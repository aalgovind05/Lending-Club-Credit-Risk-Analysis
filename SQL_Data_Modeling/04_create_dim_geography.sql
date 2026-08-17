CREATE TABLE dim_geography (
    state_key       INT IDENTITY(1,1) PRIMARY KEY,
    borrower_state  VARCHAR(5) NOT NULL
);

INSERT INTO dim_geography (borrower_state)
SELECT DISTINCT borrower_state
FROM happen
ORDER BY borrower_state;


SELECT * FROM dim_geography ;

-- Insert state_key into happen table

ALTER TABLE happen ADD state_key    INT;

UPDATE f
SET    f.state_key = d.state_key
FROM   happen f
JOIN   dim_geography d
    ON UPPER(f.borrower_state) = UPPER(d.borrower_state);


-- Check state_key in happen table

SELECT TOP(10) * FROM happen;

-- Verify
SELECT
    COUNT(*)                                              AS total_rows,
    SUM(CASE WHEN state_key IS NULL THEN 1 ELSE 0 END)   AS null_state_key
FROM happen;