--creating dim grade table 

CREATE TABLE dim_grade (
        grade_key INT IDENTITY(1,1) PRIMARY KEY,
        grade VARCHAR(5) NOT NULL,
        sub_grade VARCHAR(5) NOT NULL);


INSERT INTO dim_grade(grade, sub_grade)
SELECT 
    DISTINCT grade, 
    sub_grade
FROM happen
ORDER BY grade, sub_grade;


-- Check dim_grade table 

SELECT * FROM dim_grade;


-- Add grade_key into main table 

ALTER TABLE happen ADD grade_key    INT;

UPDATE f
SET  f.grade_key = d.grade_key
FROM happen f
JOIN dim_grade d
    ON f.grade     = d.grade
    AND f.sub_grade = d.sub_grade;


-- Check key in main table

SELECT top(10)* from happen


-- Verify

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN grade_key IS NULL THEN 1 ELSE 0 END) AS null_grade_key
FROM happen;
