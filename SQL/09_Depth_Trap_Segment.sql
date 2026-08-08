/*Q9 — Debt Trap Segmentation
Define "debt trap" profile: debt_to_income_ratio > 25, revolving_utilization_rate > 70%,
loan_status = Charged Off.
Find what share of total charged-off dollars this profile represents, overall and by purpose.
Insight: high DTI + maxed-out revolving credit + already charged off = the segment that
drains the most dollars per loan. Credit policy teams use this to tighten underwriting
on the worst-offending purposes.*/

WITH trap AS (
    SELECT
        purpose,
        loan_amount,
        CASE WHEN debt_to_income_ratio > 25
              AND revolving_utilization_rate > 70
              AND loan_status = 'Charged Off'
             THEN 1 ELSE 0 END AS is_trap
    FROM happen
    WHERE loan_status = 'Charged Off'
),
by_purpose AS (
    SELECT
        purpose,
        COUNT(*) AS trap_loans,
SUM(is_trap * loan_amount) AS trap_dollars,
SUM(loan_amount) AS total_dollars
    FROM trap
    GROUP BY purpose
)
SELECT
    purpose,
    trap_loans,
    ROUND(trap_dollars, 0) AS trap_dollars,
ROUND(total_dollars, 0) AS total_dollars,
ROUND(100.0 * trap_dollars / total_dollars, 2) AS trap_share_pct
FROM by_purpose
WHERE total_dollars > 0
ORDER BY trap_share_pct DESC, trap_dollars DESC;