-- Demonstrate the placement workflow using fictional sample data.
-- Run after 05_sample_applications.sql and the current 04_functions.sql.
-- Execute this initial block once.
-- Aarav's backend application must initially be submitted.

BEGIN;

-- Step 1: submitted -> shortlisted.
SELECT public.change_application_status(
    (
        SELECT a.application_id
        FROM public.applications AS a
        JOIN public.students AS s
            ON s.student_id = a.student_id
        JOIN public.jobs AS j
            ON j.job_id = a.job_id
        JOIN public.companies AS c
            ON c.company_id = j.company_id
        WHERE s.university_email = 'aarav.sharma@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    'shortlisted'
) AS new_status;

-- Step 2: shortlisted -> interviewing.
SELECT public.change_application_status(
    (
        SELECT a.application_id
        FROM public.applications AS a
        JOIN public.students AS s
            ON s.student_id = a.student_id
        JOIN public.jobs AS j
            ON j.job_id = a.job_id
        JOIN public.companies AS c
            ON c.company_id = j.company_id
        WHERE s.university_email = 'aarav.sharma@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    'interviewing'
) AS new_status;

COMMIT;

-- Schedule Aarav's first backend interview.
-- Execute this block once, after creating schedule_interview.

BEGIN;

SELECT public.schedule_interview(
    (
        SELECT a.application_id
        FROM public.applications AS a
        JOIN public.students AS s
            ON s.student_id = a.student_id
        JOIN public.jobs AS j
            ON j.job_id = a.job_id
        JOIN public.companies AS c
            ON c.company_id = j.company_id
        WHERE s.university_email = 'aarav.sharma@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    1,
    'Technical Interview',
    TIMESTAMPTZ '2026-10-01 10:00:00+05:30'
) AS new_interview_id;

COMMIT;