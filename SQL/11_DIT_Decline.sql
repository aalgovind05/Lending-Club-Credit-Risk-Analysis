/*Q11 — DTI Decile Concentration
Use NTILE(10) on win_dti to bucket borrowers into deciles. For the top decile: calculate charged-off rate vs.
the rest of the portfolio, and average loan_amount.
Then find which grades are overrepresented in the top decile relative to their overall portfolio share.*/

WITH dti_deciles AS (
    SELECT
        *,
        NTILE(10) OVER (ORDER BY win_dti) AS dti_decile
    FROM happen
    WHERE win_dti IS NOT NULL
      AND grade IS NOT NULL
      AND loan_status IS NOT NULL
      AND loan_amount IS NOT NULL
),
top_decile AS (
    SELECT *
    FROM dti_deciles
    WHERE dti_decile = 10
),
rest_portfolio AS (
    SELECT *
    FROM dti_deciles
    WHERE dti_decile < 10
),
grade_distribution AS (
    SELECT
        grade,
        COUNT(*) * 1.0 / SUM(COUNT(*)) OVER () AS portfolio_share
    FROM dti_deciles
    GROUP BY grade
),
top_decile_grades AS (
    SELECT
        grade,
        COUNT(*) * 1.0 / SUM(COUNT(*)) OVER () AS top_decile_share
    FROM top_decile
    GROUP BY grade
)

-- PART 1: Charged-off rate & avg loan amount for top decile vs rest
SELECT
    'PART 1: Charged-off Rate & Avg Loan Amount' AS result_part,
    segment,
    metric_1_name,
    metric_1,
    metric_2_name,
    metric_2,
    metric_3_name,
    metric_3,
    metric_4_name,
    metric_4,
    sort_order
FROM (
    SELECT
        'Top Decile (10)'                          AS segment,
        'loan_count'                               AS metric_1_name,
        COUNT(*)                                   AS metric_1,
        'charged_off_count'                        AS metric_2_name,
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS metric_2,
        'charged_off_rate_pct'                     AS metric_3_name,
        ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS metric_3,
        'avg_loan_amount'                          AS metric_4_name,
        ROUND(AVG(loan_amount), 2)                 AS metric_4,
        1 AS sort_order
    FROM top_decile

    UNION ALL

    SELECT
        'Rest of Portfolio (Deciles 1-9)'          AS segment,
        'loan_count'                               AS metric_1_name,
        COUNT(*)                                   AS metric_1,
        'charged_off_count'                        AS metric_2_name,
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS metric_2,
        'charged_off_rate_pct'                     AS metric_3_name,
        ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS metric_3,
        'avg_loan_amount'                          AS metric_4_name,
        ROUND(AVG(loan_amount), 2)                 AS metric_4,
        2 AS sort_order
    FROM rest_portfolio
) p1

UNION ALL

-- PART 2: Grade overrepresentation in top DTI decile
-- Inner join is intentional: only grades present in BOTH overall portfolio AND top decile can be compared.
-- Grades missing from top_decile_grades have 0 share there and are excluded by design.
SELECT
    'PART 2: Grade Overrepresentation in Top Decile' AS result_part,
    segment,
    metric_1_name,
    metric_1,
    metric_2_name,
    metric_2,
    metric_3_name,
    metric_3,
    metric_4_name,
    metric_4,
    sort_order
FROM (
    SELECT
        g.grade                                    AS segment,
        'portfolio_share_pct'                      AS metric_1_name,
        ROUND(g.portfolio_share * 100, 2)          AS metric_1,
        'top_decile_share_pct'                     AS metric_2_name,
        ROUND(t.top_decile_share * 100, 2)         AS metric_2,
        'overrepresentation_ratio'                 AS metric_3_name,
        ROUND(t.top_decile_share / g.portfolio_share, 2) AS metric_3,
        NULL                                       AS metric_4_name,
        NULL                                       AS metric_4,
        4 AS sort_order
    FROM grade_distribution g
    JOIN top_decile_grades t ON g.grade = t.grade
    WHERE t.top_decile_share > g.portfolio_share
) p2

ORDER BY sort_order, metric_3 DESC;