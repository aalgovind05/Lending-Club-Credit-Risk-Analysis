/*Q1 — Vintage Risk Analysis
Group loans by issue year (from issue_date) and grade. 
For each year-grade combination, calculate the charged-off rate. 
Then identify which vintage (year) shows the worst Grade A performance 
defined as the year where Grade A's charged-off rate most exceeds the all-year Grade A average.
Use a CTE to compute the baseline Grade A average, 
then join back to the year-level rates to find the outlier.*/

SELECT 
    YEAR(issue_date) AS issue_year,
    grade,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS charged_off_rate
FROM happen
WHERE grade = 'A'
GROUP BY YEAR(issue_date), grade