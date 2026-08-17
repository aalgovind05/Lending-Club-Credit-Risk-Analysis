/*NOTE:

     Here i have just inserted only one column(loan_status) because it's only column 
that represent a situation of loan that here and this column is not well to combine in 
fact table or any other columns that why this column contain it's own weightage here for
as independent table */


CREATE TABLE dim_loan_status (
        status_key INT IDENTITY(1, 1) PRIMARY KEY,
        loan_status VARCHAR(20) NOT NULL
);

INSERT INTO dim_loan_status (loan_status)
SELECT 
    DISTINCT loan_status
FROM happen
ORDER BY loan_status;

SELECT * FROM dim_loan_status;


-- Add status key in main big table

ALTER TABLE happen ADD status_key INT;


UPDATE f
SET f.status_key = d.status_key
FROM happen f
JOIN dim_loan_status d
    ON f.loan_status = d.loan_status;


--Check status key in main table 

SELECT top(10)* FROM happen


-- Verify
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN status_key IS NULL THEN 1 ELSE 0 END) AS null_status_key
FROM happen;