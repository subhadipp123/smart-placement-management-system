-- Verify that offers cannot be created before selection.
-- Priya's backend application must currently be submitted.
-- Execute sections separately in the same pgAdmin tab.
-- The existing offer for Aarav must remain unchanged.

-- SECTION 1: Check Priya's application and existing offer count.
SELECT
    a.application_id,
    s.full_name,
    a.status AS application_status,
    (
        SELECT COUNT(*)
        FROM public.offers AS o
        WHERE o.application_id = a.application_id
    ) AS offer_count
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

-- SECTION 2: Start the test transaction.
BEGIN;

-- SECTION 3: Attempt to create an offer before selection.
-- Expected: status submitted is rejected; expected selected.
-- Expected SQLSTATE: 23514.
SELECT public.create_offer(
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
    800000.00,
    TIMESTAMPTZ '2026-10-02 15:00:00+05:30'
) AS new_offer_id;

-- SECTION 4: Clear the failed transaction.
ROLLBACK;

-- SECTION 5: Confirm that Priya received no offer.
SELECT COUNT(*) AS priya_offer_count
FROM public.offers AS o
JOIN public.applications AS a
    ON a.application_id = o.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE s.university_email = 'priya.sen@example.com'
  AND c.company_name = 'Aurora Systems'
  AND j.job_title = 'Backend Developer Intern';

-- SECTION 6: Inspect the existing offers.
SELECT
    s.full_name,
    c.company_name,
    j.job_title,
    o.annual_ctc_inr,
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
ORDER BY o.offer_id;