CREATE TABLE dim_borrower (
    borrower_key        INT IDENTITY(1,1) PRIMARY KEY,
    employment_length   VARCHAR(20),
    home_ownership      VARCHAR(20),
    verification_status VARCHAR(50)
);

INSERT INTO dim_borrower (employment_length, home_ownership, verification_status)
SELECT DISTINCT employment_length, home_ownership, verification_status
FROM happen
ORDER BY employment_length, home_ownership, verification_status;

SELECT * FROM dim_borrower;
SELECT top(1) * FROM happen;