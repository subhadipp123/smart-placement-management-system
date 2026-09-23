# Smart Placement Management System — Requirements

## Goal
Track campus job openings, student applications, interview rounds, offers, and placement results using a PostgreSQL database.

## Core rules
1. Each student has one unique student ID and university email.
2. Each company can post multiple jobs.
3. Each job specifies a minimum CGPA, graduation year, whether active
   backlogs are allowed, and any required skills.
4. A student is eligible for a job only when they meet every stated
   requirement for that job.
5. A student can apply to the same job only once.
6. One application can have multiple interview rounds.
7. An offer belongs to a particular application.
8. A student can receive offers from more than one company.

## Questions the database must answer
- Which students are eligible for a given job?
- Which jobs is a given student eligible for?
- Which students applied to a given job?
- What was each applicant's latest interview result?
- Which students received multiple offers?
- How many students were placed in a graduating batch?