-- =====================================================================
-- Budget vs Actual Analysis System - Banking Sector
-- PostgreSQL Schema for Financial Planning & Analysis (FP&A)
-- =====================================================================

-- Drop existing tables if they exist (for fresh setup)
DROP TABLE IF EXISTS actual_results CASCADE;
DROP TABLE IF EXISTS budget_plan CASCADE;
DROP TABLE IF EXISTS chart_of_accounts CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- =====================================================================
-- 1. DEPARTMENTS TABLE
-- =====================================================================
-- Represents different business units within the bank
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    manager_name VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- =====================================================================
-- 2. CHART OF ACCOUNTS TABLE
-- =====================================================================
-- Represents the GL accounts used for financial reporting
CREATE TABLE chart_of_accounts (
    account_id SERIAL PRIMARY KEY,
    account_code VARCHAR(20) NOT NULL UNIQUE,
    account_name VARCHAR(150) NOT NULL,
    account_type VARCHAR(30) NOT NULL, -- 'Revenue', 'Expense', 'Asset', 'Liability'
    category VARCHAR(50) NOT NULL,
    sub_category VARCHAR(50),
    account_description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================================
-- 3. BUDGET PLAN TABLE
-- =====================================================================
-- Stores budgeted amounts by account and department for the fiscal year
CREATE TABLE budget_plan (
    budget_id SERIAL PRIMARY KEY,
    fiscal_year INT NOT NULL,
    account_id INT NOT NULL REFERENCES chart_of_accounts(account_id),
    department_id INT NOT NULL REFERENCES departments(department_id),
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    budgeted_amount NUMERIC(15, 2) NOT NULL,
    notes VARCHAR(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    UNIQUE(fiscal_year, account_id, department_id, month)
);

-- =====================================================================
-- 4. ACTUAL RESULTS TABLE
-- =====================================================================
-- Stores actual financial results by account and department
CREATE TABLE actual_results (
    actual_id SERIAL PRIMARY KEY,
    fiscal_year INT NOT NULL,
    account_id INT NOT NULL REFERENCES chart_of_accounts(account_id),
    department_id INT NOT NULL REFERENCES departments(department_id),
    month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
    actual_amount NUMERIC(15, 2) NOT NULL,
    transaction_date DATE,
    transaction_count INT DEFAULT 1,
    notes VARCHAR(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(fiscal_year, account_id, department_id, month)
);

-- =====================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =====================================================================
CREATE INDEX idx_budget_fiscal_year ON budget_plan(fiscal_year);
CREATE INDEX idx_budget_account ON budget_plan(account_id);
CREATE INDEX idx_budget_department ON budget_plan(department_id);
CREATE INDEX idx_actual_fiscal_year ON actual_results(fiscal_year);
CREATE INDEX idx_actual_account ON actual_results(account_id);
CREATE INDEX idx_actual_department ON actual_results(department_id);
CREATE INDEX idx_coa_type ON chart_of_accounts(account_type);

-- =====================================================================
-- INSERT DEPARTMENTS
-- =====================================================================
INSERT INTO departments (department_name, department_code, manager_name, description) VALUES
('Retail Banking', 'RB001', 'Michael Johnson', 'Consumer banking products and services'),
('Commercial Banking', 'CB001', 'Sarah Williams', 'Corporate and commercial lending'),
('Investment Banking', 'IB001', 'David Chen', 'M&A, Capital Markets, Advisory'),
('Operations', 'OPS001', 'Jennifer Martinez', 'Internal operations and support'),
('Risk & Compliance', 'RCC001', 'Robert Thompson', 'Risk management and regulatory compliance'),
('Technology & Digital', 'TECH001', 'Lisa Anderson', 'IT infrastructure and digital services');

-- =====================================================================
-- INSERT CHART OF ACCOUNTS - REVENUES
-- =====================================================================
INSERT INTO chart_of_accounts (account_code, account_name, account_type, category, sub_category, account_description) VALUES
('4100', 'Net Interest Income', 'Revenue', 'Interest Revenue', 'Core Banking', 'Interest earned on loans and deposits minus interest paid'),
('4110', 'Loan Interest Income', 'Revenue', 'Interest Revenue', 'Loans', 'Interest revenue from retail and commercial loans'),
('4120', 'Investment Income', 'Revenue', 'Interest Revenue', 'Investments', 'Interest and dividend income from securities'),
('4200', 'Non-Interest Income', 'Revenue', 'Fee & Charges', 'Service Fees', 'Fees from banking services'),
('4210', 'Credit Card Fees', 'Revenue', 'Fee & Charges', 'Card Services', 'Annual fees, transaction fees from credit cards'),
('4220', 'Loan Origination Fees', 'Revenue', 'Fee & Charges', 'Lending', 'One-time fees from loan origination'),
('4230', 'Advisory Fees', 'Revenue', 'Fee & Charges', 'Investment Services', 'Wealth management and advisory fees'),
('4240', 'Foreign Exchange Gains', 'Revenue', 'Trading Revenue', 'FX Trading', 'Gains from foreign exchange transactions');

-- =====================================================================
-- INSERT CHART OF ACCOUNTS - EXPENSES
-- =====================================================================
INSERT INTO chart_of_accounts (account_code, account_name, account_type, category, sub_category, account_description) VALUES
('5100', 'Salaries and Benefits', 'Expense', 'Personnel Expense', 'Compensation', 'Employee salaries, bonuses, and benefits'),
('5110', 'Base Salaries', 'Expense', 'Personnel Expense', 'Compensation', 'Base salary compensation'),
('5120', 'Performance Bonuses', 'Expense', 'Personnel Expense', 'Compensation', 'Performance-based bonuses'),
('5130', 'Health Insurance', 'Expense', 'Personnel Expense', 'Benefits', 'Employee health insurance premiums'),
('5200', 'Technology Costs', 'Expense', 'Technology Expense', 'Systems', 'Software licenses and IT infrastructure'),
('5210', 'Software Licenses', 'Expense', 'Technology Expense', 'Systems', 'Annual software licensing fees'),
('5220', 'System Maintenance', 'Expense', 'Technology Expense', 'Systems', 'Hardware and system maintenance'),
('5230', 'Cybersecurity', 'Expense', 'Technology Expense', 'Security', 'Cybersecurity and data protection'),
('5300', 'Occupancy Costs', 'Expense', 'Facility Expense', 'Real Estate', 'Rent, utilities, and facility maintenance'),
('5400', 'Regulatory & Compliance', 'Expense', 'Compliance Expense', 'Regulatory', 'Compliance, audit, and regulatory costs'),
('5500', 'Depreciation & Amortization', 'Expense', 'Non-Cash Expense', 'Depreciation', 'D&A on fixed assets'),
('5600', 'Marketing & Business Development', 'Expense', 'Marketing Expense', 'Advertising', 'Marketing campaigns and client acquisition'),
('5700', 'Provision for Loan Losses', 'Expense', 'Credit Expense', 'Credit Risk', 'Expected credit loss reserve');

-- =====================================================================
-- INSERT SAMPLE BUDGET DATA FOR 2026 (FY 2026)
-- =====================================================================
-- Retail Banking - Interest Income
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 2500000, 'Q1 planning', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 2520000, 'Expected growth', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 2540000, 'Seasonal increase', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 4, 2560000, 'Q2 planning', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 5, 2580000, 'Expected growth', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 6, 2600000, 'Mid-year peak', 'CFO');

-- Commercial Banking - Interest Income
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 1, 3200000, 'Corporate loans', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 2, 3250000, 'Growth expected', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 3, 3300000, 'Pipeline strong', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 4, 3350000, 'Q2 projections', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 5, 3400000, 'Continued growth', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 6, 3450000, 'H1 peak season', 'CFO');

-- Credit Card Fees - Retail Banking
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 450000, 'Card portfolio growth', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 455000, 'Seasonal increase', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 460000, 'Growth trajectory', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 4, 465000, 'Q2 momentum', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 5, 470000, 'Summer spending', 'CFO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 6, 475000, 'H1 average', 'CFO');

-- Salaries and Benefits - All Departments
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 1200000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 1200000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 1250000, 'With bonus accrual', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 1, 1500000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 2, 1500000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 3, 1550000, 'With bonus accrual', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 1, 900000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 2, 900000, 'Base salary + benefits', 'HR Director'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 3, 950000, 'With bonus accrual', 'HR Director');

