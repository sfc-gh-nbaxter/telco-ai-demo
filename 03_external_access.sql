-- ============================================================
-- B2B Sales Intelligence - Brave Search External Access
-- Creates network rule, secret, integration, and Python UDF
-- ============================================================
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- ARCHITECTURE TEAM APPROVAL REQUIRED
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--
-- This script creates a network egress rule that allows outbound
-- HTTPS traffic from Snowflake to api.search.brave.com.
--
-- Before deploying to production, ensure this has been reviewed
-- and approved by your Architecture/Security team.
--
-- What is transmitted:
--   - Company names + search context (e.g., "Shell Netherlands business news")
--   - NO PII, NO internal business data, NO credentials
--
-- Security controls in place:
--   - Egress restricted to single host: api.search.brave.com (port 443 only)
--   - API key stored as Snowflake SECRET (encrypted at rest, RBAC-controlled)
--   - Brave free tier enforces 2,000 queries/month hard cap
--   - UDF accessible only to roles granted USAGE
--
-- Alternative (no external access needed):
--   If this integration is NOT approved, you can still use the
--   built-in web_search agent tool (managed by Snowflake, ZDR-enabled).
--   Simply skip this script and remove CompanyIntelligenceSearch
--   from the agent specification in 06_cortex_agent.sql.
--
-- ============================================================

USE SCHEMA TELCO_AI_DEMO.B2B_SALES;

-- Network rule for Brave Search API
CREATE OR REPLACE NETWORK RULE BRAVE_NETWORK_RULE
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('api.search.brave.com')
  COMMENT = 'Egress rule for Brave Web Search API calls';

-- Secret for API key (REPLACE with your real key from https://brave.com/search/api/)
CREATE OR REPLACE SECRET BRAVE_API_KEY_SECRET
  TYPE = GENERIC_STRING
  SECRET_STRING = 'REPLACE_WITH_YOUR_BRAVE_API_KEY'
  COMMENT = 'Brave Search API key for B2B company intelligence gathering';

-- External access integration
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION BRAVE_SEARCH_ACCESS_INTEGRATION
  ALLOWED_NETWORK_RULES = (TELCO_AI_DEMO.B2B_SALES.BRAVE_NETWORK_RULE)
  ALLOWED_AUTHENTICATION_SECRETS = (TELCO_AI_DEMO.B2B_SALES.BRAVE_API_KEY_SECRET)
  ENABLED = TRUE
  COMMENT = 'External access integration for Brave Search API';

-- Python UDF: searches Brave for company intelligence
CREATE OR REPLACE FUNCTION BRAVE_COMPANY_SEARCH(
    COMPANY_NAME VARCHAR, 
    SEARCH_CONTEXT VARCHAR DEFAULT 'Netherlands business news'
)
RETURNS VARIANT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
HANDLER = 'search_company'
EXTERNAL_ACCESS_INTEGRATIONS = (BRAVE_SEARCH_ACCESS_INTEGRATION)
PACKAGES = ('requests')
SECRETS = ('brave_api_key' = TELCO_AI_DEMO.B2B_SALES.BRAVE_API_KEY_SECRET)
COMMENT = 'Searches Brave Web Search API for company intelligence. Returns up to 5 recent results as JSON array.'
AS
$$
import _snowflake
import requests
import json

session = requests.Session()

def search_company(company_name, search_context):
    api_key = _snowflake.get_generic_secret_string('brave_api_key')
    url = "https://api.search.brave.com/res/v1/web/search"
    headers = {
        "Accept": "application/json",
        "Accept-Encoding": "gzip",
        "X-Subscription-Token": api_key
    }
    params = {
        "q": f"{company_name} {search_context}",
        "count": 5,
        "freshness": "pw"
    }
    try:
        response = session.get(url, headers=headers, params=params, timeout=10)
        if response.status_code == 200:
            data = response.json()
            results = []
            for item in data.get("web", {}).get("results", []):
                results.append({
                    "title": item.get("title", ""),
                    "snippet": item.get("description", ""),
                    "url": item.get("url", ""),
                    "age": item.get("age", "")
                })
            return results
        else:
            return [{"error": f"HTTP {response.status_code}", "detail": response.text[:500]}]
    except Exception as e:
        return [{"error": "request_failed", "detail": str(e)[:500]}]
$$;
