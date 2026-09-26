-- Test: two students cannot have the same university email.
-- Run sections A, B, C, and D separately, in the same session.
-- Section A must succeed before testing section B.
-- Expected error in section B: students_university_email_key.
-- Always run section C afterward to end the transaction.

-- A: Start the transaction and insert the first student.
BEGIN;

INSERT INTO public.students (
    full_name,
    university_email,
    cgpa,
    graduation_year,
    active_backlogs
)
VALUES (
    'First Email Test Student',
    'duplicate.email@example.com',
    8.00,
    2027,
    0
)
RETURNING student_id, full_name, university_email;

-- B: Try inserting a different student with the same email.
INSERT INTO public.students (
    full_name,
    university_email,
    cgpa,
    graduation_year,
    active_backlogs
)
VALUES (
    'Second Email Test Student',
    'duplicate.email@example.com',
    9.00,
    2027,
    0
);

-- C: Undo the test transaction, including the first insertion.
ROLLBACK;

-- D: Confirm that neither test student remains.
SELECT COUNT(*) AS remaining_test_students
FROM public.students
WHERE university_email = 'duplicate.email@example.com';