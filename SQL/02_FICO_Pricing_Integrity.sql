/*Q2 — FICO Pricing Integrity
Create FICO bands using fico_range_low (580–619, 620–659, 660–699, 700–739, 740+). 
For each band, calculate charged-off rate AND average interest_rate. 
Find bands where interest rate does not justify risk
high rate but also high default. Flag these as mispriced segments.*/


WITH band AS(
SELECT *,
    CASE WHEN fico_range_low BETWEEN 580 AND 619 THEN '580-619'
         WHEN fico_range_low BETWEEN 620 AND 659 THEN '620-659'
         WHEN fico_range_low BETWEEN 660 AND 699 THEN '660-699'
         WHEN fico_range_low BETWEEN 700 AND 739 THEN '700-739'
         WHEN fico_range_low >= 740 THEN '740+'
    END AS fico_band
FROM happen
)
SELECT fico_band,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND((SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)), 2) AS charged_off_rate,
    CASE 
        WHEN AVG(interest_rate) > 15 AND SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) > 10 THEN 'Mispriced'
        ELSE 'Priced Correctly'
    END AS pricing_integrity
FROM band
GROUP BY fico_band
ORDER BY MIN(fico_range_low)