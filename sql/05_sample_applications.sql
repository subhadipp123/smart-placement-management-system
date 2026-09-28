-- Create eight fictional applications through the submission function.
-- Run after:
--   01_schema.sql
--   02_sample_data.sql
--   03_views.sql
--   04_functions.sql
--
-- Execute once, with applications empty.
-- COMMIT keeps these records for later workflow demonstrations.

BEGIN;

SELECT
    sample.student_email,
    sample.company_name,
    sample.job_title,
    public.submit_application(
        (
            SELECT s.student_id
            FROM public.students AS s
            WHERE s.university_email = sample.student_email
        ),
        (
            SELECT j.job_id
            FROM public.jobs AS j
            JOIN public.companies AS c
                ON c.company_id = j.company_id
            WHERE c.company_name = sample.company_name
              AND j.job_title = sample.job_title
        )
    ) AS application_id
FROM (
    VALUES
        (
            'aarav.sharma@example.com',
            'Aurora Systems',
            'Backend Developer Intern'
        ),
        (
            'aarav.sharma@example.com',
            'Orbit Dataworks',
            'Data Analyst Intern'
        ),
        (
            'ananya.das@example.com',
            'Aurora Systems',
            'Backend Developer Intern'
        ),
        (
            'ananya.das@example.com',
            'Cedarbyte Labs',
            'Java Developer Intern'
        ),
        (
            'ananya.das@example.com',
            'Orbit Dataworks',
            'Data Analyst Intern'
        ),
        (
            'priya.sen@example.com',
            'Aurora Systems',
            'Backend Developer Intern'
        ),
        (
            'meera.rao@example.com',
            'Riverstone Software',
            'Graduate Software Engineer'
        ),
        (
            'sara.khan@example.com',
            'Summit Cloud Technologies',
            'Cloud Support Intern'
        )
) AS sample (student_email, company_name, job_title);

COMMIT;