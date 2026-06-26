-- ============================================================
-- B2B Sales Intelligence - FinOps: Cost Monitoring & Optimization
-- Run these queries to track and manage solution costs
-- ============================================================

-- ============================================================
-- SECTION 1: ESTIMATED MONTHLY COSTS
-- ============================================================
/*
    Component                          | Credits/Run | Runs/Month | Monthly Credits | Est. Cost/Month
    -----------------------------------|-------------|------------|-----------------|----------------
    Weekly Task (COMPUTE_WH XS, ~2m)   | 0.033       | 4          | 0.13            | ~EUR 0.26
    Agent queries (Cortex Analyst)      | 0.02/query  | 50         | 1.00            | ~EUR 2.00
    Agent orchestration (LLM tokens)    | varies      | 50         | 0.50            | ~EUR 1.00
    Web Search invocations (Brave ZDR)  | included    | 20         | included        | EUR 0.00
    Custom tool UDF calls (XS WH)      | 0.017/call  | 10         | 0.17            | ~EUR 0.34
    Storage (< 5 MB total)             | negligible  | -          | negligible      | < EUR 0.01
    -----------------------------------|-------------|------------|-----------------|----------------
    TOTAL ESTIMATE (light demo usage)  |             |            | ~1.8 credits    | ~EUR 3.60/month
    TOTAL ESTIMATE (heavy demo usage)  |             |            | ~5.0 credits    | ~EUR 10.00/month

    External API:
    - Brave Search Free tier: 2,000 queries/month (plenty for 50 companies x 5 results x 4 weeks = 1,000 calls)
    - Brave Search Pro tier: EUR 5/month for 20,000 queries if needed

    Notes:
    - Costs assume XS warehouse (1 credit/hour = ~EUR 2/hour)
    - Cortex AI credits follow the Snowflake Service Consumption Table
    - Web search (built-in agent tool) is included in Cortex Agents pricing
*/

-- ============================================================
-- SECTION 2: MONITOR ACTUAL COSTS
-- ============================================================

-- 2a. Overall credit usage by service type (last 30 days)
SELECT 
    start_time::DATE AS usage_date,
    service_type,
    name AS resource_name,
    SUM(credits_used) AS credits_used
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
WHERE start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
  AND (service_type IN ('SERVERLESS_TASK', 'AI_SERVICES', 'WAREHOUSE_METERING')
       OR name = 'COMPUTE_WH')
GROUP BY 1, 2, 3
ORDER BY usage_date DESC, credits_used DESC;

-- 2b. Weekly task run history and cost (warehouse-based task)
-- Note: This task uses COMPUTE_WH (not serverless), so we estimate credits from runtime
SELECT 
    SCHEDULED_TIME::DATE AS run_date,
    NAME AS task_name,
    STATE,
    DATEDIFF('second', QUERY_START_TIME, COMPLETED_TIME) AS runtime_seconds,
    -- Cost estimate: XS warehouse = 1 credit/hour
    ROUND(DATEDIFF('second', QUERY_START_TIME, COMPLETED_TIME) / 3600.0, 4) AS estimated_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY
WHERE DATABASE_NAME = 'TELCO_AI_DEMO' 
  AND SCHEMA_NAME = 'B2B_SALES'
  AND NAME = 'REFRESH_COMPANY_INTELLIGENCE'
  AND SCHEDULED_TIME >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
ORDER BY SCHEDULED_TIME DESC;

-- 2c. Cortex Agent usage (credits and tokens consumed)
SELECT 
    start_time::DATE AS usage_date,
    AGENT_NAME,
    SUM(TOKEN_CREDITS) AS total_credits,
    SUM(TOKENS) AS total_tokens,
    COUNT(*) AS num_requests
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY
WHERE start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
  AND AGENT_NAME = 'B2B_SALES_AGENT'
GROUP BY 1, 2
ORDER BY usage_date DESC;

-- 2d. Warehouse usage by the weekly task
SELECT 
    start_time::DATE AS day,
    warehouse_name,
    SUM(credits_used) AS credits,
    SUM(credits_used_compute) AS compute_credits,
    SUM(credits_used_cloud_services) AS cloud_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name = 'COMPUTE_WH'
  AND start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
GROUP BY 1, 2
ORDER BY day DESC;

-- ============================================================
-- SECTION 3: SET UP BUDGET ALERTS (optional)
-- ============================================================

/*
-- Create a budget to alert when agent costs exceed EUR 20/month:

CREATE OR REPLACE BUDGET TELCO_AI_DEMO.B2B_SALES.B2B_AGENT_BUDGET
  WITH CREDIT_QUOTA = 10  -- ~EUR 20 worth of credits
  FREQUENCY = MONTHLY
  START_TIMESTAMP = CURRENT_TIMESTAMP();

-- Add notification when 80% of budget is consumed:
ALTER BUDGET TELCO_AI_DEMO.B2B_SALES.B2B_AGENT_BUDGET
  ADD NOTIFICATION_INTEGRATION = MY_EMAIL_NOTIFICATION
  AT 80 PERCENT;
*/

-- ============================================================
-- SECTION 4: OPTIMIZATION RECOMMENDATIONS
-- ============================================================

