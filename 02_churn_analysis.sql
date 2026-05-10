-- Q8: What is the overall churn rate and retention rate?
SELECT
    COUNT(*)                                              AS total_customers,
    SUM(Exited)                                           AS total_churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)             AS churn_rate_pct,
    ROUND((1 - SUM(Exited) / COUNT(*)) * 100.0, 2)       AS retention_rate_pct
FROM customer_churn;

-- Q9: Which country has the highest churn rate?
SELECT Geography,
    SUM(Exited)                                           AS total_churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)             AS churn_rate_pct
FROM customer_churn
GROUP BY Geography
ORDER BY churn_rate_pct DESC;

-- Q10: Which age band has the highest churn rate?
SELECT 
      CASE 
      WHEN Age BETWEEN 18 AND 30 THEN '18-30'
      WHEN Age BETWEEN 31 AND 45 THEN '31-45'
      WHEN Age BETWEEN 46 AND 60 THEN '46-60'
      ELSE '60+'
      END AS age_band,
COUNT(*)                                  AS total_customers,
SUM(Exited)                               AS total_churned,
ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)  AS churn_rate_pct
FROM customer_churn
GROUP BY age_band
ORDER BY MIN(age);

-- Q11: How does churn rate differ by gender within each country? (Cross Segment Analysis)
SELECT
    Geography,
    Gender,
    COUNT(*)                                         AS total_customers,
    SUM(Exited)                                      AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM customer_churn
GROUP BY Geography, Gender
ORDER BY Geography, churn_rate_pct DESC;
-- Q12: How does the number of products a customer holds affect churn rate?
SELECT
    NumOfProducts,
    COUNT(*)                                         AS total_customers,
    SUM(Exited)                                      AS churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM customer_churn
GROUP BY NumOfProducts
ORDER BY NumOfProducts;

-- Q13: Which geography + age band combinations have the highest churn rates? (CTE)
WITH Segment_summary AS
	 (SELECT 
	  Geography,
	  CASE 
	  WHEN Age BETWEEN 18 AND 30 THEN '18-30'
      WHEN Age BETWEEN 31 AND 45 THEN '31-45'
      WHEN Age BETWEEN 46 AND 60 THEN '46-60'
      ELSE '60+' 
      END AS age_band,
      COUNT(*) AS total_customers,
      SUM(exited) AS churned,
      ROUND(SUM(exited)*100.0/COUNT(*),2) AS churn_rate_pct
      FROM Customer_churn
      GROUP BY Geography, age_band
)
SELECT * 
FROM Segment_Summary
ORDER BY churn_rate_pct DESC
LIMIT 10;

-- Q14: Who are the highest-balance churned customers within each country? (RANK)
SELECT 
customerId,
Geography,
surname,
balance,
RANK() OVER(PARTITION BY geography ORDER BY balance DESC) AS balance_rank_in_country
FROM customer_churn
WHERE exited=1
ORDER BY geography,balance_rank_in_country
LIMIT 30;

-- Q15: How does churn rate vary across balance quartiles? (NTILE)
WITH risk_flags AS (
    SELECT
        CustomerId,
        Geography,
        Age,
        Balance,
        NumOfProducts,
        IsActiveMember,
        Exited,
        CASE
            WHEN IsActiveMember = 0 AND NumOfProducts > 1 THEN 'High Risk'
            WHEN IsActiveMember = 0 AND NumOfProducts = 1 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END                                          AS churn_risk_label
    FROM customer_churn
)
SELECT
    churn_risk_label,
    Geography,
    COUNT(*)                                         AS total_customers,
    SUM(Exited)                                      AS already_churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)        AS churn_rate_pct,
    ROUND(AVG(Balance), 2)                           AS avg_balance
FROM risk_flags
GROUP BY churn_risk_label, Geography
ORDER BY churn_rate_pct DESC;

-- Q16: How does churned customer count accumulate as tenure increases? (Running Total)
SELECT
    Tenure,
    COUNT(*)                                         AS total_customers,
    SUM(Exited)                                      AS churned_this_tenure,
    SUM(SUM(Exited)) OVER (
        ORDER BY Tenure
    )                                                AS cumulative_churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)        AS churn_rate_pct
FROM customer_churn
GROUP BY Tenure
ORDER BY Tenure;

-- Q17: Which customer segments are at highest risk of churning next? (Risk Flag CTE)
   -- Inactive + multi-product customers who haven't left YET
WITH risk_flags AS (
    SELECT
        CustomerId,
        Geography,
        Age,
        Balance,
        NumOfProducts,
        IsActiveMember,
        Exited,
        CASE
            WHEN IsActiveMember = 0 AND NumOfProducts > 1 THEN 'High Risk'
            WHEN IsActiveMember = 0 AND NumOfProducts = 1 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END                                          AS churn_risk_label
    FROM customer_churn
)
SELECT
    churn_risk_label,
    Geography,
    COUNT(*)                                         AS total_customers,
    SUM(Exited)                                      AS already_churned,
    ROUND(SUM(Exited) * 100.0 / COUNT(*), 2)        AS churn_rate_pct,
    ROUND(AVG(Balance), 2)                           AS avg_balance
FROM risk_flags
GROUP BY churn_risk_label, Geography
ORDER BY churn_rate_pct DESC;
