/*Q12 — Data Quality Audit
Write a data quality validation script checking:
(1) duplicate loan_id,
(2) interest_rate outside a plausible range (below 1% or above 40%),
(3) fico_range_low/fico_range_high outside 300–850,
(4) win_dti values above 100 (likely data entry errors),
(5) issue_date in the future relative to the dataset period.
Return a summary — one row per check, count of violations.
Structure as a multi-CTE pipeline where each CTE handles one check and the final SELECT unions them.
*/

WITH dataset_bounds AS (
    -- Get the max issue_date in the dataset to define "future"
    SELECT MAX(issue_date) AS max_issue_date FROM happen
),
check_duplicate_loan_id AS (
    SELECT 'Duplicate loan_id' AS check_name,
           COUNT(*) AS violation_count
    FROM (
        SELECT loan_id, COUNT(*) AS cnt
        FROM happen
        GROUP BY loan_id
        HAVING COUNT(*) > 1
    ) dup
),
check_interest_rate_range AS (
    SELECT 'Interest rate outside 1-40%' AS check_name,
           COUNT(*) AS violation_count
    FROM happen
    WHERE interest_rate < 1 OR interest_rate > 40
),
check_fico_range AS (
    SELECT 'FICO range outside 300-850' AS check_name,
           COUNT(*) AS violation_count
    FROM happen
    WHERE fico_range_low < 300
       OR fico_range_low > 850
       OR fico_range_high < 300
       OR fico_range_high > 850
),
check_win_dti_high AS (
    SELECT 'win_dti above 100' AS check_name,
           COUNT(*) AS violation_count
    FROM happen
    WHERE win_dti > 100
),
check_future_issue_date AS (
    SELECT 'issue_date in future (beyond dataset max)' AS check_name,
           COUNT(*) AS violation_count
    FROM happen, dataset_bounds
    WHERE issue_date > max_issue_date
)
SELECT check_name, violation_count FROM check_duplicate_loan_id
UNION ALL
SELECT check_name, violation_count FROM check_interest_rate_range
UNION ALL
SELECT check_name, violation_count FROM check_fico_range
UNION ALL
SELECT check_name, violation_count FROM check_win_dti_high
UNION ALL
SELECT check_name, violation_count FROM check_future_issue_date
ORDER BY violation_count DESC