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
charged_off_analysis AS (
    SELECT
        'Top Decile (10)' AS segment,
        COUNT(*) AS loan_count,
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_count,
        ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS charged_off_rate_pct,
        ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
        1 AS sort_order,
        NULL AS overrepresentation_ratio
    FROM top_decile
    UNION ALL
    SELECT
        'Rest of Portfolio (Deciles 1-9)' AS segment,
        COUNT(*) AS loan_count,
        SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_count,
        ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / COUNT(*), 2) AS charged_off_rate_pct,
        ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
        2 AS sort_order,
        NULL AS overrepresentation_ratio
    FROM rest_portfolio
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
),
grade_overrepresentation AS (
    SELECT
        g.grade AS segment,
        CAST(g.portfolio_share * 100 AS DECIMAL(10,2)) AS loan_count,
        CAST(t.top_decile_share * 100 AS DECIMAL(10,2)) AS charged_off_count,
        ROUND(t.top_decile_share / g.portfolio_share, 2) AS charged_off_rate_pct,
        NULL AS avg_loan_amount,
        4 AS sort_order,
        ROUND(t.top_decile_share / g.portfolio_share, 2) AS overrepresentation_ratio
    FROM grade_distribution g
    JOIN top_decile_grades t ON g.grade = t.grade
    WHERE t.top_decile_share > g.portfolio_share
)
SELECT
    segment,
    loan_count,
    charged_off_count,
    charged_off_rate_pct,
    avg_loan_amount,
    sort_order,
    overrepresentation_ratio
FROM charged_off_analysis
UNION ALL
SELECT
    '--- GRADE OVERREPRESENTATION IN TOP DECILE ---',
    NULL, NULL, NULL, NULL,
    3, NULL
UNION ALL
SELECT
    segment,
    loan_count,
    charged_off_count,
    charged_off_rate_pct,
    avg_loan_amount,
    sort_order,
    overrepresentation_ratio
FROM grade_overrepresentation
ORDER BY sort_order, overrepresentation_ratio DESC;