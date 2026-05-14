-- =====================================================================
-- BUDGET VS ACTUAL ANALYSIS QUERIES
-- Financial Planning & Analysis (FP&A) - Banking Sector
-- =====================================================================

-- =====================================================================
-- QUERY 1: MONTHLY VARIANCE SUMMARY BY DEPARTMENT
-- Purpose: Executive overview of budget performance by department
-- Use Case: Monthly board reporting, executive dashboards
-- =====================================================================
SELECT 
    department_name,
    month,
    SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END) AS revenue_budget,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) AS revenue_actual,
    SUM(CASE WHEN account_type = 'Expense' THEN budgeted_amount ELSE 0 END) AS expense_budget,
    SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS expense_actual,
    (SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
     SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END)) AS revenue_variance,
    (SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) - 
     SUM(CASE WHEN account_type = 'Expense' THEN budgeted_amount ELSE 0 END)) AS expense_variance,
    ROUND(((SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
            SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END)) / 
           NULLIF(SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END), 0)) * 100, 2) AS revenue_variance_pct
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY department_name, month
ORDER BY month DESC, revenue_variance DESC;

-- =====================================================================
-- QUERY 2: DETAILED ACCOUNT-LEVEL VARIANCE ANALYSIS
-- Purpose: Drill-down analysis by GL account to identify specific areas
-- Use Case: Variance investigation, root cause analysis
-- =====================================================================
SELECT 
    account_code,
    account_name,
    account_type,
    category,
    SUM(budgeted_amount) AS total_budgeted,
    SUM(actual_amount) AS total_actual,
    SUM(actual_amount) - SUM(budgeted_amount) AS total_variance,
    ROUND((SUM(actual_amount) - SUM(budgeted_amount)) / 
           NULLIF(SUM(budgeted_amount), 0) * 100, 2) AS variance_percent,
    COUNT(DISTINCT CONCAT(fiscal_year, '-', month)) AS periods_reported,
    CASE 
        WHEN account_type = 'Revenue' AND (SUM(actual_amount) - SUM(budgeted_amount)) > 0 THEN 'Favorable'
        WHEN account_type = 'Revenue' AND (SUM(actual_amount) - SUM(budgeted_amount)) < 0 THEN 'Unfavorable'
        WHEN account_type = 'Expense' AND (SUM(actual_amount) - SUM(budgeted_amount)) < 0 THEN 'Favorable'
        WHEN account_type = 'Expense' AND (SUM(actual_amount) - SUM(budgeted_amount)) > 0 THEN 'Unfavorable'
        ELSE 'On Budget'
    END AS variance_assessment
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY account_code, account_name, account_type, category
ORDER BY ABS(SUM(actual_amount) - SUM(budgeted_amount)) DESC;

-- =====================================================================
-- QUERY 3: DEPARTMENT PROFIT & LOSS (P&L) SUMMARY
-- Purpose: Calculate contribution by department with variances
-- Use Case: Departmental performance evaluation, profitability analysis
-- =====================================================================
WITH dept_summary AS (
    SELECT 
        department_code,
        department_name,
        account_type,
        SUM(budgeted_amount) AS budget_amount,
        SUM(actual_amount) AS actual_amount
    FROM v_budget_vs_actual_summary
    WHERE fiscal_year = 2026
    GROUP BY department_code, department_name, account_type
)
SELECT 
    department_code,
    department_name,
    SUM(CASE WHEN account_type = 'Revenue' THEN budget_amount ELSE 0 END) AS budgeted_revenue,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) AS actual_revenue,
    SUM(CASE WHEN account_type = 'Expense' THEN budget_amount ELSE 0 END) AS budgeted_expenses,
    SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS actual_expenses,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
    SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS actual_profit,
    SUM(CASE WHEN account_type = 'Revenue' THEN budget_amount ELSE 0 END) - 
    SUM(CASE WHEN account_type = 'Expense' THEN budget_amount ELSE 0 END) AS budgeted_profit,
    (SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
     SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END)) -
    (SUM(CASE WHEN account_type = 'Revenue' THEN budget_amount ELSE 0 END) - 
     SUM(CASE WHEN account_type = 'Expense' THEN budget_amount ELSE 0 END)) AS profit_variance
FROM dept_summary
GROUP BY department_code, department_name
ORDER BY profit_variance DESC;

-- =====================================================================
-- QUERY 4: TOP UNFAVORABLE VARIANCES (Exception Reporting)
-- Purpose: Identify top problem areas requiring management attention
-- Use Case: Exception management, variance investigation
-- =====================================================================
SELECT 
    department_name,
    account_code,
    account_name,
    account_type,
    month,
    budgeted_amount,
    actual_amount,
    ABS(actual_amount - budgeted_amount) AS abs_variance,
    ROUND(ABS((actual_amount - budgeted_amount) / NULLIF(budgeted_amount, 1)) * 100, 2) AS variance_pct,
    CASE 
        WHEN account_type = 'Revenue' AND actual_amount < budgeted_amount THEN 'Revenue Shortfall'
        WHEN account_type = 'Revenue' AND actual_amount > budgeted_amount THEN 'Revenue Upside'
        WHEN account_type = 'Expense' AND actual_amount > budgeted_amount THEN 'Expense Overage'
        WHEN account_type = 'Expense' AND actual_amount < budgeted_amount THEN 'Cost Savings'
    END AS variance_type
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND ABS(actual_amount - budgeted_amount) > 50000
ORDER BY ABS(actual_amount - budgeted_amount) DESC
LIMIT 20;

