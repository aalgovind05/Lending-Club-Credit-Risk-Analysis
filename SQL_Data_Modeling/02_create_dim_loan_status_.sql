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