/*
COST OPTIMIZATION STRATEGIES:

1. WAREHOUSE SIZING
   - The weekly task processes 50 companies sequentially
   - XS warehouse is sufficient (1 credit/hour)
   - Do NOT upsize unless task exceeds 10 minutes

2. TASK SCHEDULING
   - Weekly is optimal for demo purposes
   - For production: consider bi-weekly if news freshness isn't critical
   - To pause during inactive periods:
     ALTER TASK TELCO_AI_DEMO.B2B_SALES.REFRESH_COMPANY_INTELLIGENCE SUSPEND;

3. BRAVE API USAGE
   - Free tier: 2,000 queries/month
   - Current usage: ~1,000/month (50 companies x 5 results x 4 weeks)
   - If you exceed: reduce to 3 results per company or search bi-weekly

4. AGENT QUERY OPTIMIZATION
   - Semantic view verified queries reduce LLM token usage
   - Add more verified queries for common questions
   - Set appropriate orchestration budget (currently 60s / 16K tokens)

5. DATA RETENTION
   - COMPANY_INTELLIGENCE grows ~250 rows/week (~13,000/year)
   - Consider purging data older than 6 months:
     DELETE FROM TELCO_AI_DEMO.B2B_SALES.COMPANY_INTELLIGENCE
     WHERE SEARCH_DATE < DATEADD(MONTH, -6, CURRENT_TIMESTAMP());

6. SERVERLESS TASKS (alternative)
   - Remove WAREHOUSE parameter from task to use serverless compute
   - May reduce costs for short-running tasks (billed per-second)
   - Trade-off: less predictable pricing
*/

-- ============================================================
-- SECTION 5: QUICK HEALTH CHECK
-- ============================================================

-- Check task is running successfully (uses ACCOUNT_USAGE for 30-day lookback)
-- Note: INFORMATION_SCHEMA.TASK_HISTORY only supports 7-day lookback
SELECT NAME, STATE, SCHEDULED_TIME, COMPLETED_TIME, ERROR_MESSAGE
FROM SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY
WHERE DATABASE_NAME = 'TELCO_AI_DEMO'
  AND SCHEMA_NAME = 'B2B_SALES'
  AND NAME = 'REFRESH_COMPANY_INTELLIGENCE'
  AND SCHEDULED_TIME >= DATEADD(DAY, -30, CURRENT_TIMESTAMP())
ORDER BY SCHEDULED_TIME DESC
LIMIT 10;

-- Check intelligence table growth
SELECT 
    DATE_TRUNC('week', SEARCH_DATE) AS week,
    COUNT(*) AS rows_added,
    COUNT(DISTINCT COMPANY_ID) AS companies_covered
FROM TELCO_AI_DEMO.B2B_SALES.COMPANY_INTELLIGENCE
GROUP BY 1
ORDER BY week DESC
LIMIT 8;

-- Verify data freshness
SELECT 
    MAX(SEARCH_DATE) AS latest_search,
    DATEDIFF(DAY, MAX(SEARCH_DATE), CURRENT_TIMESTAMP()) AS days_since_last_refresh,
    COUNT(*) AS total_intelligence_rows
FROM TELCO_AI_DEMO.B2B_SALES.COMPANY_INTELLIGENCE;

-- ============================================================
-- SECTION 6: SNOWSIGHT UI NAVIGATION FOR FINOPS
-- ============================================================

/*
You can also monitor costs WITHOUT writing SQL using the Snowsight UI:

1. OVERALL CREDIT CONSUMPTION
   Navigate: Admin > Cost Management > Consumption
   - Filter by "Warehouse" to see COMPUTE_WH usage (weekly task)
   - Filter by "Serverless" > "AI Services" to see Cortex Agent credits
   - Use the date range picker to compare month-over-month
   - Export to CSV for chargeback reporting

2. BUDGET MANAGEMENT
   Navigate: Admin > Cost Management > Budgets
   - Create a new budget scoped to the B2B_SALES schema
   - Set monthly credit limit (recommended: 10 credits = ~EUR 20)
   - Configure email notifications at 50%, 80%, and 100% thresholds
   - View spend-vs-budget trend graph

3. AGENT-SPECIFIC USAGE
   Navigate: AI & ML > Agents > B2B_SALES_AGENT
   - View request count, token usage, and latency metrics
   - Identify peak usage periods
   - Review which tools are invoked most often

4. TASK MONITORING
   Navigate: Monitoring > Task History
   - Filter: Database = TELCO_AI_DEMO, Schema = B2B_SALES
   - Check for FAILED or SKIPPED runs (red/orange indicators)
   - Click a run to see execution details and error messages
   - Verify the task completes in < 5 minutes

5. QUERY HISTORY (for debugging)
   Navigate: Activity > Query History
   - Filter: Warehouse = COMPUTE_WH
   - Filter: User = SYSTEM (tasks run as system)
   - Sort by Duration to find slow queries
   - Check for queries from the BRAVE_COMPANY_SEARCH UDF

6. WAREHOUSE ACTIVITY
   Navigate: Admin > Warehouses > COMPUTE_WH
   - Check "Auto-suspend" is set to 60 seconds (default)
   - Verify warehouse is not running 24/7 due to other workloads
   - If shared with other workloads, consider a dedicated XS warehouse

KEY METRICS TO WATCH WEEKLY:
   - Total credits consumed by B2B_SALES_AGENT (target: < 2 credits/week)
   - Task success rate (target: 100% -- check for Brave API failures)
   - COMPANY_INTELLIGENCE row count growth (~250 rows/week expected)
   - Warehouse idle time (should auto-suspend within 60s after task)
*/
