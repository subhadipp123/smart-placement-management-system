-- Test successful application submission.
-- Requires the initial sample data, eligibility view,
-- and submit_application function.
-- Run with applications initially empty.
-- ROLLBACK removes the application created by this test.

BEGIN;

-- Aarav meets all requirements for this open backend role.
SELECT public.submit_application(
    (
        SELECT s.student_id
        FROM public.students AS s
        WHERE s.university_email = 'aarav.sharma@example.com'
    ),
    (
        SELECT j.job_id
        FROM public.jobs AS j
        JOIN public.companies AS c
            ON c.company_id = j.company_id
        WHERE c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    )
) AS new_application_id;

-- Inspect the application before rolling back.
SELECT
    a.application_id,
    s.full_name,
    c.company_name,
    j.job_title,
    a.status,
    a.applied_at
FROM public.applications AS a
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern';

ROLLBACK;

-- Confirm that the test left no application behind.
SELECT COUNT(*) AS application_count_after_rollback
FROM public.applications;