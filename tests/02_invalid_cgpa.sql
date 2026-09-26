-- Test: reject a student whose CGPA exceeds 10.
-- Run sections A, B, C, and D separately, in the same session.
-- Expected error in section B: students_cgpa_range.
-- Always run section C afterward to end the transaction.

-- A: Start the test transaction.
BEGIN;

-- B: Attempt to insert an invalid CGPA.
INSERT INTO public.students (
    full_name,
    university_email,
    cgpa,
    graduation_year,
    active_backlogs
)
VALUES (
    'Invalid CGPA Test',
    'invalid.cgpa@example.com',
    11.00,
    2027,
    0
);

-- C: End the transaction and undo any changes.
ROLLBACK;

-- D: Confirm that the test student was not retained.
SELECT COUNT(*) AS remaining_invalid_students
FROM public.students
WHERE university_email = 'invalid.cgpa@example.com';