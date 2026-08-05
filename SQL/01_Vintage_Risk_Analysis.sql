/*Q1 — Vintage Risk Analysis
Group loans by issue year (FROM issue_date) and grade. 
For each year-grade combination, calculate the charged-off rate. 
Then identify which vintage (year) shows the worst Grade A performance 
defined as the year WHERE Grade A's charged-off rate most exceeds the all-year Grade A average.
Use a CTE to compute the baseline Grade A average, 
then join back to the year-level rates to find the outlier.*/


WITH status_rates AS(
SELECT 
    YEAR(issue_date) AS issue_year,
    grade,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS charged_off_rate
FROM happen
WHERE grade = 'A'
GROUP BY YEAR(issue_date), grade
),

avg_charged_off_rate AS(
SELECT 
    issue_year,
    grade,
    charged_off_rate,
    (SELECT AVG(charged_off_rate) FROM status_rates) AS avg_charged_off_rate
FROM status_rates
)

SELECT TOP 1
    issue_year,
    grade,
    charged_off_rate AS highest_charged_off_rate,
    avg_charged_off_rate
FROM avg_charged_off_rate
WHERE charged_off_rate > avg_charged_off_rate
ORDER BY highest_charged_off_rate DESC


