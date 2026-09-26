-- Smart Placement Management System
-- Fictional sample data for learning and demonstration.
-- Run after 01_schema.sql.
-- Execute this initial batch once, with companies and skills empty.

BEGIN;

-- Five fictional recruiting companies.
INSERT INTO public.companies (
    company_name,
    website
)
VALUES
    ('Aurora Systems', 'https://aurora.example'),
    ('Cedarbyte Labs', 'https://cedarbyte.example'),
    ('Orbit Dataworks', 'https://orbit.example'),
    ('Riverstone Software', 'https://riverstone.example'),
    ('Summit Cloud Technologies', 'https://summit.example');

-- Shared skill names follow our lowercase naming convention.
INSERT INTO public.skills (
    skill_name
)
VALUES
    ('sql'),
    ('c++'),
    ('python'),
    ('java'),
    ('postgresql'),
    ('git'),
    ('linux'),
    ('data structures');

COMMIT;

-- Ten fictional students covering different eligibility scenarios.
-- Run this batch once, with the students table empty.

BEGIN;

INSERT INTO public.students (
    full_name,
    university_email,
    cgpa,
    graduation_year,
    active_backlogs
)
VALUES
    ('Aarav Sharma', 'aarav.sharma@example.com', 8.50, 2027, 0),
    ('Ananya Das', 'ananya.das@example.com', 9.10, 2027, 0),
    ('Rohan Mehta', 'rohan.mehta@example.com', 6.99, 2027, 0),
    ('Priya Sen', 'priya.sen@example.com', 7.00, 2027, 0),
    ('Karan Patel', 'karan.patel@example.com', 8.20, 2027, 1),
    ('Meera Rao', 'meera.rao@example.com', 8.80, 2026, 0),
    ('Ishaan Roy', 'ishaan.roy@example.com', 7.60, 2028, 0),
    ('Nisha Verma', 'nisha.verma@example.com', 6.50, 2027, 0),
    ('Dev Malhotra', 'dev.malhotra@example.com', 7.80, 2027, 2),
    ('Sara Khan', 'sara.khan@example.com', 8.00, 2027, 0);

COMMIT;

-- Assign 30 skills across nine fictional students.
-- Sara Khan intentionally has no recorded skills.
-- Run this batch once, with student_skills empty.

BEGIN;

INSERT INTO public.student_skills (student_id, skill_id)
SELECT
    (
        SELECT s.student_id
        FROM public.students AS s
        WHERE s.university_email = mapping.student_email
    ),
    (
        SELECT sk.skill_id
        FROM public.skills AS sk
        WHERE sk.skill_name = mapping.skill_name
    )
FROM (
    VALUES
        ('aarav.sharma@example.com', 'sql'),
        ('aarav.sharma@example.com', 'python'),
        ('aarav.sharma@example.com', 'postgresql'),
        ('aarav.sharma@example.com', 'git'),

        ('ananya.das@example.com', 'sql'),
        ('ananya.das@example.com', 'python'),
        ('ananya.das@example.com', 'java'),
        ('ananya.das@example.com', 'postgresql'),
        ('ananya.das@example.com', 'git'),
        ('ananya.das@example.com', 'data structures'),

        ('rohan.mehta@example.com', 'sql'),
        ('rohan.mehta@example.com', 'python'),
        ('rohan.mehta@example.com', 'git'),

        ('priya.sen@example.com', 'sql'),
        ('priya.sen@example.com', 'python'),
        ('priya.sen@example.com', 'git'),

        ('karan.patel@example.com', 'java'),
        ('karan.patel@example.com', 'git'),
        ('karan.patel@example.com', 'data structures'),

        ('meera.rao@example.com', 'sql'),
        ('meera.rao@example.com', 'python'),
        ('meera.rao@example.com', 'postgresql'),

        ('ishaan.roy@example.com', 'c++'),
        ('ishaan.roy@example.com', 'git'),
        ('ishaan.roy@example.com', 'data structures'),

        ('nisha.verma@example.com', 'sql'),
        ('nisha.verma@example.com', 'linux'),

        ('dev.malhotra@example.com', 'java'),
        ('dev.malhotra@example.com', 'linux'),
        ('dev.malhotra@example.com', 'git')
) AS mapping (student_email, skill_name);

