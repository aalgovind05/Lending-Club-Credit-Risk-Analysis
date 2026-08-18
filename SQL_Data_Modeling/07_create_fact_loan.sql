
-- STEP 1: Create fact_loan structure
 ALTER TABLE fact_loan
 ALTER COLUMN loan_id INT;
CREATE TABLE fact_loan (

    loan_id INT  NOT NULL,

    date_key INT NOT NULL,
    grade_key INT NOT NULL,
    status_key INT NOT NULL,
    purpose_key INT NOT NULL,
    state_key INT NOT NULL,
    borrower_key INT NOT NULL,

    loan_amount FLOAT,
    installment FLOAT,
    revolving_balance FLOAT,
    open_accounts INT,
    public_derogatory_records INT,
    total_accounts INT,

    term_months INT,
    interest_rate FLOAT,
    revolving_utilization_rate FLOAT,

    annual_income  FLOAT,
    win_annual_inc FLOAT,

    debt_to_income_ratio FLOAT,
    win_dti FLOAT,

    fico_range_low INT,
    fico_range_high INT,


    earliest_credit_line DATE,

    -- Primary Key
    CONSTRAINT PK_fact_loan PRIMARY KEY (loan_id)
);


-- STEP 2: Load fact_loan from source table

INSERT INTO fact_loan (
    loan_id,
    date_key,
    grade_key,
    status_key,
    purpose_key,
    state_key,
    borrower_key,
    loan_amount,
    installment,
    revolving_balance,
    open_accounts,
    public_derogatory_records,
    total_accounts,
    term_months,
    interest_rate,
    revolving_utilization_rate,
    annual_income,
    win_annual_inc,
    debt_to_income_ratio,
    win_dti,
    fico_range_low,
    fico_range_high,
    earliest_credit_line
)
SELECT
    loan_id,
    date_key,
    grade_key,
    status_key,
    purpose_key,
    state_key,
    borrower_key,
    loan_amount,
    installment,
    revolving_balance,
    open_accounts,
    public_derogatory_records,
    total_accounts,
    term_months,
    interest_rate,
    revolving_utilization_rate,
    annual_income,
    win_annual_inc,
    debt_to_income_ratio,
    win_dti,
    fico_range_low,
    fico_range_high,
    earliest_credit_line
FROM happen;


-- Quick view
SELECT TOP(10) * FROM fact_loan


-- Fact table final Duplicates verification
SELECT COUNT(loan_id) as DN ,
        loan_id  
FROM fact_loan 
GROUP BY loan_id
HAVING COUNT(loan_id) > 1


-- Column type confirmation
SP_HELP 'fact_loan';