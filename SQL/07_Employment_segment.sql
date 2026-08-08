/*Q7 — Employment Length Segmentation
Bucket employment_length into 4 groups + Unknown, compute default rate and avg loan_amount per bucket.
Default = any loan in Charged Off / Default / late statuses.
Insight: longer-employed borrowers may borrow more in absolute dollars, so even a lower
default rate can mean a higher dollar loss exposure.*/

WITH bucketed AS (
    SELECT
        CASE
            WHEN employment_length IS NULL OR employment_length = 'Unknown'        THEN 'Unknown'
            WHEN employment_length = '< 1 year' OR employment_length IN ('1 year','2 years')      THEN '0-2 years'
            WHEN employment_length IN ('3 years','4 years','5 years')                             THEN '3-5 years'
            WHEN employment_length IN ('6 years','7 years','8 years','9 years')                   THEN '6-9 years'
            WHEN employment_length = '10+ years'                                                  THEN '10+ years'
        END AS emp_bucket,
        loan_amount,
        CASE WHEN loan_status IN ('Charged Off','Default',
                                  'Late (16-30 days)','Late (31-120 days)',
                                  'Does not meet the credit policy. Status:Charged Off')
             THEN 1 ELSE 0 END AS is_default
    FROM happen
)
SELECT
    emp_bucket,
    COUNT(*)                                                        AS loan_count,
    ROUND(100.0 * SUM(is_default) / COUNT(*), 2)                    AS default_rate_pct,
    ROUND(AVG(loan_amount * 1.0), 0)                                AS avg_loan_amount,
    SUM(is_default)                                                 AS defaulted_loans,
    ROUND(SUM(is_default * loan_amount * 1.0), 0)                  AS est_loss_exposure,
    ROUND(SUM(CASE WHEN is_default = 1 THEN loan_amount END) * 1.0
        / NULLIF(SUM(is_default), 0), 0)                          AS avg_defaulted_loan_amount
FROM bucketed
WHERE emp_bucket IS NOT NULL
GROUP BY emp_bucket
ORDER BY
    CASE emp_bucket
        WHEN '0-2 years' THEN 1
        WHEN '3-5 years' THEN 2
        WHEN '6-9 years' THEN 3
        WHEN '10+ years' THEN 4
        WHEN 'Unknown'    THEN 5
    END;