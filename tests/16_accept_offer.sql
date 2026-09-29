-- Test accepting Aarav's pending offer.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK restores the pending offer.

-- SECTION 1: Check the starting state.
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

-- SECTION 3: Accept the offer using a simulated response date.
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
) AS recorded_response;

-- SECTION 4: Inspect the updated offer.
SELECT
    s.full_name,
    a.status AS application_status,
    o.status AS offer_status,
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

-- SECTION 5: Undo the test response.
ROLLBACK;

-- SECTION 6: Verify restoration.
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