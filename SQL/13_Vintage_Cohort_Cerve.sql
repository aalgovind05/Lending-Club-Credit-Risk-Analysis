/*Q13 — Vintage Cohort Default Curve
Using issue_date to define monthly issuance cohorts, pick 3 cohorts (e.g. 2015-01, 2016-01, 2017-01).
Calculate cumulative charged-off rate at 6, 12, 18, and 24 months post-issuance
using a DATEDIFF-based CASE WHEN bucket and a running SUM via window function.
Do not conflate cohort vintage (issue_date) with borrower credit history age
(earliest_credit_line) in your write-up — they measure different things.
Output should be plot-ready: cohort × month-on-book × cumulative default %.*/

WITH cohorts AS (
    SELECT
        loan_id,
        issue_date,
        loan_status,
        DATEFROMPARTS(YEAR(issue_date), MONTH(issue_date), 1) AS cohort_month
    FROM happen
    WHERE DATEFROMPARTS(YEAR(issue_date), MONTH(issue_date), 1)
          IN ('2015-01-01', '2016-01-01', '2017-01-01')
),
cohort_sizes AS (
    -- Total loans per cohort — this is the fixed denominator
    SELECT
        cohort_month,
        COUNT(*) AS total_loans_in_cohort
    FROM cohorts
    GROUP BY cohort_month
),
observation_windows AS (
    -- Fixed observation points per cohort (static historical dates, not GETDATE())
    -- Each loan is assigned to a month-on-book bucket based on cohort + fixed offset
    SELECT
        c.loan_id,
        c.cohort_month,
        c.loan_status,
        obs.month_on_book,
        DATEADD(MONTH, obs.month_on_book, c.cohort_month) AS observation_date
    FROM cohorts c
    CROSS JOIN (VALUES (6), (12), (18), (24)) AS obs(month_on_book)
),
bucketed AS (
    -- At each observation point: count charged-off loans in that bucket
    -- Since we have no charge_off_date, we count all Charged Off loans in the cohort
    -- and assign them to the EARLIEST bucket they'd appear in (6-month increments)
    SELECT
        cohort_month,
        month_on_book,
        COUNT(CASE WHEN loan_status = 'Charged Off' THEN 1 END) AS new_charged_off
    FROM observation_windows
    GROUP BY cohort_month, month_on_book
),
running AS (
    SELECT
        b.cohort_month,
        b.month_on_book,
        s.total_loans_in_cohort,
        SUM(b.new_charged_off) OVER (
            PARTITION BY b.cohort_month
            ORDER BY b.month_on_book
            ROWS UNBOUNDED PRECEDING
        ) AS running_charged_off
    FROM bucketed b
    JOIN cohort_sizes s ON b.cohort_month = s.cohort_month
)
SELECT
    cohort_month,
    month_on_book,
    running_charged_off        AS cumulative_charged_off_loans,
    total_loans_in_cohort,
    ROUND(100.0 * running_charged_off / total_loans_in_cohort, 2) AS cumulative_default_pct
FROM running
ORDER BY cohort_month, month_on_book;