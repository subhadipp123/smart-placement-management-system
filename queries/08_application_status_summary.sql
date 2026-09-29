-- Current application-status distribution.
-- Includes statuses with zero applications.
-- This is a snapshot, not a historical conversion funnel.

WITH status_list (status, display_order) AS (
    VALUES
        ('submitted', 1),
        ('shortlisted', 2),
        ('interviewing', 3),
        ('selected', 4),
        ('rejected', 5),
        ('withdrawn', 6)
),
status_counts AS (
    SELECT
        sl.status,
        sl.display_order,
        COUNT(a.application_id) AS application_count
    FROM status_list AS sl
    LEFT JOIN public.applications AS a
        ON a.status = sl.status
    GROUP BY
        sl.status,
        sl.display_order
),
totals AS (
    SELECT COUNT(*) AS total_applications
    FROM public.applications
)
SELECT
    sc.status,
    sc.application_count,
    COALESCE(
        ROUND(
            100.0 * sc.application_count
            / NULLIF(t.total_applications, 0),
            2
        ),
        0.00
    ) AS percentage_of_applications
FROM status_counts AS sc
CROSS JOIN totals AS t
ORDER BY sc.display_order;