-- Test submitted -> shortlisted for Aarav's backend application.
-- Requires the eight sample applications in their initial state.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK restores the original submitted status.

-- SECTION 1: Confirm the starting status.
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

-- SECTION 2: Begin the test transaction.
BEGIN;

-- SECTION 3: Shortlist the application.
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

-- SECTION 4: Verify the temporary status counts.
SELECT
    status,
    COUNT(*) AS application_count
FROM public.applications
GROUP BY status
ORDER BY status;

-- SECTION 5: Undo the test update.
ROLLBACK;

-- SECTION 6: Verify the original state was restored.
SELECT
    status,
    COUNT(*) AS application_count
FROM public.applications
GROUP BY status
ORDER BY status;