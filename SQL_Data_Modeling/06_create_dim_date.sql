CREATE TABLE dim_date (
    date_key     INT          IDENTITY(1,1)  PRIMARY KEY,
    full_date    DATE         NOT NULL,
    year         INT          NOT NULL,
    quarter      VARCHAR(5)   NOT NULL,
    month_number INT          NOT NULL,
    month_name   VARCHAR(15)  NOT NULL,
    half_year    VARCHAR(5)   NOT NULL
);

INSERT INTO dim_date (
    full_date,
    year,
    quarter,
    month_number,
    month_name,
    half_year
)
SELECT DISTINCT
    issue_date AS full_date,
    YEAR(issue_date) AS year,
    'Q' + CAST(DATEPART(QUARTER, issue_date) AS VARCHAR(1)) AS quarter,
    MONTH(issue_date) AS month_number,
    DATENAME(MONTH, issue_date) AS month_name,
    CASE
        WHEN MONTH(issue_date) <= 6 THEN 'H1'
        ELSE 'H2'
    END AS half_year
FROM happen
ORDER BY issue_date;

--counting total dates

SELECT count(*) as lam from dim_date;


--verify date duplicates

SELECT full_date, COUNT(*) AS cnt
FROM dim_date
GROUP BY full_date
HAVING COUNT(*) > 1;

-- adding date key into main table

ALTER TABLE happen ADD date_key INT;

UPDATE f
SET    f.date_key = d.date_key
FROM   happen f
JOIN   dim_date d
    ON f.issue_date = d.full_date;

-- Check date key 


SELECT top(10)*  from happen

-- Verify immediately after each UPDATE
SELECT 
    COUNT(*)                                              AS total_rows,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END)    AS null_date_key
FROM happen;


