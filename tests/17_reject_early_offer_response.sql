-- Verify that an offer response cannot precede its issue timestamp.
-- Aarav's offer must initially be pending with no response timestamp.
-- Execute sections separately in the same pgAdmin tab.

-- SECTION 1: Confirm the starting state.
SELECT
    o.offer_id,
    s.full_name,
    o.status AS offer_status,
    o.offered_at AT TIME ZONE 'Asia/Kolkata'
        AS offered_at_india,
    o.responded_at AT TIME ZONE 'Asia/Kolkata'
        AS responded_at_india
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

-- SECTION 3: Attempt acceptance before the offer was issued.
-- Offer date: October 2.
-- Invalid response date: October 1.
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
    'accepted',
    TIMESTAMPTZ '2026-10-01 10:00:00+05:30'
) AS recorded_response;

-- SECTION 4: Clear the failed transaction.
ROLLBACK;

-- SECTION 5: Confirm the offer remains unchanged.
SELECT
    o.status AS offer_status,
    o.offered_at AT TIME ZONE 'Asia/Kolkata'
        AS offered_at_india,
    o.responded_at AT TIME ZONE 'Asia/Kolkata'
        AS responded_at_india
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