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

-- 2b. Task-specific cost tracking
SELECT 
    start_time::DATE AS run_date,
    task_name,
    SUM(credits_used) AS credits_consumed,
    COUNT(*) AS num_runs,
    AVG(credits_used) AS avg_credits_per_run
FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.SERVERLESS_TASK_HISTORY(
    DATE_RANGE_START => DATEADD(MONTH, -1, CURRENT_TIMESTAMP()),
    DATE_RANGE_END => CURRENT_TIMESTAMP()
))
WHERE database_name = 'TELCO_AI_DEMO' AND schema_name = 'B2B_SALES'
GROUP BY 1, 2
ORDER BY run_date DESC;

-- 2c. Cortex Agent usage (if using CORTEX_AGENT_USAGE_HISTORY view)
SELECT 
    start_time::DATE AS usage_date,
    agent_name,
    SUM(credits_used) AS total_credits,
    COUNT(*) AS num_requests
FROM SNOWFLAKE.ACCOUNT_USAGE.CORTEX_AGENT_USAGE_HISTORY
WHERE start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
  AND agent_name = 'B2B_SALES_AGENT'
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

-- Check task is running successfully
SELECT name, state, scheduled_time, completed_time, error_message
FROM TABLE(TELCO_AI_DEMO.INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'REFRESH_COMPANY_INTELLIGENCE',
    SCHEDULED_TIME_RANGE_START => DATEADD(DAY, -30, CURRENT_TIMESTAMP())
))
ORDER BY scheduled_time DESC
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
