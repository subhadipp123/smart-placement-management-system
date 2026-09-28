-- Display saved applications with student and job details.
-- Read-only: safe to run repeatedly.

SELECT
    a.application_id,
    s.full_name,
    s.university_email,
    c.company_name,
    j.job_title,
    a.status,
    a.applied_at
FROM public.applications AS a
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
ORDER BY
    s.full_name,
    c.company_name,
    j.job_title;