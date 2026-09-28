-- Verify that submitted -> selected is rejected.
-- Requires the eight sample applications in their initial state.
-- Execute sections separately in the same pgAdmin Query Tool tab.

-- SECTION 1: Confirm Aarav's starting status.
SELECT
    a.application_id,
    a.status
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

-- SECTION 2: Start the test transaction.
BEGIN;

-- SECTION 3: Attempt a forbidden status transition.
-- Expected: submitted -> selected is rejected.
-- Expected SQLSTATE: 23514.
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
    'selected'
) AS new_status;

-- SECTION 4: End the failed transaction.
ROLLBACK;

-- SECTION 5: Confirm that all applications remain submitted.
SELECT
    status,
    COUNT(*) AS application_count
FROM public.applications
GROUP BY status
ORDER BY status;