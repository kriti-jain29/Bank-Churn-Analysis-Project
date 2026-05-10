# Bank-Churn-Analysis-Project
SQL analysis of bank customer churn using CTEs, window functions and revenue insights.

# 🏦 Bank Customer Churn & Revenue Analysis

## Project Overview
Analyzed churning behavior of 10,000 bank customers using SQL 
to identify high-risk segments and quantify revenue at risk.

## Tools Used
- **SQL** — MySQL Workbench
- **Dataset** — Bank Customer Churn (Kaggle/Maven Analytics)

## Business Questions Answered
- Which customer segments have the highest churn rate?
- How much revenue is the bank losing to churn?
- Which inactive customers are most at risk of churning next?

## Key Findings
- 🔴 Germany has a **~32% churn rate** — 2x higher than France and Spain
- 🔴 Customers aged **46–60 with 3+ products** churn at nearly 100%
- 💰 Total estimated **revenue at risk: $X million** from churned customers
- ⚠️ **$X million** in future revenue at risk from inactive members still with the bank

## SQL Skills Demonstrated
| Skill | Used In |
|---|---|
| CASE WHEN, GROUP BY, HAVING | Q4, Q5, Q7 |
| CTEs (WITH clause) | Q13, Q22, Q23, Q24 |
| Window Functions (RANK, NTILE, SUM OVER) | Q14, Q15, Q16 |
| Subqueries | Q17 |
| Multi-condition filtering | Q10, Q17, Q24 |

## File Structure
| File | Description |
|---|---|
| `sql/01_setup.sql` | Database setup and table creation |
| `sql/02_exploration.sql` | Data exploration — distributions and patterns |
| `sql/03_churn_analysis.sql` | Churn rate analysis using CTEs and window functions |
| `sql/04_revenue_cohort.sql` | Revenue at risk and cohort segmentation |
