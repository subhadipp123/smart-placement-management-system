-- Verify that a pending interview blocks selection.
-- Requires Aarav's backend application to be interviewing
-- with round 1 still pending.
-- Execute sections separately in the same pgAdmin tab.

-- SECTION 1: Confirm the starting state.
SELECT
    s.full_name,
    a.status AS application_status,
    i.round_number,
    i.result AS interview_result
FROM public.applications AS a
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
JOIN public.interviews AS i
    ON i.application_id = a.application_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern'
ORDER BY i.round_number;

-- SECTION 2: Begin the test.
BEGIN;

-- SECTION 3: Attempt selection before the interview is passed.
-- Expected: every interview round must be passed.
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

-- SECTION 4: Clear the failed transaction.
ROLLBACK;

-- SECTION 5: Verify that the application state is unchanged.
SELECT
    status,
    COUNT(*) AS application_count
FROM public.applications
GROUP BY status
ORDER BY status;