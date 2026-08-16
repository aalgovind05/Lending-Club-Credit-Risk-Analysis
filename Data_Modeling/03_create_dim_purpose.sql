CREATE TABLE dim_purpose (
    purpose_key  INT IDENTITY(1,1) PRIMARY KEY,
    purpose      VARCHAR(100) NOT NULL
);

INSERT INTO dim_purpose (purpose)
SELECT DISTINCT purpose
FROM happen
ORDER BY purpose;

SELECT * FROM dim_purpose