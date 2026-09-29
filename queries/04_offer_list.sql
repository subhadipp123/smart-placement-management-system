-- Display offers with student and job details.
-- Monetary values are annual CTC in Indian rupees.

SELECT
    o.offer_id,
    s.full_name,
    c.company_name,
    j.job_title,
    o.annual_ctc_inr,
    ROUND(o.annual_ctc_inr / 100000.0, 2) AS annual_ctc_lpa,
    o.status AS offer_status,
    o.offered_at AT TIME ZONE 'Asia/Kolkata'
        AS offered_at_india,
    o.responded_at AT TIME ZONE 'Asia/Kolkata'
        AS responded_at_india
FROM public.offers AS o
JOIN public.applications AS a
    ON a.application_id = o.application_id
JOIN public.students AS s
    ON s.student_id = a.student_id
JOIN public.jobs AS j
    ON j.job_id = a.job_id
JOIN public.companies AS c
    ON c.company_id = j.company_id
ORDER BY o.offer_id;