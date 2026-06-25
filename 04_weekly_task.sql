-- ============================================================
-- B2B Sales Intelligence - Weekly Intelligence Refresh Task
-- Runs every Sunday at 02:00 UTC
-- ============================================================

USE SCHEMA TELCO_AI_DEMO.B2B_SALES;

-- Stored procedure: calls Brave Search for all active companies
CREATE OR REPLACE PROCEDURE REFRESH_COMPANY_INTELLIGENCE_SP()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = 'Iterates over all active companies, calls Brave Search API, inserts results into COMPANY_INTELLIGENCE'
AS
$$
BEGIN
    INSERT INTO TELCO_AI_DEMO.B2B_SALES.COMPANY_INTELLIGENCE 
        (COMPANY_ID, SEARCH_QUERY, TITLE, SNIPPET, URL, SOURCE_TYPE, RELEVANCE_SCORE)
    SELECT 
        c.COMPANY_ID,
        c.COMPANY_NAME || ' Netherlands business news' AS SEARCH_QUERY,
        r.value:title::VARCHAR AS TITLE,
        r.value:snippet::VARCHAR AS SNIPPET,
        r.value:url::VARCHAR AS URL,
        'NEWS' AS SOURCE_TYPE,
        1.0 AS RELEVANCE_SCORE
    FROM TELCO_AI_DEMO.B2B_SALES.DIM_COMPANY c,
    LATERAL FLATTEN(
        input => TELCO_AI_DEMO.B2B_SALES.BRAVE_COMPANY_SEARCH(c.COMPANY_NAME, 'Netherlands business news')
    ) r
    WHERE c.IS_ACTIVE = TRUE
      AND r.value:error IS NULL;

    RETURN 'Company intelligence refresh completed at ' || CURRENT_TIMESTAMP()::VARCHAR;
END;
$$;

-- Weekly CRON task
CREATE OR REPLACE TASK REFRESH_COMPANY_INTELLIGENCE
  WAREHOUSE = COMPUTE_WH
  SCHEDULE = 'USING CRON 0 2 * * SUN UTC'
  COMMENT = 'Weekly refresh of company intelligence via Brave Search API - runs Sunday 02:00 UTC'
AS
  CALL TELCO_AI_DEMO.B2B_SALES.REFRESH_COMPANY_INTELLIGENCE_SP();

-- Resume the task (tasks start suspended by default)
ALTER TASK REFRESH_COMPANY_INTELLIGENCE RESUME;
