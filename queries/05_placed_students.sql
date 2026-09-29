-- List each placed student once.
-- Placed means having at least one accepted offer.

SELECT
    s.student_id,
    s.full_name,
    s.university_email,
    s.graduation_year
FROM public.students AS s
WHERE EXISTS (
    SELECT 1
    FROM public.applications AS a
    JOIN public.offers AS o
        ON o.application_id = a.application_id
    WHERE a.student_id = s.student_id
      AND o.status = 'accepted'
)
ORDER BY
    s.graduation_year,
    s.full_name,
    s.student_id;