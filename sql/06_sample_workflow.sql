-- Demonstrate the placement workflow using fictional sample data.
-- Run after 05_sample_applications.sql and the current 04_functions.sql.
-- Execute this initial block once.
-- Aarav's backend application must initially be submitted.

BEGIN;

-- Step 1: submitted -> shortlisted.
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

-- Step 2: shortlisted -> interviewing.
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
    'interviewing'
) AS new_status;

COMMIT;

-- Schedule Aarav's first backend interview.
-- Execute this block once, after creating schedule_interview.

BEGIN;

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
        WHERE s.university_email = 'aarav.sharma@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    1,
    'Technical Interview',
    TIMESTAMPTZ '2026-10-01 10:00:00+05:30'
) AS new_interview_id;

COMMIT;

-- Simulate completion of Aarav's first interview and final selection.
-- Execute this block once.
-- Starting state:
--   Application: interviewing
--   Interview round 1: pending
--
-- This fictional demonstration records the outcome without
-- waiting for the scheduled calendar date.

BEGIN;

-- Step 1: Record the successful interview outcome.
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

-- Step 2: Select the application after checking interview outcomes.
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

COMMIT;

-- Create Aarav's pending full-time conversion offer.
-- Fictional annual CTC: INR 800,000 (8 LPA).
-- Execute this block once, after Aarav's application is selected.

BEGIN;

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
        WHERE s.university_email = 'aarav.sharma@example.com'
          AND c.company_name = 'Aurora Systems'
          AND j.job_title = 'Backend Developer Intern'
    ),
    800000.00,
    TIMESTAMPTZ '2026-10-02 15:00:00+05:30'
) AS new_offer_id;

COMMIT;

-- Save Aarav's acceptance of the fictional conversion offer.
-- Execute this block once, while the offer is pending.

BEGIN;

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

COMMIT;