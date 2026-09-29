-- Recruitment summary for every company.
-- Includes companies with no jobs, applications, or offers.
-- Each offer belongs to a unique application.
-- Placed students are counted once per company.

SELECT
    c.company_name,

    COUNT(DISTINCT j.job_id) AS total_jobs,

    COUNT(DISTINCT j.job_id) FILTER (
        WHERE j.status = 'open'
    ) AS open_jobs,

    COUNT(a.application_id) AS total_applications,

    COUNT(a.application_id) FILTER (
        WHERE a.status = 'selected'
    ) AS selected_applications,

    COUNT(o.offer_id) AS total_offers,

    COUNT(o.offer_id) FILTER (
        WHERE o.status = 'accepted'
    ) AS accepted_offers,

    COUNT(DISTINCT a.student_id) FILTER (
        WHERE o.status = 'accepted'
    ) AS placed_students

FROM public.companies AS c
LEFT JOIN public.jobs AS j
    ON j.company_id = c.company_id
LEFT JOIN public.applications AS a
    ON a.job_id = j.job_id
LEFT JOIN public.offers AS o
    ON o.application_id = a.application_id

GROUP BY
    c.company_id,
    c.company_name

ORDER BY
    c.company_name,
    c.company_id;