-- =====================================================================
-- QUERY 5: MONTH-OVER-MONTH TREND ANALYSIS
-- Purpose: Track performance trends across months
-- Use Case: Forecasting adjustments, trend analysis
-- =====================================================================
WITH monthly_data AS (
    SELECT 
        month,
        SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) AS monthly_revenue,
        SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS monthly_expense,
        SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END) AS budgeted_revenue,
        SUM(CASE WHEN account_type = 'Expense' THEN budgeted_amount ELSE 0 END) AS budgeted_expense
    FROM v_budget_vs_actual_summary
    WHERE fiscal_year = 2026
    GROUP BY month
)
SELECT 
    month,
    ROUND(monthly_revenue::NUMERIC, 2) AS actual_revenue,
    ROUND(budgeted_revenue::NUMERIC, 2) AS budgeted_revenue,
    ROUND((monthly_revenue - budgeted_revenue)::NUMERIC, 2) AS revenue_var,
    ROUND(monthly_expense::NUMERIC, 2) AS actual_expense,
    ROUND(budgeted_expense::NUMERIC, 2) AS budgeted_expense,
    ROUND((monthly_expense - budgeted_expense)::NUMERIC, 2) AS expense_var,
    ROUND((monthly_revenue - monthly_expense)::NUMERIC, 2) AS actual_net_income,
    ROUND((budgeted_revenue - budgeted_expense)::NUMERIC, 2) AS budgeted_net_income,
    LAG(ROUND(monthly_revenue::NUMERIC, 2)) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month)) / 
           NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0) * 100)::NUMERIC, 2) AS revenue_growth_pct
FROM monthly_data
ORDER BY month ASC;

-- =====================================================================
-- QUERY 6: REVENUE ANALYSIS BY STREAM (Banking Products)
-- Purpose: Analyze revenue performance by product line
-- Use Case: Revenue management, product performance evaluation
-- =====================================================================
SELECT 
    department_name,
    category,
    sub_category,
    SUM(budgeted_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(actual_amount) - SUM(budgeted_amount) AS variance_amount,
    ROUND((SUM(actual_amount) - SUM(budgeted_amount)) / 
           NULLIF(SUM(budgeted_amount), 0) * 100, 2) AS variance_pct,
    ROUND((SUM(actual_amount) / SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) 
           OVER (PARTITION BY department_name)) * 100, 2) AS pct_of_dept_revenue
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND account_type = 'Revenue'
GROUP BY department_name, category, sub_category
ORDER BY department_name, variance_pct DESC;

-- =====================================================================
-- QUERY 7: EXPENSE CONTROL ANALYSIS
-- Purpose: Monitor expense spend and control
-- Use Case: Cost management, budget control, efficiency analysis
-- =====================================================================
SELECT 
    department_name,
    category,
    SUM(budgeted_amount) AS total_budget,
    SUM(actual_amount) AS total_actual,
    SUM(budgeted_amount) - SUM(actual_amount) AS savings_unfavorable,
    CASE 
        WHEN SUM(actual_amount) < SUM(budgeted_amount) THEN 'Under Budget'
        WHEN SUM(actual_amount) > SUM(budgeted_amount) THEN 'Over Budget'
        ELSE 'On Budget'
    END AS budget_status,
    ROUND((SUM(actual_amount) / SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) 
           OVER (PARTITION BY department_name)) * 100, 2) AS pct_of_dept_expense,
    COUNT(DISTINCT month) AS months_with_activity
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND account_type = 'Expense'
GROUP BY department_name, category
ORDER BY department_name, total_actual DESC;

-- =====================================================================
-- QUERY 8: FORECAST VS ACTUAL (YTD Performance)
-- Purpose: Compare year-to-date actual performance against budget
-- Use Case: Performance tracking, forecast adjustments, reporting
-- =====================================================================
SELECT 
    department_name,
    account_code,
    account_name,
    account_type,
    SUM(budgeted_amount) AS ytd_budget,
    SUM(actual_amount) AS ytd_actual,
    SUM(actual_amount) - SUM(budgeted_amount) AS ytd_variance,
    ROUND(((SUM(actual_amount) - SUM(budgeted_amount)) / 
           NULLIF(SUM(budgeted_amount), 0)) * 100, 2) AS variance_pct,
    COUNT(DISTINCT month) AS months_reported,
    ROUND((SUM(actual_amount) / COUNT(DISTINCT month))::NUMERIC, 0) AS avg_monthly_actual,
    ROUND((SUM(budgeted_amount) / COUNT(DISTINCT month))::NUMERIC, 0) AS avg_monthly_budget
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY department_name, account_code, account_name, account_type
ORDER BY department_name, variance_pct DESC;

