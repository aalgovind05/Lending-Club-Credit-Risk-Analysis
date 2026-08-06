/*Q3 — Revolving Utilization as Risk Predictor
Bucket revolving_utilization_rate into five ranges (0–20%, 20–40%, 40–60%, 60–80%, 80%+).
For each bucket, calculate bad-outcome rate and average win_dti.
The question is: within the same utilization bucket,
does DTI vary significantly? If high-utilization borrowers also have high DTI uniformly,
note this as a co-movement observation, not a statistical proof of collinearity.
Flag what additional analysis (correlation coefficient) would be needed to confirm.*/

WITH utilization_band AS (
    SELECT *,
   CASE 
        WHEN revolving_utilization_rate >= 0  AND revolving_utilization_rate < 20 THEN '0-20%'
        WHEN revolving_utilization_rate >= 20 AND revolving_utilization_rate < 40 THEN '20-40%'
        WHEN revolving_utilization_rate >= 40 AND revolving_utilization_rate < 60 THEN '40-60%'
        WHEN revolving_utilization_rate >= 60 AND revolving_utilization_rate < 80 THEN '60-80%'
        WHEN revolving_utilization_rate >= 80 THEN '80%+'
    END AS utilization_bucket
FROM happen
)
SELECT utilization_bucket,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(AVG(win_dti), 2) AS avg_win_dti,
    ROUND((SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS bad_outcome_rate,
    CASE 
        WHEN AVG(win_dti) > 19 AND SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 10 THEN 'Co-movement Observed'
        ELSE 'No Co-movement'
    END AS dti_utilization_relationship
FROM utilization_band
GROUP BY utilization_bucket
ORDER BY MIN(revolving_utilization_rate);

