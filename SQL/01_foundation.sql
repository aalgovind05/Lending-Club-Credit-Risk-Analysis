/*Q1 — Portfolio Snapshot (Foundational)
Produce one summary row: total loans, total dollar volume, average interest rate. 
This is the number every data team keeps on a dashboard — the "state of the business" query.*/


SELECT COUNT(*) AS total_loans,
       SUM(loan_amount) AS total_dollar_volume,
       ROUND(AVG(interest_rate), 2) AS average_interest_rate
FROM happen