-- Technology Costs - Technology Department
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 1, 350000, 'Monthly licenses', 'CTO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 2, 350000, 'Monthly licenses', 'CTO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 3, 360000, 'Q1 additional spend', 'CTO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 4, 350000, 'Monthly licenses', 'CTO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 5, 350000, 'Monthly licenses', 'CTO'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 6, 365000, 'Mid-year upgrades', 'CTO');

-- Compliance & Regulatory - Risk & Compliance
INSERT INTO budget_plan (fiscal_year, account_id, department_id, month, budgeted_amount, notes, created_by) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 1, 250000, 'Regulatory fees', 'Chief Compliance Officer'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 2, 250000, 'Regulatory fees', 'Chief Compliance Officer'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 3, 280000, 'Annual audit', 'Chief Compliance Officer'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 4, 250000, 'Regulatory fees', 'Chief Compliance Officer'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 5, 250000, 'Regulatory fees', 'Chief Compliance Officer'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 6, 250000, 'Regulatory fees', 'Chief Compliance Officer');

-- =====================================================================
-- INSERT SAMPLE ACTUAL RESULTS FOR 2026 (Jan-Jun)
-- =====================================================================
-- Retail Banking - Loan Interest Income (Actual vs Budget variance)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 2480000, '2026-01-31', 15200, 'Strong Q1 start but below budget'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 2535000, '2026-02-28', 15500, 'Recovery from Jan shortfall'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 2565000, '2026-03-31', 15800, 'Above budget - strong spring'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 4, 2545000, '2026-04-30', 15600, 'Slight dip in early Q2'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 5, 2605000, '2026-05-31', 15900, 'Strong May performance'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 6, 2620000, '2026-06-30', 16100, 'H1 momentum strong');

