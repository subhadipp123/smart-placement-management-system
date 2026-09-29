-- Measure the same lookup after adding the job_id index.
-- Keep the selected columns and filter identical to the baseline.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    application_id,
    student_id,
    status,
    applied_at
FROM performance_lab.applications
WHERE job_id = 42;