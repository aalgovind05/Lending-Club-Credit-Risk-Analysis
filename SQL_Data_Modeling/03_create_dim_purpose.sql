CREATE TABLE dim_purpose (
    purpose_key  INT IDENTITY(1,1) PRIMARY KEY,
    purpose      VARCHAR(100) NOT NULL
);

INSERT INTO dim_purpose (purpose)
SELECT DISTINCT purpose
FROM happen
ORDER BY purpose;

SELECT * FROM dim_purpose

--adding purpose_key in happen (main) table

ALTER TABLE happen ADD purpose_key  INT;

UPDATE f
SET f.purpose_key = d.purpose_key
FROM happen f
JOIN dim_purpose d
    ON TRIM(f.purpose) = TRIM(d.purpose);


-- Check purpose key in happen table 

SELECT TOP(10)* FROM happen


-- Verify

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN purpose_key IS NULL THEN 1 ELSE 0 END) AS null_purpose_key
FROM happen;