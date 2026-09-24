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