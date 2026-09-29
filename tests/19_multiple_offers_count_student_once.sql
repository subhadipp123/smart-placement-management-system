-- Verify that multiple accepted offers do not double-count a student.
-- Requires:
--   Aarav's Aurora backend offer: accepted.
--   Aarav's Orbit data analyst application: submitted.
-- Execute sections separately in the same pgAdmin tab.
-- ROLLBACK removes all temporary workflow changes.

-- SECTION 1: Check Aarav's existing applications and offers.
SELECT
    c.company_name,
    j.job_title,
    a.status AS application_status,
    o.status AS offer_status
FROM public.applications AS a
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
LEFT JOIN public.offers AS o
    ON o.application_id = a.application_id
WHERE s.university_email = 'aarav.sharma@example.com'
ORDER BY c.company_name, j.job_title;

-- SECTION 2: Begin the test transaction.
BEGIN;

-- SECTION 3: Create a second accepted offer through our functions.
DO $$
DECLARE
    v_application_id BIGINT;
    v_application_status TEXT;
    v_offer_id BIGINT;
BEGIN
    SELECT
        a.application_id,
        a.status
    INTO STRICT
        v_application_id,
        v_application_status
    FROM public.applications AS a
    JOIN public.students AS s
        ON s.student_id = a.student_id
    JOIN public.jobs AS j
        ON j.job_id = a.job_id
    JOIN public.companies AS c
        ON c.company_id = j.company_id
    WHERE s.university_email = 'aarav.sharma@example.com'
      AND c.company_name = 'Orbit Dataworks'
      AND j.job_title = 'Data Analyst Intern';

    IF v_application_status <> 'submitted' THEN
        RAISE EXCEPTION
            'Test requires Aarav''s Orbit application to be submitted.';
    END IF;

    PERFORM public.change_application_status(
        v_application_id, 'shortlisted'
    );

    PERFORM public.change_application_status(
        v_application_id, 'interviewing'
    );

    PERFORM public.schedule_interview(
        v_application_id,
        1,
        'Data Analysis Interview',
        TIMESTAMPTZ '2026-10-04 10:00:00+05:30'
    );

    PERFORM public.record_interview_result(
        v_application_id,
        1,
        'passed',
        'Temporary result for placement-count verification.'
    );

    PERFORM public.change_application_status(
        v_application_id, 'selected'
    );

    v_offer_id := public.create_offer(
        v_application_id,
        900000.00,
        TIMESTAMPTZ '2026-10-05 15:00:00+05:30'
    );

    PERFORM public.respond_to_offer(
        v_offer_id,
        'accepted',
        TIMESTAMPTZ '2026-10-06 10:00:00+05:30'
    );
END;
$$;

-- SECTION 4: Confirm Aarav now has two accepted offers.
SELECT COUNT(*) AS aarav_accepted_offers
FROM public.offers AS o
JOIN public.applications AS a
    ON a.application_id = o.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
WHERE s.university_email = 'aarav.sharma@example.com'
  AND o.status = 'accepted';

-- SECTION 5:
-- Run queries/06_placement_percentage_by_year.sql
-- in THIS SAME Query Tool tab before rolling back.
-- Expected 2027 row: 8 total, 1 placed, 12.50 percent.

-- SECTION 6: Undo the temporary second-offer workflow.
ROLLBACK;

-- SECTION 7: Verify restoration.
SELECT
    c.company_name,
    j.job_title,
    a.status AS application_status,
    o.status AS offer_status,
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
LEFT JOIN public.offers AS o
    ON o.application_id = a.application_id
WHERE s.university_email = 'aarav.sharma@example.com'
ORDER BY c.company_name, j.job_title;