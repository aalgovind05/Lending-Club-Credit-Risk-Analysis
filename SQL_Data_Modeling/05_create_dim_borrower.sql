CREATE TABLE dim_borrower (
    borrower_key        INT IDENTITY(1,1) PRIMARY KEY,
    employment_length   VARCHAR(20),
    home_ownership      VARCHAR(20),
    verification_status VARCHAR(50)
);

INSERT INTO dim_borrower (employment_length, home_ownership, verification_status)
SELECT 
    DISTINCT employment_length, 
    home_ownership, 
    verification_status
FROM happen
ORDER BY employment_length, home_ownership, verification_status;


SELECT * FROM dim_borrower;

-- Add borrower_key into happen (main) table

ALTER TABLE happen ADD borrower_key INT;



UPDATE f
SET    f.borrower_key = d.borrower_key
FROM   happen f
JOIN   dim_borrower d
    ON  ISNULL(f.employment_length, 'Unknown') 
      = ISNULL(d.employment_length, 'Unknown')
    AND ISNULL(f.home_ownership, 'Unknown') 
      = ISNULL(d.home_ownership, 'Unknown')
    AND ISNULL(f.verification_status, 'Unknown') 
      = ISNULL(d.verification_status, 'Unknown');


-- Check happen table for borrower_key presence

SELECT TOP(10)* FROM happen

-- Verify
SELECT
    COUNT(*)                                                AS total_rows,
    SUM(CASE WHEN borrower_key IS NULL THEN 1 ELSE 0 END)  AS null_borrower_key
FROM happen;
