CREATE TABLE dim_grade (
        grade_key INT IDENTITY(1,1) PRIMARY KEY,
        grade VARCHAR(5) NOT NULL,
        sub_grade VARCHAR(5) NOT NULL);


INSERT INTO dim_grade(grade, sub_grade)
SELECT DISTINCT grade, 
    sub_grade
FROM happen
ORDER BY grade, sub_grade;

SELECT * FROM dim_grade;