-- Add a job lookup index to the benchmark table.
-- Run once, after recording the baseline plan.

CREATE INDEX applications_job_id_idx
ON performance_lab.applications (job_id);