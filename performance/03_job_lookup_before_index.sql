-- Baseline: retrieve applications for one synthetic job.
-- Run after 02_setup_performance_lab.sql.
-- Existing primary-key and student-job unique indexes remain present.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    application_id,
    student_id,
    status,
    applied_at
FROM performance_lab.applications
WHERE job_id = 42;