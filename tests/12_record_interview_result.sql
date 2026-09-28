-- Test recording a successful interview result.
-- Simulates the outcome of Aarav's scheduled interview.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK restores the original pending result.

-- SECTION 1: Verify the starting state.
SELECT
    i.interview_id,
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

-- SECTION 2: Begin the test.
BEGIN;

-- SECTION 3: Record a simulated successful result.
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
    'Demonstrated clear SQL reasoning and explained joins correctly.'
) AS recorded_result;

-- SECTION 4: Inspect the result and feedback.
SELECT
    s.full_name,
    j.job_title,
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

-- SECTION 5: Undo the test update.
ROLLBACK;

-- SECTION 6: Verify the original result and feedback.
SELECT
    i.result,
    i.feedback
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