-- Summarize offer outcomes and accepted annual CTC.
-- Acceptance percentage uses all issued offers as its denominator.
-- Package statistics describe accepted offers, not distinct students.
-- Package values are displayed in lakhs per annum (LPA).

SELECT
    COUNT(*) AS total_offers,

    COUNT(*) FILTER (
        WHERE status = 'pending'
    ) AS pending_offers,

    COUNT(*) FILTER (
        WHERE status = 'accepted'
    ) AS accepted_offers,

    COUNT(*) FILTER (
        WHERE status = 'declined'
    ) AS declined_offers,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE status = 'accepted'
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS accepted_percentage_of_all_offers,

    ROUND(
        (
            MIN(annual_ctc_inr) FILTER (
                WHERE status = 'accepted'
            )
        ) / 100000.0,
        2
    ) AS lowest_accepted_ctc_lpa,

    ROUND(
        (
            AVG(annual_ctc_inr) FILTER (
                WHERE status = 'accepted'
            )
        ) / 100000.0,
        2
    ) AS average_accepted_ctc_lpa,

    ROUND(
        (
            MAX(annual_ctc_inr) FILTER (
                WHERE status = 'accepted'
            )
        ) / 100000.0,
        2
    ) AS highest_accepted_ctc_lpa

FROM public.offers;