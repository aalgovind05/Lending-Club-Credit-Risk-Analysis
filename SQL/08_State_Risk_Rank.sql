/*Q8 — Dollar-Weighted State Risk with Rank Divergence
Rank states by count-based default rate, then by dollar-weighted default rate.
States where the two ranks diverge by more than 10 positions look safe by loan count
but are high-exposure by dollar — that's where policy review pays off.*/

WITH base AS (
    SELECT
        borrower_state,
        loan_amount,
        CASE WHEN loan_status IN ('Charged Off','Default',
                                  'Late (16-30 days)','Late (31-120 days)',
                                  'Does not meet the credit policy. Status:Charged Off')
             THEN 1 ELSE 0 END AS is_default
    FROM happen
    WHERE borrower_state IS NOT NULL
),
ranked AS (
    SELECT
        borrower_state,
        COUNT(*)  AS loan_count,
        ROUND(100.0 * SUM(is_default) / COUNT(*), 2) AS default_rate_pct,
        ROUND(SUM(is_default * loan_amount), 0) AS default_dollars,
        ROUND(SUM(loan_amount), 0) AS total_dollars,
        RANK() OVER (ORDER BY 100.0 * SUM(is_default) / COUNT(*) DESC) AS count_rank,
        RANK() OVER (ORDER BY SUM(is_default * loan_amount) * 1.0
        / SUM(loan_amount) DESC) AS dollar_rank
    FROM base
    GROUP BY borrower_state
)
SELECT
    borrower_state,
    loan_count,
    default_rate_pct,
    default_dollars,
    total_dollars,
    count_rank,
    dollar_rank,
    (count_rank - dollar_rank) AS rank_divergence,
    CASE
        WHEN ABS(count_rank - dollar_rank) > 10 THEN 'REVIEW'
        ELSE 'Normal'
    END AS review_flag
FROM ranked
WHERE loan_count >= 100
ORDER BY ABS(count_rank - dollar_rank) DESC,
         default_rate_pct DESC;