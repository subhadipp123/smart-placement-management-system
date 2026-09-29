-- Create an isolated application-lookup benchmark.
-- Run once in a database without a performance_lab schema.
-- Define the baseline structure explicitly so future indexes
-- on public.applications do not change the benchmark.

BEGIN;

CREATE SCHEMA performance_lab;

CREATE TABLE performance_lab.applications (
    application_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id BIGINT NOT NULL,
    job_id BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'submitted',
    applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT applications_student_job_unique
        UNIQUE (student_id, job_id),

    CONSTRAINT applications_status_allowed
        CHECK (
            status IN (
                'submitted',
                'shortlisted',
                'interviewing',
                'selected',
                'rejected',
                'withdrawn'
            )
        )
);

INSERT INTO performance_lab.applications (
    student_id,
    job_id,
    status,
    applied_at
)
SELECT
    n::BIGINT,
    (1 + ((n - 1) % 1000))::BIGINT,
    'submitted',
    TIMESTAMPTZ '2026-01-01 00:00:00+00'
        + n * INTERVAL '1 minute'
FROM generate_series(1, 100000) AS generated(n);

COMMIT;

ANALYZE performance_lab.applications;

SELECT
    COUNT(*) AS total_applications,
    COUNT(DISTINCT student_id) AS distinct_students,
    COUNT(DISTINCT job_id) AS distinct_jobs,
    COUNT(*) FILTER (
        WHERE job_id = 42
    ) AS applications_for_job_42
FROM performance_lab.applications;