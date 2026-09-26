-- Test: a job cannot reference a nonexistent company.
-- Run sections A through E separately, in the same session.
-- Section A must return 0 before continuing.
-- Expected error in section C: jobs_company_fk.
-- Always run section D after attempting the insertion.

-- A: Confirm that our chosen company ID does not exist.
SELECT COUNT(*) AS matching_companies
FROM public.companies
WHERE company_id = -1;

-- B: Start the test transaction.
BEGIN;

-- C: Attempt to create a job for the nonexistent company.
INSERT INTO public.jobs (
    company_id,
    job_title,
    min_cgpa,
    graduation_year,
    allows_active_backlogs,
    status
)
VALUES (
    -1,
    'Foreign Key Test Job',
    7.00,
    2027,
    FALSE,
    'open'
);

-- D: End the transaction and undo any changes.
ROLLBACK;

-- E: Confirm that the test job was not retained.
SELECT COUNT(*) AS remaining_test_jobs
FROM public.jobs
WHERE company_id = -1
  AND job_title = 'Foreign Key Test Job';