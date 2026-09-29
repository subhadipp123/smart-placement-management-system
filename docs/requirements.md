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

## Application status transitions

- New applications start as submitted.
- submitted can change to shortlisted, rejected, or withdrawn.
- shortlisted can change to interviewing, rejected, or withdrawn.
- interviewing can change to selected, rejected, or withdrawn.
- selected, rejected, and withdrawn are terminal application statuses.
- Repeating the current status is rejected.
- Reopening a terminal application is outside the project scope.
- selected means successful selection, not offer acceptance.
- Offer responses are managed separately in the offers table.

## Interview scheduling

- Interviews are scheduled through the scheduling function.
- The application must exist and currently be interviewing.
- Round numbers must be positive and unique within an application.
- Round numbers do not have to be consecutive.
- Each interview needs a nonblank round name and a scheduled timestamp.
- New interviews start with result pending.
- Historical scheduled timestamps are allowed for recorded and sample data.

## Interview results

- Results are recorded through the interview-result function.
- The application must currently be interviewing.
- A pending round can become passed, failed, absent, or cancelled.
- A completed round cannot be overwritten through this function.
- Feedback is optional.
- Recording a result does not automatically change application status.
- Result corrections and real-time scheduling checks are outside
  the current project scope.

  ## Selection requirements

- Selection is allowed only from the interviewing status.
- The application must have at least one interview round.
- Every recorded interview round must have result passed.
- A pending, failed, absent, or cancelled round blocks selection.
- Passing all recorded rounds permits selection but does not
  automatically select the application.

  ## Offer creation

- Offers are created through the offer-creation function.
- The application must currently be selected.
- Each application can have at most one offer.
- New offers start as pending, with no response timestamp.
- Annual CTC is recorded in Indian rupees.
- Internship-role sample offers represent full-time conversion
  packages; internship stipends are outside the current schema.
- Receiving an offer does not count as placement until it is accepted.

## Offer responses

- Offer responses are recorded through the response function.
- Only pending offers can be accepted or declined.
- A response timestamp is required and cannot precede the offer timestamp.
- Accepted and declined responses cannot be overwritten through this function.
- Responding to an offer does not change the application's selected status.
- A student is placed when they have at least one accepted offer.
- Multiple accepted offers still count as one placed student.