-- Commercial Banking - Loan Interest Income (Exceeds budget)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 1, 3250000, '2026-01-31', 8500, 'Strong corporate deal flow'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 2, 3320000, '2026-02-28', 8700, 'Large syndicated loans closed'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 3, 3380000, '2026-03-31', 8900, 'Pipeline execution strong'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 4, 3410000, '2026-04-30', 9100, 'Continued momentum'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 5, 3480000, '2026-05-31', 9300, 'Exceptional May sales'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4110'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 6, 3520000, '2026-06-30', 9500, 'H1 significantly above target');

-- Credit Card Fees - Retail Banking (Variable performance)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 445000, '2026-01-31', 125000, 'Holiday season impact'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 448000, '2026-02-28', 127000, 'Seasonal decline minimal'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 462000, '2026-03-31', 130000, 'Spring spending surge'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 4, 468000, '2026-04-30', 132000, 'Sustained momentum'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 5, 485000, '2026-05-31', 135000, 'Early summer boost'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '4210'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 6, 492000, '2026-06-30', 138000, 'Strong H1 finish');

-- Salaries and Benefits - Retail Banking (On budget)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 1, 1198000, '2026-01-31', 450, 'On track'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 2, 1202000, '2026-02-28', 450, 'Minimal variance'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 3, 1248000, '2026-03-31', 470, 'Q1 bonus accrual'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 4, 1205000, '2026-04-30', 450, 'Q2 baseline'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 5, 1207000, '2026-05-31', 450, 'On budget'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'RB001'), 6, 1210000, '2026-06-30', 450, 'H1 on track');

-- Salaries and Benefits - Commercial Banking (Over budget)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 1, 1520000, '2026-01-31', 550, 'Retention bonuses'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 2, 1525000, '2026-02-28', 550, 'Higher than budget'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 3, 1575000, '2026-03-31', 570, 'Q1 bonus + hiring'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 4, 1530000, '2026-04-30', 555, 'New hire costs'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 5, 1540000, '2026-05-31', 560, 'Continues to overspend'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5100'), 
 (SELECT department_id FROM departments WHERE department_code = 'CB001'), 6, 1585000, '2026-06-30', 575, 'Strong performance bonuses');

-- Technology Costs - Technology Department (Under budget)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 1, 340000, '2026-01-31', 120, 'Vendor negotiations'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 2, 340000, '2026-02-28', 120, 'Favorable contracts'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 3, 355000, '2026-03-31', 130, 'Necessary upgrades'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 4, 345000, '2026-04-30', 125, 'Q2 savings'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 5, 348000, '2026-05-31', 125, 'Controlled spending'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5200'), 
 (SELECT department_id FROM departments WHERE department_code = 'TECH001'), 6, 360000, '2026-06-30', 130, 'Mid-year within budget');

-- Compliance & Regulatory - Risk & Compliance (On track)
INSERT INTO actual_results (fiscal_year, account_id, department_id, month, actual_amount, transaction_date, transaction_count, notes) VALUES
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 1, 248000, '2026-01-31', 50, 'On budget'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 2, 252000, '2026-02-28', 50, 'Minimal variance'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 3, 282000, '2026-03-31', 75, 'Annual audit costs'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 4, 252000, '2026-04-30', 50, 'Back to baseline'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 5, 251000, '2026-05-31', 50, 'On budget'),
(2026, (SELECT account_id FROM chart_of_accounts WHERE account_code = '5400'), 
 (SELECT department_id FROM departments WHERE department_code = 'RCC001'), 6, 249000, '2026-06-30', 50, 'H1 on track');

-- =====================================================================
-- CREATE VIEWS FOR VARIANCE ANALYSIS
-- =====================================================================

