-- Additional fictional recruitment outcomes.
-- Run after 06_sample_workflow.sql.
-- Execute each sample block once.

-- Scenario 1:
-- Ananya passes a Java interview and receives a pending
-- full-time conversion offer of INR 900,000 (9 LPA).

BEGIN;

DO $$
DECLARE
    v_application_id BIGINT;
    v_application_status TEXT;
BEGIN
    -- Find exactly one matching application.
    SELECT
        a.application_id,
        a.status
    INTO STRICT
        v_application_id,
        v_application_status
    FROM public.applications AS a
    JOIN public.students AS s
        ON s.student_id = a.student_id
    JOIN public.jobs AS j
        ON j.job_id = a.job_id
    JOIN public.companies AS c
        ON c.company_id = j.company_id
    WHERE s.university_email = 'ananya.das@example.com'
      AND c.company_name = 'Cedarbyte Labs'
      AND j.job_title = 'Java Developer Intern';

    IF v_application_status <> 'submitted' THEN
        RAISE EXCEPTION
            'Expected Ananya''s Java application to be submitted.';
    END IF;

    PERFORM public.change_application_status(
        v_application_id,
        'shortlisted'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'interviewing'
    );

    PERFORM public.schedule_interview(
        v_application_id,
        1,
        'Java and Data Structures Interview',
        TIMESTAMPTZ '2026-10-04 11:00:00+05:30'
    );

    PERFORM public.record_interview_result(
        v_application_id,
        1,
        'passed',
        'Explained Java fundamentals and data structures clearly.'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'selected'
    );

    PERFORM public.create_offer(
        v_application_id,
        900000.00,
        TIMESTAMPTZ '2026-10-05 15:00:00+05:30'
    );
END;
$$;

COMMIT;

-- Scenario 2:
-- Meera passes her interview and receives a graduate offer
-- of INR 1,000,000 (10 LPA), which she declines.
-- Execute this block once.

BEGIN;

DO $$
DECLARE
    v_application_id BIGINT;
    v_application_status TEXT;
    v_offer_id BIGINT;
BEGIN
    SELECT
        a.application_id,
        a.status
    INTO STRICT
        v_application_id,
        v_application_status
    FROM public.applications AS a
    JOIN public.students AS s
        ON s.student_id = a.student_id
    JOIN public.jobs AS j
        ON j.job_id = a.job_id
    JOIN public.companies AS c
        ON c.company_id = j.company_id
    WHERE s.university_email = 'meera.rao@example.com'
      AND c.company_name = 'Riverstone Software'
      AND j.job_title = 'Graduate Software Engineer';

    IF v_application_status <> 'submitted' THEN
        RAISE EXCEPTION
            'Expected Meera''s graduate application to be submitted.';
    END IF;

    PERFORM public.change_application_status(
        v_application_id,
        'shortlisted'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'interviewing'
    );

    PERFORM public.schedule_interview(
        v_application_id,
        1,
        'Software Engineering Interview',
        TIMESTAMPTZ '2026-10-05 10:00:00+05:30'
    );

    PERFORM public.record_interview_result(
        v_application_id,
        1,
        'passed',
        'Demonstrated strong programming and database fundamentals.'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'selected'
    );

    v_offer_id := public.create_offer(
        v_application_id,
        1000000.00,
        TIMESTAMPTZ '2026-10-06 15:00:00+05:30'
    );

    PERFORM public.respond_to_offer(
        v_offer_id,
        'declined',
        TIMESTAMPTZ '2026-10-07 10:00:00+05:30'
    );
END;
$$;

COMMIT;

-- Scenario 3:
-- Priya does not pass her technical interview.
-- The company then rejects her application.
-- Execute this block once.

BEGIN;

DO $$
DECLARE
    v_application_id BIGINT;
    v_application_status TEXT;
BEGIN
    SELECT
        a.application_id,
        a.status
    INTO STRICT
        v_application_id,
        v_application_status
    FROM public.applications AS a
    JOIN public.students AS s
        ON s.student_id = a.student_id
    JOIN public.jobs AS j
        ON j.job_id = a.job_id
    JOIN public.companies AS c
        ON c.company_id = j.company_id
    WHERE s.university_email = 'priya.sen@example.com'
      AND c.company_name = 'Aurora Systems'
      AND j.job_title = 'Backend Developer Intern';

    IF v_application_status <> 'submitted' THEN
        RAISE EXCEPTION
            'Expected Priya''s backend application to be submitted.';
    END IF;

    PERFORM public.change_application_status(
        v_application_id,
        'shortlisted'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'interviewing'
    );

    PERFORM public.schedule_interview(
        v_application_id,
        1,
        'Technical Interview',
        TIMESTAMPTZ '2026-10-06 11:00:00+05:30'
    );

    PERFORM public.record_interview_result(
        v_application_id,
        1,
        'failed',
        'Needs more practice with SQL joins and query reasoning.'
    );

    PERFORM public.change_application_status(
        v_application_id,
        'rejected'
    );
END;
$$;

COMMIT;