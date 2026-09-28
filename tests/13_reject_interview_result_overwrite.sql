-- Verify that a completed interview result cannot be overwritten.
-- Aarav's backend round 1 must initially be pending.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK restores the initial result and feedback.

-- SECTION 1: Confirm the starting state.
SELECT
    i.round_number,
    i.result,
    i.feedback,
    a.status AS application_status
FROM public.interviews AS i
JOIN public.applications AS a
    ON a.application_id = i.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern'
  AND i.round_number = 1;

-- SECTION 2: Begin the test transaction.
BEGIN;

-- SECTION 3: Record the first result successfully.
SELECT public.record_interview_result(
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
    'passed',
    'Initial result recorded during overwrite-protection test.'
) AS first_result;

-- SECTION 4: Attempt to overwrite the completed result.
-- Expected: Cannot overwrite... current result is passed.
-- Expected SQLSTATE: 23514.
SELECT public.record_interview_result(
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
    'failed',
    'This overwrite must be rejected.'
) AS overwritten_result;

-- SECTION 5: Undo the whole test transaction.
ROLLBACK;

-- SECTION 6: Confirm the original state was restored.
SELECT
    i.result,
    i.feedback,
    a.status AS application_status
FROM public.interviews AS i
JOIN public.applications AS a
    ON a.application_id = i.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern'
  AND i.round_number = 1;