-- Verify that an interview cannot be scheduled
-- while an application is still submitted.
-- Execute sections separately in the same pgAdmin tab.
-- Priya's backend application must initially be submitted.

-- SECTION 1: Check the starting application state.
SELECT
    a.application_id,
    s.full_name,
    j.job_title,
    a.status,
    (
        SELECT COUNT(*)
        FROM public.interviews AS i
        WHERE i.application_id = a.application_id
    ) AS interview_count
FROM public.applications AS a
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'priya.sen@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern';

-- SECTION 2: Begin the test transaction.
BEGIN;

-- SECTION 3: Attempt scheduling before the interviewing stage.
-- Expected: status submitted is rejected.
-- Expected SQLSTATE: 23514.
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
        WHERE s.university_email = 'priya.sen@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    1,
    'Technical Interview',
    TIMESTAMPTZ '2026-10-01 11:00:00+05:30'
) AS new_interview_id;

-- SECTION 4: Clear the failed transaction.
ROLLBACK;

-- SECTION 5: Confirm Priya still has no interview.
SELECT COUNT(*) AS priya_interview_count
FROM public.interviews AS i
JOIN public.applications AS a
    ON a.application_id = i.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'priya.sen@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern';

-- SECTION 6: Confirm Aarav's existing interview remains.
SELECT
    result,
    COUNT(*) AS interview_count
FROM public.interviews
GROUP BY result
ORDER BY result;