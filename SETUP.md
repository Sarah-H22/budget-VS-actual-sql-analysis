# Setup & Installation Guide

Complete instructions for setting up and running the Budget vs Actual SQL Analysis project.

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Installation Steps](#installation-steps)
3. [Database Setup](#database-setup)
4. [Running Queries](#running-queries)
5. [Troubleshooting](#troubleshooting)
6. [Verification Steps](#verification-steps)

---

## System Requirements

### Required Software

- **PostgreSQL 13+** (or later versions)
- **Git** (for cloning the repository)
- **Command-line access** (Terminal, PowerShell, or Command Prompt)

### Recommended Environment

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| PostgreSQL Version | 13 | 14+ |
| RAM | 512 MB | 2+ GB |
| Disk Space | 100 MB | 1+ GB |
| OS | Windows/Mac/Linux | Any |

### Installation Links

- **PostgreSQL Download:** https://www.postgresql.org/download/
- **Git Download:** https://git-scm.com/downloads
- **pgAdmin (Optional):** https://www.pgadmin.org/

---

## Installation Steps

### Step 1: Install PostgreSQL

#### Windows
1. Download PostgreSQL installer from https://www.postgresql.org/download/windows/
2. Run the installer (`.exe` file)
3. Follow installation wizard:
   - Accept default installation path
   - Set `postgres` user password (remember this!)
   - Port: `5432` (default)
   - Locale: `[Default locale]`
4. Click **Finish**
5. (Optional) Uncheck "Stack Builder" checkbox

#### macOS
```bash
# Using Homebrew (recommended)
brew install postgresql@14

# Or download the installer from:
# https://www.postgresql.org/download/macosx/
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

#### Linux (CentOS/RHEL)
```bash
sudo yum install postgresql-server postgresql-contrib
sudo systemctl start postgresql
```

### Step 2: Verify PostgreSQL Installation

Open terminal/command prompt and run:

```bash
psql --version
```

**Expected output:** `psql (PostgreSQL) 13.x` or higher

### Step 3: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/Sarah-H22/budget-VS-actual-sql-analysis.git

# Navigate into the project directory
cd budget-VS-actual-sql-analysis

# List files to verify
ls -la
# You should see: README.md, schema.sql, analysis_queries.sql, SETUP.md
```

### Step 4: Verify Repository Contents

```bash
# Check that required files exist
cat README.md          # Should display README content
cat schema.sql         # Should display schema content
cat analysis_queries.sql # Should display queries content
```

---

## Database Setup

### Step 1: Create the Database

Open a terminal/command prompt and run:

```bash
# Login to PostgreSQL as admin
psql -U postgres

# You'll be prompted for the password you set during installation
# After login, you'll see the psql prompt: postgres=#
```

Once in psql, run:

```sql
-- Create the database
CREATE DATABASE fpa_banking_db;

-- Verify creation
\l

-- You should see 'fpa_banking_db' in the list
```

Exit psql:
```sql
\q
```

### Step 2: Load the Schema & Sample Data

From your terminal (in the project directory):

```bash
# Load schema.sql into the database
psql -U postgres -d fpa_banking_db -f schema.sql

# Expected output: Multiple "CREATE TABLE", "INSERT", and "CREATE VIEW" success messages
```

**What this does:**
- Creates 4 tables (departments, chart_of_accounts, budget_plan, actual_results)
- Creates 3 views (v_budget_vs_actual_summary, v_department_variance, v_top_variances)
- Inserts sample banking data
- Creates indexes for performance

### Step 3: Verify Database Setup

```bash
# Connect to the database
psql -U postgres -d fpa_banking_db

# Run verification queries
\dt                    # List all tables (should show 4 tables)
\dv                    # List all views (should show 3 views)
\d departments         # Show departments table structure
```

Sample output:
```
        List of relations
 Schema |        Name         | Type  | Owner
--------+---------------------+-------+----------
 public | actual_results      | table | postgres
 public | budget_plan         | table | postgres
 public | chart_of_accounts   | table | postgres
 public | departments         | table | postgres
 public | v_budget_vs_actual_summary | view | postgres
 public | v_department_variance | view | postgres
 public | v_top_variances     | view | postgres
```

Check data loaded:
```sql
SELECT COUNT(*) FROM departments;        -- Should return 6
SELECT COUNT(*) FROM chart_of_accounts;  -- Should return 20
SELECT COUNT(*) FROM budget_plan;        -- Should return 72
SELECT COUNT(*) FROM actual_results;     -- Should return 54
```

Exit psql:
```
\q
```

---

## Running Queries

### Method 1: Run All Queries from File

```bash
# From your project directory
psql -U postgres -d fpa_banking_db -f analysis_queries.sql

# This will execute all 12 queries and display results
```

### Method 2: Interactive Query Execution

```bash
# Start psql in interactive mode
psql -U postgres -d fpa_banking_db

# Copy and paste any query from analysis_queries.sql
# Execute with semicolon (;) at the end
# Results will display in the terminal
```

### Method 3: Save Query Results to File

```bash
# Save output to a CSV file
psql -U postgres -d fpa_banking_db -f analysis_queries.sql -o results.csv

# Or with formatting:
psql -U postgres -d fpa_banking_db \
  -c "SELECT * FROM v_budget_vs_actual_summary LIMIT 10;" \
  -o query_output.csv

# View the file
cat results.csv
```

### Method 4: Use a GUI Tool (pgAdmin)

1. **Install pgAdmin** (optional GUI client)
2. Open pgAdmin web interface
3. Register PostgreSQL server:
   - Host: `localhost`
   - Port: `5432`
   - Username: `postgres`
   - Password: (your password)
4. Navigate to: Databases → fpa_banking_db → Query Tool
5. Paste queries and click **Execute**

---

## Example Query Execution

### Query 1: Monthly Variance Summary

```bash
psql -U postgres -d fpa_banking_db
```

Then paste:

```sql
SELECT 
    department_name,
    month,
    SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END) AS revenue_budget,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) AS revenue_actual,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
    SUM(CASE WHEN account_type = 'Revenue' THEN budgeted_amount ELSE 0 END) AS revenue_variance
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY department_name, month
ORDER BY month DESC
LIMIT 10;
```

**Expected output:**
```
      department_name      | month | revenue_budget | revenue_actual | revenue_variance
---------------------------+-------+----------------+----------------+------------------
 Retail Banking            |     6 |        3025000 |        3577000 |            552000
 Commercial Banking        |     6 |        3450000 |        3520000 |             70000
 Investment Banking        |     6 |        1200000 |        1185000 |            -15000
 Retail Banking            |     5 |        2980000 |        3090000 |            110000
 ...
```

### Query 2: Top Variances (Exception Report)

```sql
SELECT 
    department_name,
    account_code,
    account_name,
    month,
    budgeted_amount,
    actual_amount,
    ABS(actual_amount - budgeted_amount) AS abs_variance
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026 
  AND ABS(actual_amount - budgeted_amount) > 50000
ORDER BY ABS(actual_amount - budgeted_amount) DESC
LIMIT 10;
```

### Query 3: Department P&L Summary

```sql
SELECT 
    department_code,
    department_name,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) AS actual_revenue,
    SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS actual_expenses,
    SUM(CASE WHEN account_type = 'Revenue' THEN actual_amount ELSE 0 END) - 
    SUM(CASE WHEN account_type = 'Expense' THEN actual_amount ELSE 0 END) AS actual_profit
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY department_code, department_name
ORDER BY actual_profit DESC;
```

---

## Troubleshooting

### Issue: "psql: command not found"

**Solution:** PostgreSQL is not in your system PATH

**Windows:**
```bash
# Find PostgreSQL bin directory
# Typically: C:\Program Files\PostgreSQL\14\bin

# Add to PATH:
setx PATH "%PATH%;C:\Program Files\PostgreSQL\14\bin"

# Restart command prompt and try again
psql --version
```

**macOS/Linux:**
```bash
# Add to PATH in ~/.bash_profile or ~/.zshrc
export PATH="/usr/local/opt/postgresql@14/bin:$PATH"

# Reload
source ~/.bash_profile
psql --version
```

---

### Issue: "FATAL: Ident authentication failed for user 'postgres'"

**Solution:** Password authentication issue

```bash
# Try connecting with password prompt
psql -U postgres -W

# Or specify the host explicitly
psql -h localhost -U postgres -d fpa_banking_db
```

---

### Issue: "Database 'fpa_banking_db' does not exist"

**Solution:** Database wasn't created

```bash
# Check if database exists
psql -U postgres -l | grep fpa_banking_db

# If not shown, create it:
psql -U postgres
CREATE DATABASE fpa_banking_db;
\q

# Then load schema:
psql -U postgres -d fpa_banking_db -f schema.sql
```

---

### Issue: "ERROR: relation does not exist"

**Solution:** Schema wasn't loaded properly

```bash
# Verify tables exist
psql -U postgres -d fpa_banking_db -c "\dt"

# If empty, reload schema
psql -U postgres -d fpa_banking_db -f schema.sql

# Verify load was successful
psql -U postgres -d fpa_banking_db -c "SELECT COUNT(*) FROM departments;"
```

---

### Issue: "Permission denied" or "Access denied"

**Solution:** Check user permissions

```bash
# List users
psql -U postgres -c "\du"

# Grant privileges if needed
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE fpa_banking_db TO postgres;"
```

---

## Verification Steps

### Complete Verification Script

Save as `verify_setup.sql`:

```sql
-- Verification Script for Budget vs Actual Analysis Database

\echo '=== DATABASE VERIFICATION ==='
\echo 'Checking database...'
SELECT datname FROM pg_database WHERE datname = 'fpa_banking_db';

\echo ''
\echo '=== TABLE VERIFICATION ==='
SELECT tablename FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

\echo ''
\echo '=== VIEW VERIFICATION ==='
SELECT viewname FROM pg_views 
WHERE schemaname = 'public' 
ORDER BY viewname;

\echo ''
\echo '=== DATA COUNT VERIFICATION ==='
SELECT 'departments' as table_name, COUNT(*) as row_count FROM departments
UNION ALL
SELECT 'chart_of_accounts', COUNT(*) FROM chart_of_accounts
UNION ALL
SELECT 'budget_plan', COUNT(*) FROM budget_plan
UNION ALL
SELECT 'actual_results', COUNT(*) FROM actual_results;

\echo ''
\echo '=== SAMPLE DATA VERIFICATION ==='
\echo 'Departments:'
SELECT * FROM departments LIMIT 3;

\echo ''
\echo 'Sample Budget Data:'
SELECT * FROM budget_plan LIMIT 3;

\echo ''
\echo 'Sample Actual Data:'
SELECT * FROM actual_results LIMIT 3;

\echo ''
\echo '=== VIEW FUNCTIONALITY VERIFICATION ==='
\echo 'Budget vs Actual Summary View:'
SELECT * FROM v_budget_vs_actual_summary LIMIT 3;

\echo ''
\echo '✅ VERIFICATION COMPLETE'
```

Run verification:

```bash
psql -U postgres -d fpa_banking_db -f verify_setup.sql
```

**Expected results:**
- All 4 tables listed
- All 3 views listed
- Row counts: departments(6), chart_of_accounts(20+), budget_plan(72), actual_results(54)
- Sample data displays correctly
- Views return results

---

## Next Steps

### 1. Explore the Data

```bash
psql -U postgres -d fpa_banking_db

-- View all departments
SELECT * FROM departments;

-- View GL account structure
SELECT account_code, account_name, account_type, category 
FROM chart_of_accounts 
ORDER BY account_code;

-- Sample budget data
SELECT * FROM budget_plan WHERE month = 1 LIMIT 5;

-- Sample actual results
SELECT * FROM actual_results WHERE month = 1 LIMIT 5;
```

### 2. Run Analysis Queries

Execute all queries from `analysis_queries.sql`:

```bash
psql -U postgres -d fpa_banking_db -f analysis_queries.sql | head -100
```

Or run specific queries for detailed analysis.

### 3. Create Custom Queries

Connect interactively and create your own analysis:

```bash
psql -U postgres -d fpa_banking_db

-- Create custom analysis
SELECT 
    department_name,
    account_type,
    SUM(actual_amount) as total_actual,
    SUM(budgeted_amount) as total_budget
FROM v_budget_vs_actual_summary
WHERE fiscal_year = 2026
GROUP BY department_name, account_type
ORDER BY department_name;
```

### 4. Export Results

```bash
# Export to CSV
psql -U postgres -d fpa_banking_db \
  -c "COPY (SELECT * FROM v_budget_vs_actual_summary WHERE fiscal_year = 2026) 
       TO STDOUT WITH CSV HEADER;" > variance_report.csv

# Export to JSON (PostgreSQL 13+)
psql -U postgres -d fpa_banking_db \
  -c "SELECT json_agg(row_to_json(t)) 
       FROM (SELECT * FROM departments) t;" > departments.json
```

---

## Performance Optimization

### Create Additional Indexes

For large datasets, create these indexes:

```sql
CREATE INDEX idx_budget_fy_dept_month ON budget_plan(fiscal_year, department_id, month);
CREATE INDEX idx_actual_fy_dept_month ON actual_results(fiscal_year, department_id, month);
CREATE INDEX idx_coa_account_type ON chart_of_accounts(account_type, category);
```

### Analyze Query Performance

```sql
-- View query execution plan
EXPLAIN ANALYZE
SELECT * FROM v_budget_vs_actual_summary 
WHERE fiscal_year = 2026 AND department_id = 1;
```

---

## Database Backup & Restore

### Backup the Database

```bash
# Full backup
pg_dump -U postgres fpa_banking_db > backup_fpa_banking.sql

# Or backup to custom format
pg_dump -U postgres -Fc fpa_banking_db > backup_fpa_banking.dump
```

### Restore from Backup

```bash
# From SQL file
psql -U postgres -d fpa_banking_db -f backup_fpa_banking.sql

# From custom format
pg_restore -U postgres -d fpa_banking_db backup_fpa_banking.dump
```

---

## Quick Reference Commands

```bash
# Connect to database
psql -U postgres -d fpa_banking_db

# Run a file
psql -U postgres -d fpa_banking_db -f filename.sql

# Run a single command
psql -U postgres -d fpa_banking_db -c "SELECT * FROM departments;"

# Run and save output
psql -U postgres -d fpa_banking_db -f query.sql -o output.txt

# Run with timing
psql -U postgres -d fpa_banking_db
\timing on
SELECT * FROM large_query;

# Export to CSV
psql -U postgres -d fpa_banking_db -c "COPY (SELECT...) TO STDOUT WITH CSV HEADER;" > file.csv
```

### PostgreSQL psql Commands

```sql
\l              -- List databases
\dt             -- List tables
\dv             -- List views
\di             -- List indexes
\du             -- List users
\d tablename    -- Show table structure
\c dbname       -- Connect to database
\q              -- Quit
\? or \h        -- Help
\timing on/off  -- Toggle query timing
```

---

## Additional Resources

- **PostgreSQL Documentation:** https://www.postgresql.org/docs/
- **SQL Tutorial:** https://www.postgresql.org/docs/current/tutorial.html
- **pgAdmin Documentation:** https://www.pgadmin.org/docs/
- **Query Optimization:** https://www.postgresql.org/docs/current/using-explain.html

---

## Support & Troubleshooting

If you encounter issues:

1. **Check PostgreSQL is running:**
   ```bash
   psql -U postgres -c "SELECT version();"
   ```

2. **Verify database exists:**
   ```bash
   psql -U postgres -l | grep fpa_banking_db
   ```

3. **Verify tables and views:**
   ```bash
   psql -U postgres -d fpa_banking_db -c "\dt"
   psql -U postgres -d fpa_banking_db -c "\dv"
   ```

4. **Check recent error logs:**
   ```bash
   # Windows
   type "%ProgramFiles%\PostgreSQL\14\data\log\*"
   
   # macOS/Linux
   tail -f /var/lib/postgresql/14/main/postgresql.log
   ```

5. **Test a simple query:**
   ```bash
   psql -U postgres -d fpa_banking_db -c "SELECT 1;"
   ```

---

**Last Updated:** May 14, 2026  
**Status:** Ready to Use ✅

For questions or issues, refer to the main [README.md](README.md)
