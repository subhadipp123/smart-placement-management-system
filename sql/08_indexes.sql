-- Additional index for retrieving applications by job.
-- Run once after 01_schema.sql.
-- Benchmark evidence: docs/performance-analysis.md.

CREATE INDEX applications_job_id_idx
ON public.applications (job_id);