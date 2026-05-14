[![FP&A Portfolio Project](https://img.shields.io/badge/FP%26A-Portfolio%20Project-blue?style=flat-square)](https://github.com/Sarah-H22/budget-VS-actual-sql-analysis)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13+-336791?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![SQL](https://img.shields.io/badge/SQL-Advanced-4479A1?style=flat-square)](https://en.wikipedia.org/wiki/SQL)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

# Budget vs Actual SQL Analysis System

## 📊 Project Overview

A comprehensive **Financial Planning & Analysis (FP&A) system** demonstrating advanced SQL capabilities for budget variance analysis in the banking sector. This project showcases the ability to design financial databases, perform multi-dimensional variance analysis, and generate actionable insights for executive decision-making.

### Why This Project Matters

In FP&A roles, the ability to extract meaningful insights from financial data is critical. This project demonstrates:
- ✅ **Database Design Excellence** - Normalized schema supporting complex financial reporting
- ✅ **Advanced SQL Proficiency** - Window functions, CTEs, aggregations, and view creation
- ✅ **Business Acumen** - Understanding of banking operations and financial metrics
- ✅ **Analytical Thinking** - Variance investigation and trend analysis methodology
- ✅ **Executive Communication** - Query results designed for decision-makers

---

## 🏦 Banking Sector Context

The dataset models **H1 2026 (January-June)** financial performance for a mid-sized commercial bank with the following departments:

| Department | Focus | Key Metrics |
|---|---|---|
| **Retail Banking** | Consumer products & services | Loan interest, card fees, deposit spreads |
| **Commercial Banking** | Corporate lending & services | Large loan portfolio, syndication revenue |
| **Investment Banking** | M&A, capital markets | Advisory fees, placement fees |
| **Operations** | Internal support functions | Cost center efficiency |
| **Risk & Compliance** | Regulatory adherence | Compliance costs, risk management |
| **Technology & Digital** | IT infrastructure & innovation | System costs, digital transformation |

---

## 📁 Repository Structure

```
budget-VS-actual-sql-analysis/
├── README.md                    # This file
├── schema.sql                   # Database schema, tables, and sample data
├── analysis_queries.sql         # 12 professional FP&A queries
├── SETUP.md                     # Installation & execution guide
└── SAMPLE_OUTPUT/              # Expected query results
    ├── variance_summary.csv
    └── department_performance.csv
```

---

## 🗄️ Database Schema

### Core Tables

#### `departments`
Represents organizational structure
- Retail Banking, Commercial Banking, Investment Banking, Operations, Risk & Compliance, Technology & Digital

#### `chart_of_accounts`
Complete GL account structure with 4 account types:
- **Revenue** (Interest Income, Fees)
- **Expense** (Salaries, Technology, Compliance)
- **Assets** & **Liabilities** (extensible framework)

**Sample Accounts:**
```
4110 - Loan Interest Income (Revenue)
4210 - Credit Card Fees (Revenue)
5100 - Salaries and Benefits (Expense)
5200 - Technology Costs (Expense)
5400 - Regulatory & Compliance (Expense)
```

#### `budget_plan`
Planned financial metrics by account, department, and month
- Fiscal year 2026, Jan-Jun budget allocations
- Notes and audit trail (created_by, created_date)

#### `actual_results`
Real transaction data by account, department, and month
- Includes transaction count and date tracking
- ~90 rows of realistic H1 data

### Key Relationships

```
departments (1) ──→ (M) budget_plan
                  ├─→ (M) actual_results
                  └─→ (M) chart_of_accounts

chart_of_accounts (1) ──→ (M) budget_plan
                        └─→ (M) actual_results
```

### Views for Analysis

✨ **Three strategic views** created for variance analysis:

1. **`v_budget_vs_actual_summary`** - Detailed monthly variance by account/department
2. **`v_department_variance`** - Aggregated department-level P&L variance
3. **`v_top_variances`** - Exception reporting (variances > $50K)

---

## 📈 Key FP&A Queries Included

### 1️⃣ Monthly Variance Summary by Department
**Purpose:** Executive overview for monthly board reporting
```sql
SELECT department_name, month, 
       revenue_budget, revenue_actual, revenue_variance, revenue_variance_pct
FROM v_budget_vs_actual_summary
```
**Output:** High-level KPIs for each department across 6 months

---

### 2️⃣ Detailed Account-Level Variance Analysis
**Purpose:** Drill-down to identify specific variances
```sql
SELECT account_code, account_name, total_budgeted, total_actual, 
       total_variance, variance_percent, variance_assessment
GROUP BY account and analyze each GL line
```
**Output:** Root cause analysis at GL account level

---

### 3️⃣ Department P&L Summary
**Purpose:** Profitability analysis by department
```sql
SELECT department, budgeted_revenue, actual_revenue, 
       actual_expenses, actual_profit, profit_variance
```
**Output:** Which departments are outperforming budget?

---

### 4️⃣ Top Unfavorable Variances
**Purpose:** Exception reporting for management attention
```sql
SELECT TOP 20 department, account, variance_type, abs_variance
WHERE ABS(variance) > $50,000
```
**Output:** Prioritized list of variances requiring investigation

---

### 5️⃣ Month-over-Month Trend Analysis
**Purpose:** Identify performance trends and seasonality
```sql
SELECT month, monthly_revenue, budgeted_revenue, 
       revenue_growth_pct, actual_net_income
ORDER BY month
```
**Output:** Revenue momentum and cost trajectory analysis

---

### 6️⃣-12️⃣ Additional Specialized Queries
- **Revenue Stream Analysis** - Performance by product line (loans, cards, advisory)
- **Expense Control Analysis** - Cost management and efficiency metrics
- **Forecast vs Actual (YTD)** - Year-to-date performance tracking
- **Variance Waterfall** - Cumulative impact visualization
- **Department Drill-Down** - Manager-level detailed variance breakdown
- **KPI Dashboard** - Summary by variance status (Favorable/Unfavorable)
- **Full-Year Forecast** - Project H1 performance to annual results

---

## 🚀 Quick Start

### Prerequisites
- PostgreSQL 13+ installed locally
- `psql` command-line tool
- Git

### Setup Instructions

#### 1. Clone the Repository
```bash
git clone https://github.com/Sarah-H22/budget-VS-actual-sql-analysis.git
cd budget-VS-actual-sql-analysis
```

#### 2. Create Database
```bash
createdb fpa_banking_db
```

#### 3. Load Schema & Data
```bash
psql -U postgres -d fpa_banking_db -f schema.sql
```

#### 4. Run Analysis Queries
```bash
psql -U postgres -d fpa_banking_db -f analysis_queries.sql
```

#### 5. Execute Individual Queries
```bash
psql -U postgres -d fpa_banking_db
# Then paste any query from analysis_queries.sql
```

**Full setup guide:** See [SETUP.md](SETUP.md)

---

## 📊 Sample Analysis Results

### Example 1: Monthly Revenue Summary
```
Department          Month  Revenue_Budget  Revenue_Actual  Variance_Pct
─────────────────────────────────────────────────────────────────────
Retail Banking      June   3,025,000       3,577,000       +18.2%
Commercial Banking  June   3,450,000       3,520,000       +2.0%
Investment Banking  June   1,200,000       1,185,000       -1.3%
```

### Example 2: Top 5 Variances (June)
```
Account Code  Department          Budget        Actual      Variance    Assessment
─────────────────────────────────────────────────────────────────────────────────
4110          Commercial Banking  3,450,000     3,520,000   +70,000     Favorable (Revenue)
5100          Commercial Banking  1,550,000     1,585,000   +35,000     Unfavorable (Salary)
4210          Retail Banking      475,000       492,000     +17,000     Favorable (Fees)
5200          Technology          365,000       360,000     -5,000      Favorable (Costs)
```

### Example 3: Department P&L Performance
```
Department          Budgeted_Profit  Actual_Profit  Profit_Variance
─────────────────────────────────────────────────────────────────────
Commercial Banking  8,850,000        8,925,000      +75,000 (0.8%)
Retail Banking      5,450,000        5,617,000      +167,000 (3.1%)
Investment Banking  1,200,000        1,185,000      -15,000 (-1.3%)
```

---

## 💡 FP&A Insights Demonstrated

### 1. Revenue Performance
- **Retail Banking:** +3.1% profit variance (driven by card fees outperformance)
- **Commercial Banking:** +0.8% profit variance (strong loan portfolio growth)
- **Opportunity:** Commercial Banking could increase budgets given consistent outperformance

### 2. Expense Management
- **Salary Costs:** Commercial Banking over budget by $35K (3.2%) due to hiring
- **Technology Costs:** Under budget by $15K YTD (favorable vendor negotiations)
- **Compliance Costs:** On budget (stable regulatory environment)

### 3. Forecasting & Planning
- Based on H1 performance, projected full-year revenue could exceed budget by **$120K-150K**
- Commercial Banking momentum suggests conservative budget assumptions
- Recommend mid-year reforecasting to capture upside

### 4. Risk Areas
- Investment Banking revenue -1.3% (market conditions)
- Recommend product review and strategic realignment

---

## 🎯 FP&A Skills Showcased

| Skill | Evidence |
|---|---|
| **Database Design** | Normalized schema with proper relationships and indexes |
| **Advanced SQL** | Window functions, CTEs, aggregations, views, multi-table joins |
| **Financial Analysis** | Variance methodology, P&L construction, trend analysis |
| **Data Storytelling** | Queries structured to answer business questions |
| **Executive Reporting** | Formatted output suitable for dashboards & presentations |
| **Attention to Detail** | Accurate calculations, proper GL account hierarchy |

---

## 🔍 Real-World Applications

This project demonstrates expertise applicable to:

### ✅ FP&A Analyst Roles
- Monthly variance analysis and reporting
- Budget vs actual reconciliation
- Departmental performance tracking
- Forecast adjustment preparation

### ✅ Financial Planning Roles
- Revenue and expense forecasting
- Budget building and consolidation
- Sensitivity analysis scenarios
- Long-range planning support

### ✅ Controller/Accounting Roles
- GL account reconciliation
- P&L statement preparation
- Internal controls testing
- Financial consolidation

### ✅ Business Intelligence Roles
- Financial data warehouse design
- Dashboard and report development
- Executive KPI tracking
- Data quality validation

---

## 🛠️ Technologies & Concepts

```
SQL Techniques:
├── DDL (CREATE TABLE, CREATE VIEW, CREATE INDEX)
├── DML (INSERT, aggregations)
├── Window Functions (LAG, ROW_NUMBER, SUM() OVER)
├── Common Table Expressions (WITH clauses)
├── JOINs (INNER, OUTER, FULL OUTER)
├── Conditional Logic (CASE WHEN)
└── Date Functions & Aggregations

Database Design:
├── Normalization (3NF)
├── Primary & Foreign Keys
├── Indexing Strategy
├── Data Integrity Constraints
└── View Creation for Business Logic

FP&A Concepts:
├── Variance Analysis (Actual vs Budget)
├── P&L Statement Construction
├── Departmental Profitability
├── Revenue Stream Analysis
├── Cost Center Management
├── Trend Analysis & Forecasting
└── Exception Management
```

---

## 📚 Learning Resources Embedded

Each query includes:
- **Purpose statement** - Why this analysis matters
- **Use case** - Real business scenarios
- **Detailed comments** - SQL explanation
- **Output interpretation** - How to read results

This makes the project valuable for learning FP&A best practices.

---

## 🚦 Query Difficulty Progression

**Beginner Level:**
- Query 1: Monthly Variance Summary
- Query 5: Month-over-Month Trends

**Intermediate Level:**
- Query 2: Account-Level Analysis
- Query 3: Department P&L
- Query 6-7: Revenue/Expense Deep-Dive

**Advanced Level:**
- Query 4: Exception Reporting with Complex Logic
- Query 8: YTD Calculations
- Query 9: Variance Waterfall with Row Numbering
- Query 12: Forecasting with Ratio Calculations

---

## 📈 Extension Ideas

To further enhance this project:

1. **Add Variance Explanations Table**
   ```sql
   CREATE TABLE variance_explanations (
       variance_id SERIAL PRIMARY KEY,
       account_id INT REFERENCES chart_of_accounts,
       month INT,
       explanation TEXT,
       responsible_manager VARCHAR(100),
       status VARCHAR(20)
   );
   ```

2. **Create Forecast Scenarios**
   - Best case, base case, worst case scenarios
   - Rolling forecast updates

3. **Add Previous Year Comparison**
   - Budget vs Actual vs Prior Year
   - YoY growth analysis

4. **Implement Drill-Down Hierarchy**
   - Company → Division → Department → Account
   - Multi-level reporting structure

5. **Add Data Validation Queries**
   - Reconciliation checks
   - Balance sheet integrity tests

---

## 📝 Notes & Assumptions

- **Data Period:** Fiscal Year 2026, January-June (H1)
- **Departments:** 6 functional areas (typical mid-sized bank structure)
- **Account Structure:** 20+ GL accounts covering revenue and primary expense categories
- **Budget Assumptions:** Even distribution across months (extensible for seasonality)
- **Actuals:** Realistic H1 performance with intentional variances for analysis

---

## 🤝 Contributing

This is a portfolio project. Feedback and suggestions are welcome:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add analysis query'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Sarah H.**  
📧 Email: [Your Email]  
🔗 LinkedIn: [Your LinkedIn Profile]  
💼 Portfolio: [Your Portfolio Link]

---

## 🎓 Key Takeaway

This project demonstrates **end-to-end FP&A capability** - from database design through complex analysis queries to actionable business insights. It's ready to support real financial decision-making and shows the SQL and analytical skills valued in FP&A, accounting, and finance leadership roles.

**Perfect for:**
- Portfolio building for FP&A analysts
- Interview preparation
- Demonstrating SQL + business analysis skills
- Teaching financial reporting concepts

---

## ❓ FAQ

**Q: Can I use this with other databases?**  
A: Yes! The SQL is standard and works with MySQL, SQL Server, and others with minor syntax adjustments.

**Q: How do I add more departments or accounts?**  
A: Insert rows into `departments` and `chart_of_accounts` tables, then add corresponding budget and actual records.

**Q: Can I use real company data?**  
A: Absolutely! Replace the sample data with your company's budget and actuals following the same schema.

**Q: What if budget amounts are zero?**  
A: The queries handle division-by-zero with `NULLIF(column, 0)` - they'll return NULL for variance %.

---

**Last Updated:** May 14, 2026  
**Status:** Production Ready ✅