-- =====================================================================
-- QUERY 9: VARIANCE WATERFALL ANALYSIS
-- Purpose: Show cumulative impact of variances
-- Use Case: Executive presentations, variance bridge analysis
-- =====================================================================
WITH variance_calc AS (
    SELECT 
        account_code,
        account_name,
        category,
        SUM(actual_amount) - SUM(budgeted_amount) AS variance_amount,
        account_type,
        ROW_NUMBER() OVER (ORDER BY ABS(SUM(actual_amount) - SUM(budgeted_amount)) DESC) AS row_num
    FROM v_budget_vs_actual_summary
    WHERE fiscal_year = 2026
    GROUP BY account_code, account_name, category, account_type
)
SELECT 
    row_num,
    account_code,
    account_name,
    category,
    account_type,
    variance_amount,
    SUM(variance_amount) OVER (ORDER BY row_num) AS cumulative_variance,
    ROUND((variance_amount / SUM(variance_amount) OVER ()) * 100, 2) AS pct_of_total_variance
FROM variance_calc
WHERE row_num <= 15
ORDER BY row_num;

-- =====================================================================
-- QUERY 10: DETAILED MONTHLY DRILL-DOWN FOR A SPECIFIC DEPARTMENT
-- Purpose: Deep-dive analysis for department managers
-- Use Case: Department performance review, detailed variance investigation
-- =====================================================================
-- Example: Commercial Banking Department
SELECT 
    month,
    account_code,
    account_name,
    account_type,
    category,
    budgeted_amount,
    actual_amount,
    actual_amount - budgeted_amount AS monthly_variance,
    ROUND(((actual_amount - budgeted_amount) / NULLIF(budgeted_amount, 0)) * 100, 2) AS variance_pct,
    CASE 
        WHEN account_type = 'Revenue' AND actual_amount > budgeted_amount THEN '↑ Favorable'
        WHEN account_type = 'Revenue' AND actual_amount < budgeted_amount THEN '↓ Unfavorable'
        WHEN account_type = 'Expense' AND actual_amount < budgeted_amount THEN '↓ Favorable'
        WHEN account_type = 'Expense' AND actual_amount > budgeted_amount THEN '↑ Unfavorable'
        ELSE '→ On Budget'
    END AS indicator
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND department_code = 'CB001'
ORDER BY month, account_type DESC, ABS(actual_amount - budgeted_amount) DESC;

-- =====================================================================
-- QUERY 11: VARIANCE SUMMARY BY VARIANCE STATUS (KPI Dashboard)
-- Purpose: Summary view for KPI tracking
-- Use Case: Dashboard reporting, executive scorecards
-- =====================================================================
SELECT 
    variance_status,
    COUNT(*) AS occurrence_count,
    SUM(ABS(variance_amount)) AS total_variance_abs,
    ROUND(AVG(ABS(variance_amount))::NUMERIC, 2) AS avg_variance,
    ROUND(SUM(CASE WHEN variance_status = 'Favorable' THEN 1 ELSE 0 END)::NUMERIC / 
          COUNT(*) * 100, 2) AS pct_favorable
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND variance_amount IS NOT NULL
GROUP BY variance_status
ORDER BY total_variance_abs DESC;

-- =====================================================================
-- QUERY 12: PREDICTIVE ANALYSIS - FULL YEAR FORECAST
-- Purpose: Extrapolate H1 performance to estimate full year results
-- Use Case: Full-year forecasting, budget revision planning
-- =====================================================================
WITH h1_performance AS (
    SELECT 
        department_code,
        department_name,
        account_type,
        account_code,
        account_name,
        SUM(actual_amount) AS h1_actual,
        SUM(budgeted_amount) * 2 AS full_year_budget,  -- Assuming even distribution
        ROUND((SUM(actual_amount) / NULLIF(SUM(budgeted_amount), 0)), 3) AS actual_to_budget_ratio
    FROM v_budget_vs_actual_summary
    WHERE fiscal_year = 2026 AND month <= 6
    GROUP BY department_code, department_name, account_type, account_code, account_name
)
SELECT 
    department_name,
    account_code,
    account_name,
    account_type,
    full_year_budget,
    ROUND((h1_actual * 2)::NUMERIC, 0) AS projected_full_year,
    ROUND((h1_actual * 2 - full_year_budget)::NUMERIC, 0) AS projected_variance,
    ROUND(((h1_actual * 2 - full_year_budget) / full_year_budget * 100)::NUMERIC, 2) AS projected_variance_pct,
    actual_to_budget_ratio
FROM h1_performance
WHERE account_type IN ('Revenue', 'Expense')
ORDER BY ABS((h1_actual * 2) - full_year_budget) DESC;
