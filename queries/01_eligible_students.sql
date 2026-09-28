-- Display currently eligible student-job pairs.
-- Requires sql/03_views.sql to have been executed.

SELECT
    job_id,
    company_name,
    job_title,
    student_id,
    full_name,
    university_email,
    cgpa,
    min_cgpa
FROM public.eligible_student_jobs
ORDER BY
    company_name,
    job_title,
    full_name;