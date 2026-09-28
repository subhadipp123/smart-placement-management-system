-- Compare eligibility results with the expected sample-data results.
-- Run after loading all initial sample data and executing 03_views.sql.
-- Read-only test: no database records are changed.

WITH actual AS (
    SELECT
        company_name,
        job_title,
        university_email
    FROM public.eligible_student_jobs
),
expected (company_name, job_title, university_email) AS (
    VALUES
        -- Backend: CGPA >= 7.00, no backlogs, SQL + Python + Git.
        ('Aurora Systems', 'Backend Developer Intern',
         'aarav.sharma@example.com'),
        ('Aurora Systems', 'Backend Developer Intern',
         'ananya.das@example.com'),
        ('Aurora Systems', 'Backend Developer Intern',
         'priya.sen@example.com'),

        -- Java: CGPA >= 7.50, no backlogs, all three skills.
        ('Cedarbyte Labs', 'Java Developer Intern',
         'ananya.das@example.com'),

        -- Data analyst: CGPA >= 6.50, backlogs allowed, SQL + Python.
        ('Orbit Dataworks', 'Data Analyst Intern',
         'aarav.sharma@example.com'),
        ('Orbit Dataworks', 'Data Analyst Intern',
         'ananya.das@example.com'),
        ('Orbit Dataworks', 'Data Analyst Intern',
         'priya.sen@example.com'),
        ('Orbit Dataworks', 'Data Analyst Intern',
         'rohan.mehta@example.com'),

        -- Graduate role: graduation year 2026.
        ('Riverstone Software', 'Graduate Software Engineer',
         'meera.rao@example.com'),

        -- Cloud support: 2027, CGPA >= 6.00, backlogs allowed,
        -- and no required skills.
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'aarav.sharma@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'ananya.das@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'dev.malhotra@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'karan.patel@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'nisha.verma@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'priya.sen@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'rohan.mehta@example.com'),
        ('Summit Cloud Technologies', 'Cloud Support Intern',
         'sara.khan@example.com')
),
missing AS (
    SELECT * FROM expected
    EXCEPT ALL
    SELECT * FROM actual
),
unexpected AS (
    SELECT * FROM actual
    EXCEPT ALL
    SELECT * FROM expected
)
SELECT
    CASE
        WHEN NOT EXISTS (SELECT 1 FROM missing)
         AND NOT EXISTS (SELECT 1 FROM unexpected)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS test_result,
    (SELECT COUNT(*) FROM expected) AS expected_pairs,
    (SELECT COUNT(*) FROM actual) AS actual_pairs,
    (SELECT COUNT(*) FROM missing) AS missing_pairs,
    (SELECT COUNT(*) FROM unexpected) AS unexpected_pairs;