/*Q6 — Verification Status Controlled for Grade
Compare charged-off rates across verification_status groups.
Then control for grade check whether verification status has additional explanatory power within the same grade bucket,
or whether grade absorbs the effect entirely.
Write up whether verification is independently useful or just correlated with loan size.*/

-- Step 1: Overall charge-off rate by verification_status


WITH base AS (
    SELECT
        verification_status,
        grade,
        CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END AS is_charged_off,
        loan_amount
    FROM happen
    WHERE verification_status IS NOT NULL
),
overall AS (
    SELECT
        verification_status,
        COUNT(*) AS total_loans,
        SUM(is_charged_off) AS charged_off_count,
        CAST(SUM(is_charged_off) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS chargeoff_rate_pct
    FROM base
    GROUP BY verification_status
),
by_grade AS (
    SELECT
        grade,
        verification_status,
        COUNT(*) AS total_loans,
        SUM(is_charged_off) AS charged_off_count,
        CAST(SUM(is_charged_off) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS chargeoff_rate_pct,
        AVG(loan_amount * 1.0) AS avg_loan_amount
    FROM base
    GROUP BY grade, verification_status
),
grade_baseline AS (
    SELECT
        grade,
        CAST(SUM(is_charged_off) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS grade_chargeoff_rate
    FROM base
    GROUP BY grade
)
-- Final output: verification effect within each grade
SELECT
    b.grade,
    b.verification_status,
    b.total_loans,
    b.charged_off_count,
    b.chargeoff_rate_pct,
    g.grade_chargeoff_rate,
    CAST(b.chargeoff_rate_pct - g.grade_chargeoff_rate AS DECIMAL(5,2)) AS diff_from_grade_baseline,
    b.avg_loan_amount
FROM by_grade b
JOIN grade_baseline g ON b.grade = g.grade
ORDER BY b.grade, b.chargeoff_rate_pct;