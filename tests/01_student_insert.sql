-- Test: a valid student can be inserted.
-- Run sections A, B, and C in order, in the same database session.
-- The test student is removed by ROLLBACK.

-- A: Start a transaction and insert a valid student.
BEGIN;

INSERT INTO public.students (
    full_name,
    university_email,
    cgpa,
    graduation_year,
    active_backlogs
)
VALUES (
    'Test Student',
    'test.student@example.com',
    8.25,
    2027,
    0
)
RETURNING *;

-- B: Undo the insertion and end the transaction.
ROLLBACK;

-- C: Confirm the test student was not retained.
SELECT COUNT(*) AS remaining_test_students
FROM public.students
WHERE university_email = 'test.student@example.com';