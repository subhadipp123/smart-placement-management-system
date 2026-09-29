-- Database functions for the Smart Placement Management System.
-- Run after 01_schema.sql and 03_views.sql.

CREATE OR REPLACE FUNCTION public.submit_application(
    p_student_id BIGINT,
    p_job_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_application_id BIGINT;
BEGIN
    INSERT INTO public.applications AS a (
        student_id,
        job_id
    )
    SELECT
        e.student_id,
        e.job_id
    FROM public.eligible_student_jobs AS e
    WHERE e.student_id = p_student_id
      AND e.job_id = p_job_id
    RETURNING a.application_id INTO v_application_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Application rejected: no eligible student-job pair for student_id % and job_id %.',
            p_student_id,
            p_job_id
            USING ERRCODE = '23514';
    END IF;

    RETURN v_application_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.change_application_status(
    p_application_id BIGINT,
    p_new_status TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status TEXT;
BEGIN
    -- Lock the application before checking or changing its state.
    SELECT a.status
    INTO v_current_status
    FROM public.applications AS a
    WHERE a.application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Application % does not exist.',
            p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF p_new_status IS NULL
       OR p_new_status NOT IN (
           'submitted',
           'shortlisted',
           'interviewing',
           'selected',
           'rejected',
           'withdrawn'
       )
    THEN
        RAISE EXCEPTION
            'Invalid application status: %.',
            p_new_status
            USING ERRCODE = '23514';
    END IF;

    -- Enforce the allowed status transitions.
    IF NOT (
        (
            v_current_status = 'submitted'
            AND p_new_status IN (
                'shortlisted', 'rejected', 'withdrawn'
            )
        )
        OR
        (
            v_current_status = 'shortlisted'
            AND p_new_status IN (
                'interviewing', 'rejected', 'withdrawn'
            )
        )
        OR
        (
            v_current_status = 'interviewing'
            AND p_new_status IN (
                'selected', 'rejected', 'withdrawn'
            )
        )
    )
    THEN
        RAISE EXCEPTION
            'Transition from % to % is not allowed for application %.',
            v_current_status,
            p_new_status,
            p_application_id
            USING ERRCODE = '23514';
    END IF;

    -- Additional requirements apply when selecting an application.
    IF p_new_status = 'selected' THEN

        IF NOT EXISTS (
            SELECT 1
            FROM public.interviews AS i
            WHERE i.application_id = p_application_id
        )
        THEN
            RAISE EXCEPTION
                'Cannot select application %: at least one interview round is required.',
                p_application_id
                USING ERRCODE = '23514';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM public.interviews AS i
            WHERE i.application_id = p_application_id
              AND i.result <> 'passed'
        )
        THEN
            RAISE EXCEPTION
                'Cannot select application %: every interview round must be passed.',
                p_application_id
                USING ERRCODE = '23514';
        END IF;

    END IF;

    UPDATE public.applications
    SET status = p_new_status
    WHERE application_id = p_application_id;

    RETURN p_new_status;
END;
$$;

-- Schedule a round for an application in the interviewing stage.
-- Returns the generated interview ID.

CREATE OR REPLACE FUNCTION public.schedule_interview(
    p_application_id BIGINT,
    p_round_number INTEGER,
    p_round_name TEXT,
    p_scheduled_at TIMESTAMPTZ
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_application_status TEXT;
    v_interview_id BIGINT;
BEGIN
    -- Coordinate scheduling with application-status changes.
    SELECT a.status
    INTO v_application_status
    FROM public.applications AS a
    WHERE a.application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Application % does not exist.',
            p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_application_status <> 'interviewing' THEN
        RAISE EXCEPTION
            'Cannot schedule interview: application % has status %, expected interviewing.',
            p_application_id,
            v_application_status
            USING ERRCODE = '23514';
    END IF;

    INSERT INTO public.interviews AS i (
        application_id,
        round_number,
        round_name,
        scheduled_at
    )
    VALUES (
        p_application_id,
        p_round_number,
        p_round_name,
        p_scheduled_at
    )
    RETURNING i.interview_id INTO v_interview_id;

    RETURN v_interview_id;
END;
$$;

-- Record the outcome of a pending interview round.
-- Returns the recorded result.

CREATE OR REPLACE FUNCTION public.record_interview_result(
    p_application_id BIGINT,
    p_round_number INTEGER,
    p_result TEXT,
    p_feedback TEXT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_application_status TEXT;
    v_interview_id BIGINT;
    v_current_result TEXT;
BEGIN
    -- Lock the parent application first, as in scheduling.
    SELECT a.status
    INTO v_application_status
    FROM public.applications AS a
    WHERE a.application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Application % does not exist.',
            p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_application_status <> 'interviewing' THEN
        RAISE EXCEPTION
            'Cannot record result: application % has status %, expected interviewing.',
            p_application_id,
            v_application_status
            USING ERRCODE = '23514';
    END IF;

    -- Find and lock the requested round.
    SELECT
        i.interview_id,
        i.result
    INTO
        v_interview_id,
        v_current_result
    FROM public.interviews AS i
    WHERE i.application_id = p_application_id
      AND i.round_number = p_round_number
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Round % does not exist for application %.',
            p_round_number,
            p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF p_result IS NULL
       OR p_result NOT IN (
           'passed', 'failed', 'absent', 'cancelled'
       )
    THEN
        RAISE EXCEPTION
            'Invalid interview outcome: %.',
            p_result
            USING ERRCODE = '23514';
    END IF;

    IF v_current_result <> 'pending' THEN
        RAISE EXCEPTION
            'Cannot overwrite round % for application %: current result is %.',
            p_round_number,
            p_application_id,
            v_current_result
            USING ERRCODE = '23514';
    END IF;

    UPDATE public.interviews
    SET
        result = p_result,
        feedback = p_feedback
    WHERE interview_id = v_interview_id;

    RETURN p_result;
END;
$$;

-- Create a pending offer for a selected application.
-- Returns the generated offer ID.

CREATE OR REPLACE FUNCTION public.create_offer(
    p_application_id BIGINT,
    p_annual_ctc_inr NUMERIC,
    p_offered_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_application_status TEXT;
    v_offer_id BIGINT;
BEGIN
    -- Coordinate offer creation with application-status operations.
    SELECT a.status
    INTO v_application_status
    FROM public.applications AS a
    WHERE a.application_id = p_application_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Application % does not exist.',
            p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_application_status <> 'selected' THEN
        RAISE EXCEPTION
            'Cannot create offer: application % has status %, expected selected.',
            p_application_id,
            v_application_status
            USING ERRCODE = '23514';
    END IF;

    INSERT INTO public.offers AS o (
        application_id,
        annual_ctc_inr,
        status,
        offered_at,
        responded_at
    )
    VALUES (
        p_application_id,
        p_annual_ctc_inr,
        'pending',
        p_offered_at,
        NULL
    )
    RETURNING o.offer_id INTO v_offer_id;

    RETURN v_offer_id;
END;
$$;

-- Accept or decline a pending offer.
-- Returns the saved response status.

CREATE OR REPLACE FUNCTION public.respond_to_offer(
    p_offer_id BIGINT,
    p_response TEXT,
    p_responded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status TEXT;
    v_offered_at TIMESTAMPTZ;
BEGIN
    -- Lock the offer while checking and recording its response.
    SELECT
        o.status,
        o.offered_at
    INTO
        v_current_status,
        v_offered_at
    FROM public.offers AS o
    WHERE o.offer_id = p_offer_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Offer % does not exist.',
            p_offer_id
            USING ERRCODE = 'P0002';
    END IF;

    IF p_response IS NULL
       OR p_response NOT IN ('accepted', 'declined')
    THEN
        RAISE EXCEPTION
            'Invalid offer response: %. Use accepted or declined.',
            p_response
            USING ERRCODE = '23514';
    END IF;

    IF v_current_status <> 'pending' THEN
        RAISE EXCEPTION
            'Cannot respond to offer %: current status is %, expected pending.',
            p_offer_id,
            v_current_status
            USING ERRCODE = '23514';
    END IF;

    IF p_responded_at IS NULL THEN
        RAISE EXCEPTION
            'Response timestamp is required for offer %.',
            p_offer_id
            USING ERRCODE = '23514';
    END IF;

    IF p_responded_at < v_offered_at THEN
        RAISE EXCEPTION
            'Response timestamp cannot precede the offer timestamp for offer %.',
            p_offer_id
            USING ERRCODE = '23514';
    END IF;

    UPDATE public.offers
    SET
        status = p_response,
        responded_at = p_responded_at
    WHERE offer_id = p_offer_id;

    RETURN p_response;
END;
$$;