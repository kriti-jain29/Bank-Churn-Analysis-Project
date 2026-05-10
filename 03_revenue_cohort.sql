-- Q18: Total Estimated Revenue at Risk from Churned Customers
SELECT
    COUNT(*)                                          AS total_churned_customers,
    ROUND(SUM(EstimatedSalary), 2)                    AS total_revenue_at_risk,
    ROUND(AVG(EstimatedSalary), 2)                    AS avg_revenue_per_churned_customer,
    ROUND(SUM(Balance), 2)                            AS total_deposits_lost
FROM customer_churn
WHERE Exited = 1;

-- Q19: Revenue at Risk by Country
SELECT
    Geography,
    COUNT(*)                                          AS churned_customers,
    ROUND(SUM(EstimatedSalary), 2)                    AS revenue_at_risk,
    ROUND(AVG(EstimatedSalary), 2)                    AS avg_revenue_per_customer,
    ROUND(SUM(Balance), 2)                            AS deposits_lost,
    ROUND(SUM(EstimatedSalary) * 100.0 / 
          SUM(SUM(EstimatedSalary)) OVER (), 2)        AS pct_of_total_revenue_lost
FROM customer_churn
WHERE Exited = 1
GROUP BY Geography
ORDER BY revenue_at_risk DESC;

-- Q20: Top 10 Highest-Value Churned Customers
 -- These are the customers the bank should have fought hardest to retain
 SELECT
    CustomerId,
    Surname,
    Geography,
    Age,
    ROUND(Balance, 2)                                 AS balance,
    ROUND(EstimatedSalary, 2)                         AS estimated_salary,
    NumOfProducts,
    Tenure,
    ROUND(Balance + EstimatedSalary, 2)               AS total_value_lost
FROM customer_churn
WHERE Exited = 1
ORDER BY total_value_lost DESC
LIMIT 10;

-- Q21: Average Revenue — Churned vs Retained Customers
  -- Side by side comparison: how different are churned vs retained customers?
SELECT
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Retained' END  AS customer_status,
    COUNT(*)                                                   AS total_customers,
    ROUND(AVG(EstimatedSalary), 2)                            AS avg_salary,
    ROUND(AVG(Balance), 2)                                    AS avg_balance,
    ROUND(AVG(CreditScore), 1)                                AS avg_credit_score,
    ROUND(AVG(Tenure), 1)                                     AS avg_tenure_years,
    ROUND(AVG(NumOfProducts), 2)                              AS avg_products_held
FROM customer_churn
GROUP BY Exited
ORDER BY Exited DESC;

-- Q22: High-Value vs Low-Value Churners using NTILE Cohorts
  -- Splits churned customers into 4 value tiers by balance, Q4 = highest value churners (biggest loss to the bank)
  WITH churned_customers AS (
    SELECT
        CustomerId,
        Geography,
        Age,
        Balance,
        EstimatedSalary,
        NumOfProducts,
        Tenure,
        NTILE(4) OVER (ORDER BY Balance)              AS value_tier
    FROM customer_churn
    WHERE Exited = 1
),
tier_labels AS (
    SELECT *,
        CASE value_tier
            WHEN 1 THEN 'Q1 - Low Value'
            WHEN 2 THEN 'Q2 - Mid-Low Value'
            WHEN 3 THEN 'Q3 - Mid-High Value'
            WHEN 4 THEN 'Q4 - High Value'
        END                                           AS tier_label
    FROM churned_customers
)
SELECT
    tier_label,
    COUNT(*)                                          AS churned_customers,
    ROUND(AVG(Balance), 2)                            AS avg_balance,
    ROUND(AVG(EstimatedSalary), 2)                    AS avg_salary,
    ROUND(SUM(Balance), 2)                            AS total_balance_lost,
    ROUND(AVG(Tenure), 1)                             AS avg_tenure_years,
    ROUND(AVG(NumOfProducts), 2)                      AS avg_products_held
FROM tier_labels
GROUP BY tier_label, value_tier
ORDER BY value_tier;

-- Q23: Biggest Revenue Loss by Country + Age Band
WITH segment_revenue AS (
    SELECT
        Geography,
        CASE
            WHEN Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN Age BETWEEN 31 AND 45 THEN '31-45'
            WHEN Age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '60+'
        END                                           AS age_band,
        COUNT(*)                                      AS churned_customers,
        ROUND(SUM(EstimatedSalary), 2)                AS revenue_at_risk,
        ROUND(SUM(Balance), 2)                        AS deposits_lost,
        ROUND(AVG(EstimatedSalary), 2)                AS avg_revenue_per_customer
    FROM customer_churn
    WHERE Exited = 1
    GROUP BY Geography, age_band
)
SELECT
    Geography,
    age_band,
    churned_customers,
    revenue_at_risk,
    deposits_lost,
    avg_revenue_per_customer,
    RANK() OVER (ORDER BY revenue_at_risk DESC)       AS revenue_loss_rank
FROM segment_revenue
ORDER BY revenue_at_risk DESC;

-- Q24: Revenue at Risk from Inactive Members Who Haven't Churned Yet
  -- These customers are still here but likely to leave soon
WITH future_risk AS (
    SELECT
        Geography,
        COUNT(*)                                      AS at_risk_customers,
        ROUND(SUM(EstimatedSalary), 2)                AS potential_revenue_at_risk,
        ROUND(SUM(Balance), 2)                        AS potential_deposits_at_risk,
        ROUND(AVG(CreditScore), 1)                    AS avg_credit_score
    FROM customer_churn
    WHERE IsActiveMember = 0
      AND Exited = 0           -- still a customer but inactive
    GROUP BY Geography
),
total_active_revenue AS (
    SELECT ROUND(SUM(EstimatedSalary), 2) AS total_revenue
    FROM customer_churn
    WHERE Exited = 0
)
SELECT
    f.Geography,
    f.at_risk_customers,
    f.potential_revenue_at_risk,
    f.potential_deposits_at_risk,
    f.avg_credit_score,
    ROUND(f.potential_revenue_at_risk * 100.0 / t.total_revenue, 2) AS pct_of_active_revenue_at_risk
FROM future_risk f
CROSS JOIN total_active_revenue t
ORDER BY potential_revenue_at_risk DESC;