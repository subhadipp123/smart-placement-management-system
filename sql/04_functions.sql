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

-- Change an application's status through the allowed workflow.
-- Returns the new status after a successful update.

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
    -- Lock this application until the surrounding transaction ends.
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

    -- Reject NULL and unknown status values.
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

    -- Check the requested transition against the workflow.
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

    UPDATE public.applications
    SET status = p_new_status
    WHERE application_id = p_application_id;

    RETURN p_new_status;
END;
$$;