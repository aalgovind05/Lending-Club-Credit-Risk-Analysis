/*Q2 — FICO Pricing Integrity
Create FICO bands using fico_range_low (580–619, 620–659, 660–699, 700–739, 740+). 
For each band, calculate charged-off rate AND average interest_rate. 
Find bands where interest rate does not justify risk
high rate but also high default. Flag these as mispriced segments.*/

select * from INFORMATION_SCHEMA.COLUMNS