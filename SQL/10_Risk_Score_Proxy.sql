/*Q10 — Risk Score Proxy with Full Validation
Build a composite risk score (0–4) from fico_range_low, debt_to_income_ratio,
revolving_utilization_rate, and grade.
Validate three ways: (1) default rate must decrease monotonically as score rises,
(2) lift vs portfolio average per score bucket, (3) confusion matrix at cutoff = 2
showing true/false positive rates — the underwriting approval-tradeoff.*/

WITH scored AS (
    SELECT
        loan_amount,
        CASE WHEN loan_status IN ('Charged Off','Default',
                                  'Late (16-30 days)','Late (31-120 days)',
                                  'Does not meet the credit policy. Status:Charged Off')
             THEN 1 ELSE 0 END AS is_default,
        CASE
            WHEN fico_range_low < 640 THEN 1 ELSE 0
        END
      + CASE WHEN debt_to_income_ratio > 25 THEN 1 ELSE 0 END
      + CASE WHEN revolving_utilization_rate > 70 THEN 1 ELSE 0 END
      + CASE WHEN grade IN ('E','F','G') THEN 1 ELSE 0 END
    AS risk_score
    FROM happen
    WHERE fico_range_low IS NOT NULL
      AND debt_to_income_ratio IS NOT NULL
      AND revolving_utilization_rate IS NOT NULL
      AND grade IS NOT NULL
),
per_score AS (
    SELECT
        risk_score,
        COUNT(*) AS loan_count,
        ROUND(100.0 * SUM(is_default) / COUNT(*), 2) AS default_rate_pct,
        SUM(is_default * loan_amount) AS default_dollars,
        SUM(loan_amount) AS total_dollars
    FROM scored
    GROUP BY risk_score
),
portfolio AS (
    SELECT
        100.0 * SUM(is_default) / COUNT(*) AS portfolio_default_rate
    FROM scored
),
matrix AS (
    SELECT
        SUM(CASE WHEN risk_score >= 2 AND is_default = 1 THEN 1 ELSE 0 END) AS tp,
        SUM(CASE WHEN risk_score >= 2 AND is_default = 0 THEN 1 ELSE 0 END) AS fp,
        SUM(CASE WHEN is_default = 1 THEN 1 ELSE 0 END) AS actual_defaults,
        SUM(CASE WHEN is_default = 0 THEN 1 ELSE 0 END) AS actual_non_defaults
    FROM scored
)
SELECT
    p.risk_score,
    p.loan_count,
    p.default_rate_pct,
    ROUND(p.default_dollars, 0) AS default_dollars,
    ROUND(p.total_dollars, 0) AS total_dollars,
    ROUND(p.default_rate_pct / pf.portfolio_default_rate, 2) AS lift_vs_portfolio,
    ROUND(100.0 * m.tp / m.actual_defaults, 2) AS true_positive_rate_pct,
    ROUND(100.0 * m.fp / m.actual_non_defaults, 2) AS false_positive_rate_pct,
    CASE
        WHEN p.default_rate_pct >
             LAG(p.default_rate_pct) OVER (ORDER BY p.risk_score)
        THEN 'NON-MONOTONIC'
        ELSE 'OK'
    END AS monotonicity_check
FROM per_score p
CROSS JOIN portfolio pf
CROSS JOIN matrix m
ORDER BY p.risk_score;

