-- Verify that a student cannot apply to the same job twice.
-- Requires the initial sample data, eligibility view,
-- and submit_application function.
-- Start with applications empty.
-- Execute sections separately in the same pgAdmin Query Tool tab.

-- SECTION 1: Start the test transaction.
BEGIN;

-- SECTION 2: First submission should succeed.
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
) AS first_application_id;

-- SECTION 3: Repeat the same submission.
-- Expected: applications_student_job_unique violation.
-- Expected SQLSTATE: 23505.
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
) AS duplicate_application_id;

-- SECTION 4: End the failed transaction and undo the first insert.
ROLLBACK;

-- SECTION 5: Confirm that no test applications remain.
SELECT COUNT(*) AS application_count_after_rollback
FROM public.applications;