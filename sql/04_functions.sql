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