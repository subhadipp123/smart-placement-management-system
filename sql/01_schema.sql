-- Smart Placement Management System
-- Database: smart_placement_db
-- This file builds the database tables.
-- Run each CREATE TABLE statement once when setting up the database.

CREATE TABLE public.companies (
    company_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    company_name VARCHAR(150) NOT NULL,

    website TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT companies_name_not_blank
        CHECK (TRIM(company_name) <> '')
);

-- Students: profile and academic information for placement eligibility.

CREATE TABLE public.students (
    student_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    full_name VARCHAR(150) NOT NULL,

    university_email VARCHAR(254) NOT NULL UNIQUE,

    cgpa NUMERIC(4, 2) NOT NULL,

    graduation_year INTEGER NOT NULL,

    active_backlogs INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT students_name_not_blank
        CHECK (TRIM(full_name) <> ''),

    CONSTRAINT students_email_not_blank
        CHECK (TRIM(university_email) <> ''),

    CONSTRAINT students_email_lowercase_trimmed
        CHECK (university_email = LOWER(TRIM(university_email))),

    CONSTRAINT students_cgpa_range
        CHECK (cgpa BETWEEN 0 AND 10),

    CONSTRAINT students_graduation_year_range
        CHECK (graduation_year BETWEEN 2000 AND 2100),

    CONSTRAINT students_backlogs_nonnegative
        CHECK (active_backlogs >= 0)
);

-- Skills: shared list used by student profiles and job requirements.

CREATE TABLE public.skills (
    skill_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    skill_name VARCHAR(100) NOT NULL UNIQUE,

    CONSTRAINT skills_name_not_blank
        CHECK (TRIM(skill_name) <> ''),

    CONSTRAINT skills_name_lowercase_trimmed
        CHECK (skill_name = LOWER(TRIM(skill_name)))
);

-- Jobs: openings posted by companies and their eligibility requirements.

CREATE TABLE public.jobs (
    job_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    company_id BIGINT NOT NULL,

    job_title VARCHAR(150) NOT NULL,

    min_cgpa NUMERIC(4, 2) NOT NULL,

    graduation_year INTEGER NOT NULL,

    allows_active_backlogs BOOLEAN NOT NULL,

    status VARCHAR(10) NOT NULL DEFAULT 'closed',

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT jobs_company_fk
        FOREIGN KEY (company_id)
        REFERENCES public.companies (company_id),

    CONSTRAINT jobs_title_not_blank
        CHECK (TRIM(job_title) <> ''),

    CONSTRAINT jobs_min_cgpa_range
        CHECK (min_cgpa BETWEEN 0 AND 10),

    CONSTRAINT jobs_graduation_year_range
        CHECK (graduation_year BETWEEN 2000 AND 2100),

    CONSTRAINT jobs_status_allowed
        CHECK (status IN ('open', 'closed'))
);

-- Student skills: connects students to the skills they have.

CREATE TABLE public.student_skills (
    student_id BIGINT NOT NULL,

    skill_id BIGINT NOT NULL,

    CONSTRAINT student_skills_pk
        PRIMARY KEY (student_id, skill_id),

    CONSTRAINT student_skills_student_fk
        FOREIGN KEY (student_id)
        REFERENCES public.students (student_id),

    CONSTRAINT student_skills_skill_fk
        FOREIGN KEY (skill_id)
        REFERENCES public.skills (skill_id)
);

-- Job required skills: connects jobs to their required skills.

CREATE TABLE public.job_required_skills (
    job_id BIGINT NOT NULL,

    skill_id BIGINT NOT NULL,

    CONSTRAINT job_required_skills_pk
        PRIMARY KEY (job_id, skill_id),

    CONSTRAINT job_required_skills_job_fk
        FOREIGN KEY (job_id)
        REFERENCES public.jobs (job_id),

    CONSTRAINT job_required_skills_skill_fk
        FOREIGN KEY (skill_id)
        REFERENCES public.skills (skill_id)
);

-- Applications: records students applying to jobs.

CREATE TABLE public.applications (
    application_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    student_id BIGINT NOT NULL,

    job_id BIGINT NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'submitted',

    applied_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT applications_student_job_unique
        UNIQUE (student_id, job_id),

    CONSTRAINT applications_student_fk
        FOREIGN KEY (student_id)
        REFERENCES public.students (student_id),

    CONSTRAINT applications_job_fk
        FOREIGN KEY (job_id)
        REFERENCES public.jobs (job_id),

    CONSTRAINT applications_status_allowed
        CHECK (
            status IN (
                'submitted',
                'shortlisted',
                'interviewing',
                'selected',
                'rejected',
                'withdrawn'
            )
        )
);

-- Interviews: individual rounds belonging to an application.

CREATE TABLE public.interviews (
    interview_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    application_id BIGINT NOT NULL,

    round_number INTEGER NOT NULL,

    round_name VARCHAR(100) NOT NULL,

    scheduled_at TIMESTAMPTZ NOT NULL,

    result VARCHAR(20) NOT NULL DEFAULT 'pending',

    feedback TEXT,

    CONSTRAINT interviews_application_round_unique
        UNIQUE (application_id, round_number),

    CONSTRAINT interviews_application_fk
        FOREIGN KEY (application_id)
        REFERENCES public.applications (application_id),

    CONSTRAINT interviews_round_number_positive
        CHECK (round_number > 0),

    CONSTRAINT interviews_round_name_not_blank
        CHECK (TRIM(round_name) <> ''),

    CONSTRAINT interviews_result_allowed
        CHECK (
            result IN (
                'pending',
                'passed',
                'failed',
                'absent',
                'cancelled'
            )
        )
);

-- Offers: offers made for applications and the student's response.
-- Compensation is recorded as annual CTC in Indian rupees.

CREATE TABLE public.offers (
    offer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    application_id BIGINT NOT NULL,

    annual_ctc_inr NUMERIC(12, 2) NOT NULL,

    status VARCHAR(10) NOT NULL DEFAULT 'pending',

    offered_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    responded_at TIMESTAMPTZ,

    CONSTRAINT offers_application_unique
        UNIQUE (application_id),

    CONSTRAINT offers_application_fk
        FOREIGN KEY (application_id)
        REFERENCES public.applications (application_id),

    CONSTRAINT offers_ctc_positive
        CHECK (
            annual_ctc_inr > 0
            AND annual_ctc_inr <> 'NaN'::NUMERIC
        ),

    CONSTRAINT offers_status_allowed
        CHECK (status IN ('pending', 'accepted', 'declined')),

    CONSTRAINT offers_response_consistent
        CHECK (
            (status = 'pending' AND responded_at IS NULL)
            OR
            (
                status IN ('accepted', 'declined')
                AND responded_at IS NOT NULL
                AND responded_at >= offered_at
            )
        )
);