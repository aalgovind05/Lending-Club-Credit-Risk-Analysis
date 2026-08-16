-- Add FK columns to your existing flat table
ALTER TABLE lending_club_loans ADD grade_key     INT;
ALTER TABLE lending_club_loans ADD status_key    INT;
ALTER TABLE lending_club_loans ADD purpose_key   INT;
ALTER TABLE lending_club_loans ADD state_key     INT;
ALTER TABLE lending_club_loans ADD borrower_key  INT;

-- Then UPDATE each FK by joining to dimension tables
UPDATE f
SET f.grade_key = d.grade_key
FROM happen f
JOIN dim_grade d 
    ON f.grade = d.grade 
    AND f.sub_grade = d.sub_grade;

UPDATE f
SET f.status_key = d.status_key
FROM lending_club_loans f
JOIN dim_loan_status d ON f.loan_status = d.loan_status;

-- repeat for purpose_key, state_key, borrower_key