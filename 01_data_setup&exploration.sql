CREATE DATABASE bank_churn_db;
USE bank_churn_db;

CREATE TABLE customer_churn (
CustomerId INT PRIMARY KEY,
Surname VARCHAR(100),
CreditScore INT,
Geography VARCHAR(50),
Gender VARCHAR(10),
Age INT,
Tenure INT,
Balance DECIMAL (15,2),
NumOfProducts INT,
HasCrCard TINYINT(1),
IsActiveMember TINYINT(1),
EstimatedSalary DECIMAL(15,2),
Exited TINYINT(1));  -- 1 = churned, 0 = stayed

SELECT COUNT(*) AS total_records FROM customer_churn;
SELECT * FROM customer_churn LIMIT 10;

-- Check for any NULL values in key columns
SELECT 
SUM(CASE WHEN CreditScore     IS NULL THEN 1 ELSE 0 END) AS null_CreditScore,
SUM(CASE WHEN Age             IS NULL THEN 1 ELSE 0 END) AS null_age,
SUM(CASE WHEN Balance         IS NULL THEN 1 ELSE 0 END) AS null_Balance,
SUM(CASE WHEN EstimatedSalary IS NULL THEN 1 ELSE 0 END) AS null_EstimatedSalary,
SUM(CASE WHEN Exited          IS NULL THEN 1 ELSE 0 END) AS null_Exited
FROM Customer_churn;

-- Q1: How many customers are from each country?
SELECT Geography,
COUNT(*) AS Total_Customers,
ROUND(COUNT(*) * 100.00/ SUM(COUNT(*)) OVER(),2) AS prt_of_total
FROM customer_churn
GROUP BY Geography
ORDER BY Total_Customers DESC;

-- Q2: Gender breakdown
SELECT Gender,
COUNT(*) AS total_customers,
ROUND(COUNT(*) * 100.00 / SUM(COUNT(*)) OVER(),2) AS prt_of_total
FROM customer_churn
GROUP BY gender
ORDER BY total_customers DESC;

-- Q3: Average credit score, balance, and salary by country
SELECT Geography,
ROUND(AVG(CreditScore),1)     AS avg_CreditScore,
ROUND(AVG(Balance),2)         AS avg_balance,
ROUND(AVG(EstimatedSalary),2) AS avg_salary
FROM Customer_churn
GROUP BY Geography
ORDER BY avg_balance DESC;

-- Q4: Customer distribution by number of products
SELECT NumOfProducts,
COUNT(*) AS total_customers,
ROUND(COUNT(*)*100.00/ SUM(COUNT(*)) OVER (),2) AS prt_of_total_customers
FROM Customer_churn
GROUP BY NumOfProducts
ORDER BY NumOfProducts DESC;

-- Q5: Age band distribution using CASE WHEN
SELECT 
      CASE 
      WHEN Age BETWEEN 18 AND 30 THEN '18-30'
      WHEN Age BETWEEN 31 AND 45 THEN '31-45'
      WHEN Age BETWEEN 46 AND 60 THEN '46-60'
      ELSE '60+'
      END AS age_band,
      COUNT(*) AS total_customers,
      ROUND(AVG(Balance),2) AS avg_balance
	  FROM customer_churn
      GROUP BY age_band
      ORDER BY age_band ASC;
      
-- Q6: Active vs Inactive members breakdown
SELECT 
      CASE 
      WHEN IsActiveMember=1 THEN 'active'
      ELSE 'inactive'
      END AS member_status,
	COUNT(*)                   AS total_customers,
    ROUND(AVG(CreditScore), 1) AS avg_credit_score,
    ROUND(AVG(Balance), 2)     AS avg_balance
FROM customer_churn
GROUP BY IsActiveMember;

-- Q7: Customers with zero balance — potential low-engagement flag
SELECT
    Geography,
    Gender,
    COUNT(*) AS zero_balance_customers
FROM customer_churn
WHERE Balance = 0
GROUP BY Geography, Gender
ORDER BY zero_balance_customers DESC;
















