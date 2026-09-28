-- Reusable views for the Smart Placement Management System.
-- Run after 01_schema.sql.

CREATE OR REPLACE VIEW public.eligible_student_jobs AS
SELECT
    j.job_id,
    c.company_name,
    j.job_title,
    s.student_id,
    s.full_name,
    s.university_email,
    s.cgpa,
    j.min_cgpa
FROM public.students AS s
CROSS JOIN public.jobs AS j
JOIN public.companies AS c
    ON c.company_id = j.company_id
WHERE j.status = 'open'
  AND s.cgpa >= j.min_cgpa
  AND s.graduation_year = j.graduation_year
  AND (
      j.allows_active_backlogs = TRUE
      OR s.active_backlogs = 0
  )
  AND NOT EXISTS (
      SELECT 1
      FROM public.job_required_skills AS jrs
      WHERE jrs.job_id = j.job_id
        AND NOT EXISTS (
            SELECT 1
            FROM public.student_skills AS ss
            WHERE ss.student_id = s.student_id
              AND ss.skill_id = jrs.skill_id
        )
  );