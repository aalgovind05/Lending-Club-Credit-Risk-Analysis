CREATE TABLE dim_geography (
    state_key       INT IDENTITY(1,1) PRIMARY KEY,
    borrower_state  VARCHAR(5) NOT NULL
);

INSERT INTO dim_geography (borrower_state)
SELECT DISTINCT borrower_state
FROM happen
ORDER BY borrower_state;


SELECT * FROM dim_geography ;