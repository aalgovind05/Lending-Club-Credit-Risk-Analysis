/*Q4 — Sub-Grade Underperformers via Self-Join
Using grade and sub_grade, 
find all sub-grades where the charged-off rate exceeds the parent grade's average charged-off rate.
Use a CTE to compute grade-level rates, then join back to sub-grade level. 
Example: if Grade B overall is 15%, find every B1–B5 that exceeds 15%.*/

WITH grade_rates AS (
    SELECT grade,
        ROUND((SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)), 2) AS grade_charged_off_rate
    FROM happen
    GROUP BY grade
)
SELECT h.grade,
    h.sub_grade,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN h.loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_loans,
    ROUND((SUM(CASE WHEN h.loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)), 2) AS sub_grade_charged_off_rate,
    gr.grade_charged_off_rate
FROM happen h
JOIN grade_rates gr ON h.grade = gr.grade
GROUP BY h.grade, h.sub_grade, gr.grade_charged_off_rate
HAVING (SUM(CASE WHEN h.loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) > gr.grade_charged_off_rate
ORDER BY h.grade, h.sub_grade;