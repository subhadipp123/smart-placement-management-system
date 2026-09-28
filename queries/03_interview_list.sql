-- Display interview rounds with student and job details.
-- Show the scheduled time explicitly in India time.

SELECT
    i.interview_id,
    s.full_name,
    c.company_name,
    j.job_title,
    i.round_number,
    i.round_name,
    i.scheduled_at AT TIME ZONE 'Asia/Kolkata'
        AS scheduled_at_india,
    i.result
FROM public.interviews AS i
JOIN public.applications AS a
    ON a.application_id = i.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
ORDER BY
    i.scheduled_at,
    i.interview_id;