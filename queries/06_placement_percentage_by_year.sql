-- Placement percentage by graduation year.
-- Denominator: all students in the graduating year.
-- Numerator: students with at least one accepted offer.
-- Each student is counted once, regardless of accepted-offer count.

WITH student_placement AS (
    SELECT
        s.student_id,
        s.graduation_year,
        EXISTS (
            SELECT 1
            FROM public.applications AS a
            JOIN public.offers AS o
                ON o.application_id = a.application_id
            WHERE a.student_id = s.student_id
              AND o.status = 'accepted'
        ) AS is_placed
    FROM public.students AS s
)
SELECT
    graduation_year,
    COUNT(*) AS total_students,
    COUNT(*) FILTER (
        WHERE is_placed
    ) AS placed_students,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE is_placed
        ) / COUNT(*),
        2
    ) AS placement_percentage
FROM student_placement
GROUP BY graduation_year
ORDER BY graduation_year;