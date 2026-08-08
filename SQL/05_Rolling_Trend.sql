/*Q5 — Rolling Volume Trend + Month-over-Month Shift
Using issue_date, calculate monthly loan volume.
Add two layers: (1) a 3-month rolling average using ROWS BETWEEN 2 PRECEDING AND CURRENT ROW,
and (2) a month-over-month change using LAG().
Flag months where actual volume dropped more than 20% below the rolling average AND volume declined from the prior month —
double confirmation of a contraction signal.
Business context: this is the kind of alert that triggers an underwriting policy review meeting.*/

WITH monthly_volume AS (
    SELECT
        DATEFROMPARTS(YEAR(issue_date), MONTH(issue_date), 1) AS issue_month,
        COUNT(*) AS loan_volume
    FROM happen
    GROUP BY DATEFROMPARTS(YEAR(issue_date), MONTH(issue_date), 1)
),
with_calculations AS (
    SELECT
        issue_month,
        loan_volume,
        AVG(loan_volume * 1.0) OVER (
            ORDER BY issue_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS rolling_3mo_avg,
        LAG(loan_volume) OVER (ORDER BY issue_month) AS prior_month_volume
    FROM monthly_volume
)
SELECT
    issue_month,
    loan_volume,
    ROUND(rolling_3mo_avg, 2) AS rolling_3mo_avg,
    prior_month_volume,
    CASE
        WHEN prior_month_volume IS NOT NULL
         AND loan_volume < rolling_3mo_avg * 0.8
         AND loan_volume < prior_month_volume
        THEN 'CONTRACTION SIGNAL'
        ELSE 'Normal'
    END AS alert_flag
FROM with_calculations
WHERE rolling_3mo_avg IS NOT NULL
ORDER BY issue_month;