COMMIT;

-- Six fictional jobs covering different eligibility scenarios.
-- Run this batch once, with the jobs table empty.

BEGIN;

INSERT INTO public.jobs (
    company_id,
    job_title,
    min_cgpa,
    graduation_year,
    allows_active_backlogs,
    status
)
SELECT
    (
        SELECT c.company_id
        FROM public.companies AS c
        WHERE c.company_name = job_data.company_name
    ),
    job_data.job_title,
    job_data.min_cgpa,
    job_data.graduation_year,
    job_data.allows_active_backlogs,
    job_data.status
FROM (
    VALUES
        (
            'Aurora Systems',
            'Backend Developer Intern',
            7.00,
            2027,
            FALSE,
            'open'
        ),
        (
            'Cedarbyte Labs',
            'Java Developer Intern',
            7.50,
            2027,
            FALSE,
            'open'
        ),
        (
            'Orbit Dataworks',
            'Data Analyst Intern',
            6.50,
            2027,
            TRUE,
            'open'
        ),
        (
            'Riverstone Software',
            'Graduate Software Engineer',
            7.00,
            2026,
            FALSE,
            'open'
        ),
        (
            'Summit Cloud Technologies',
            'Cloud Support Intern',
            6.00,
            2027,
            TRUE,
            'open'
        ),
        (
            'Aurora Systems',
            'Software Engineer Trainee',
            7.00,
            2027,
            FALSE,
            'closed'
        )
) AS job_data (
    company_name,
    job_title,
    min_cgpa,
    graduation_year,
    allows_active_backlogs,
    status
);

COMMIT;

-- Thirteen required-skill assignments across five jobs.
-- Cloud Support Intern intentionally has no required skills.
-- Run this batch once, with job_required_skills empty.

BEGIN;

INSERT INTO public.job_required_skills (job_id, skill_id)
SELECT
    (
        SELECT j.job_id
        FROM public.jobs AS j
        JOIN public.companies AS c
            ON c.company_id = j.company_id
        WHERE c.company_name = mapping.company_name
          AND j.job_title = mapping.job_title
    ),
    (
        SELECT sk.skill_id
        FROM public.skills AS sk
        WHERE sk.skill_name = mapping.skill_name
    )
FROM (
    VALUES
        (
            'Aurora Systems',
            'Backend Developer Intern',
            'sql'
        ),
        (
            'Aurora Systems',
            'Backend Developer Intern',
            'python'
        ),
        (
            'Aurora Systems',
            'Backend Developer Intern',
            'git'
        ),
        (
            'Cedarbyte Labs',
            'Java Developer Intern',
            'java'
        ),
        (
            'Cedarbyte Labs',
            'Java Developer Intern',
            'git'
        ),
        (
            'Cedarbyte Labs',
            'Java Developer Intern',
            'data structures'
        ),
        (
            'Orbit Dataworks',
            'Data Analyst Intern',
            'sql'
        ),
        (
            'Orbit Dataworks',
            'Data Analyst Intern',
            'python'
        ),
        (
            'Riverstone Software',
            'Graduate Software Engineer',
            'sql'
        ),
        (
            'Riverstone Software',
            'Graduate Software Engineer',
            'python'
        ),
        (
            'Riverstone Software',
            'Graduate Software Engineer',
            'postgresql'
        ),
        (
            'Aurora Systems',
            'Software Engineer Trainee',
            'git'
        ),
        (
            'Aurora Systems',
            'Software Engineer Trainee',
            'data structures'
        )
) AS mapping (company_name, job_title, skill_name);

COMMIT;