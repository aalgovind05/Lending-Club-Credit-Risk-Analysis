-- Add index to fast excution
CREATE INDEX idx_happen_loan_id
ON happen(loan_id)


-- Adding issue_date into fact_loan table
ALTER TABLE fact_loan 
ADD issue_date DATE;


-- insert date column in main fact table from happen(denormlized) table
UPDATE f
SET f.issue_date = s.issue_date
FROM fact_loan f
JOIN happen s
    ON f.loan_id = s.loan_id;

--Quick Check 
SELECT TOP(10)* FROM fact_loan

