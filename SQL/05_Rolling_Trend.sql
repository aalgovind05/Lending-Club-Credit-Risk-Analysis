/*Q5 — Rolling Volume Trend + Month-over-Month Shift
Using issue_date, calculate monthly loan volume. 
Add two layers: (1) a 3-month rolling average using ROWS BETWEEN 2 PRECEDING AND CURRENT ROW, 
and (2) a month-over-month change using LAG(). 
Flag months where actual volume dropped more than 20% below the rolling average AND volume declined from the prior month — 
double confirmation of a contraction signal. 
Business context: this is the kind of alert that triggers an underwriting policy review meeting.*/