-- Monthly Budget vs Actual Summary View
CREATE VIEW v_budget_vs_actual_summary AS
SELECT 
    b.fiscal_year,
    b.month,
    d.department_name,
    d.department_code,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    coa.category,
    COALESCE(b.budgeted_amount, 0) AS budgeted_amount,
    COALESCE(a.actual_amount, 0) AS actual_amount,
    COALESCE(a.actual_amount, 0) - COALESCE(b.budgeted_amount, 0) AS variance_amount,
    CASE 
        WHEN COALESCE(b.budgeted_amount, 0) = 0 THEN NULL
        ELSE ROUND(((COALESCE(a.actual_amount, 0) - COALESCE(b.budgeted_amount, 0)) / COALESCE(b.budgeted_amount, 0) * 100)::NUMERIC, 2)
    END AS variance_percent,
    CASE 
        WHEN coa.account_type = 'Revenue' THEN
            CASE 
                WHEN COALESCE(a.actual_amount, 0) > COALESCE(b.budgeted_amount, 0) THEN 'Favorable'
                WHEN COALESCE(a.actual_amount, 0) < COALESCE(b.budgeted_amount, 0) THEN 'Unfavorable'
                ELSE 'On Budget'
            END
        WHEN coa.account_type = 'Expense' THEN
            CASE 
                WHEN COALESCE(a.actual_amount, 0) < COALESCE(b.budgeted_amount, 0) THEN 'Favorable'
                WHEN COALESCE(a.actual_amount, 0) > COALESCE(b.budgeted_amount, 0) THEN 'Unfavorable'
                ELSE 'On Budget'
            END
        ELSE 'N/A'
    END AS variance_status
FROM budget_plan b
FULL OUTER JOIN actual_results a ON 
    b.account_id = a.account_id 
    AND b.department_id = a.department_id 
    AND b.fiscal_year = a.fiscal_year 
    AND b.month = a.month
JOIN chart_of_accounts coa ON COALESCE(b.account_id, a.account_id) = coa.account_id
JOIN departments d ON COALESCE(b.department_id, a.department_id) = d.department_id
ORDER BY b.fiscal_year, b.month, d.department_code, coa.account_code;

-- Department-Level P&L Variance View
CREATE VIEW v_department_variance AS
SELECT 
    EXTRACT(YEAR FROM DATE(b.fiscal_year || '-01-01')) AS fiscal_year,
    d.department_name,
    d.department_code,
    coa.account_type,
    SUM(COALESCE(b.budgeted_amount, 0)) AS total_budget,
    SUM(COALESCE(a.actual_amount, 0)) AS total_actual,
    SUM(COALESCE(a.actual_amount, 0)) - SUM(COALESCE(b.budgeted_amount, 0)) AS total_variance,
    ROUND((SUM(COALESCE(a.actual_amount, 0)) - SUM(COALESCE(b.budgeted_amount, 0))) / 
           NULLIF(SUM(COALESCE(b.budgeted_amount, 0)), 0) * 100, 2) AS variance_percentage,
    COUNT(DISTINCT COALESCE(b.account_id, a.account_id)) AS account_count
FROM budget_plan b
FULL OUTER JOIN actual_results a ON 
    b.account_id = a.account_id 
    AND b.department_id = a.department_id 
    AND b.fiscal_year = a.fiscal_year 
    AND b.month = a.month
JOIN chart_of_accounts coa ON COALESCE(b.account_id, a.account_id) = coa.account_id
JOIN departments d ON COALESCE(b.department_id, a.department_id) = d.department_id
GROUP BY b.fiscal_year, d.department_name, d.department_code, coa.account_type
ORDER BY b.fiscal_year, d.department_code, coa.account_type;

-- Top Variances View (for exception reporting)
CREATE VIEW v_top_variances AS
SELECT 
    b.fiscal_year,
    b.month,
    d.department_name,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    COALESCE(b.budgeted_amount, 0) AS budgeted_amount,
    COALESCE(a.actual_amount, 0) AS actual_amount,
    ABS(COALESCE(a.actual_amount, 0) - COALESCE(b.budgeted_amount, 0)) AS abs_variance,
    ROUND(ABS((COALESCE(a.actual_amount, 0) - COALESCE(b.budgeted_amount, 0)) / 
           NULLIF(COALESCE(b.budgeted_amount, 0), 1)), 2) AS abs_variance_percent
FROM budget_plan b
FULL OUTER JOIN actual_results a ON 
    b.account_id = a.account_id 
    AND b.department_id = a.department_id 
    AND b.fiscal_year = a.fiscal_year 
    AND b.month = a.month
JOIN chart_of_accounts coa ON COALESCE(b.account_id, a.account_id) = coa.account_id
JOIN departments d ON COALESCE(b.department_id, a.department_id) = d.department_id
WHERE ABS(COALESCE(a.actual_amount, 0) - COALESCE(b.budgeted_amount, 0)) > 50000
ORDER BY abs_variance DESC;

COMMIT;
