-- Row counts after loading the initial sample data.
-- Application, interview, and offer data will be added later.

SELECT 'companies' AS table_name, COUNT(*) AS row_count
FROM public.companies

UNION ALL

SELECT 'skills', COUNT(*)
FROM public.skills

UNION ALL

SELECT 'students', COUNT(*)
FROM public.students

UNION ALL

SELECT 'student_skills', COUNT(*)
FROM public.student_skills

UNION ALL

SELECT 'jobs', COUNT(*)
FROM public.jobs

UNION ALL

SELECT 'job_required_skills', COUNT(*)
FROM public.job_required_skills

ORDER BY table_name;