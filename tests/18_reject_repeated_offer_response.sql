-- Verify that an offer cannot receive a second response.
-- Aarav's offer must initially be pending.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK restores the original pending offer.

-- SECTION 1: Confirm the starting state.
SELECT
    o.offer_id,
    s.full_name,
    o.status AS offer_status,
    o.responded_at
FROM public.offers AS o
JOIN public.applications AS a
    ON a.application_id = o.application_id
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

-- SECTION 3: First response should succeed.
SELECT public.respond_to_offer(
    (
        SELECT o.offer_id
        FROM public.offers AS o
        JOIN public.applications AS a
            ON a.application_id = o.application_id
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
    'accepted',
    TIMESTAMPTZ '2026-10-03 10:00:00+05:30'
) AS first_response;

-- SECTION 4: A second response must be rejected.
-- Expected: current status is accepted, expected pending.
-- Expected SQLSTATE: 23514.
SELECT public.respond_to_offer(
    (
        SELECT o.offer_id
        FROM public.offers AS o
        JOIN public.applications AS a
            ON a.application_id = o.application_id
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
    'declined',
    TIMESTAMPTZ '2026-10-04 10:00:00+05:30'
) AS second_response;

-- SECTION 5: Undo the entire test transaction.
ROLLBACK;

-- SECTION 6: Confirm restoration of the original offer state.
SELECT
    o.status AS offer_status,
    o.responded_at
FROM public.offers AS o
JOIN public.applications AS a
    ON a.application_id = o.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern';