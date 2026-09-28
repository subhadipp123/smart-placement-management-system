-- Verify that an ineligible application is rejected.
-- Rohan has the required skills but CGPA 6.99 is below 7.00.
-- Execute the sections separately in the same pgAdmin tab.
-- Requires applications to be empty before this test.

-- SECTION 1: Start the test transaction.
BEGIN;

-- SECTION 2: Attempt submission.
-- Expected: Application rejected... with SQLSTATE 23514.
SELECT public.submit_application(
    (
        SELECT s.student_id
        FROM public.students AS s
        WHERE s.university_email = 'rohan.mehta@example.com'
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

-- SECTION 3: Clear the failed transaction.
ROLLBACK;

-- SECTION 4: Confirm that no application was saved.
SELECT COUNT(*) AS application_count_after_rejection
FROM public.applications;