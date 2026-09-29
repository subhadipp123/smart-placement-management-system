-- Inspect the execution plan for finding a job's applications.
-- EXPLAIN ANALYZE executes this read-only SELECT.
-- Run against the existing small sample database first.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    a.application_id,
    a.student_id,
    a.status,
    a.applied_at
FROM public.applications AS a
WHERE a.job_id = (
    SELECT j.job_id
    FROM public.jobs AS j
    JOIN public.companies AS c
        ON c.company_id = j.company_id
    WHERE c.company_name = 'Aurora Systems'
      AND j.job_title = 'Backend Developer Intern'
);