/*Q4 — Sub-Grade Underperformers via Self-Join
Using grade and sub_grade, 
find all sub-grades where the charged-off rate exceeds the parent grade's average charged-off rate.
Use a CTE to compute grade-level rates, then join back to sub-grade level. 
Example: if Grade B overall is 15%, find every B1–B5 that exceeds 15%.*/