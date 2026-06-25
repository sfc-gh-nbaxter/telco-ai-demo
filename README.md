# B2B Sales Intelligence Agent - TELCO_AI_DEMO

A Snowflake Cortex Agent that provides B2B sales intelligence for a Dutch telecom company's top 50 enterprise accounts.

## Architecture

```
TELCO_AI_DEMO.B2B_SALES
├── Star Schema (DIM_COMPANY, DIM_PRODUCT, DIM_SALES_REP, DIM_DATE, FACT_SALES)
├── COMPANY_INTELLIGENCE table (populated weekly by Brave Search)
├── Semantic View (B2B_SALES_SEMANTIC_VIEW)
├── External Access (Brave Search API via Python UDF)
├── Weekly Task (REFRESH_COMPANY_INTELLIGENCE - Sunday 02:00 UTC)
└── Cortex Agent (B2B_SALES_AGENT - 4 tools)
```

### Agent Tools

| Tool | Type | Purpose |
|------|------|---------|
| SalesAnalytics | Cortex Analyst | Natural language queries over the star schema |
| WebSearch | Web Search (Brave) | Real-time internet search during conversations |
| CompanyIntelligenceSearch | Custom UDF | On-demand Brave API search with structured results |
| data_to_chart | Built-in | Generate visualizations from query results |

## Setup Instructions

### Prerequisites

- Snowflake account with ACCOUNTADMIN role
- Brave Search API key (free tier: https://brave.com/search/api/)
- `COMPUTE_WH` warehouse available

### Deployment Steps

Run the SQL scripts in order:

```bash
# 1. Create schema and tables
snowsql -f 01_schema_and_tables.sql

# 2. Load seed data (50 companies, 10 products, 8 reps, ~1000 sales)
snowsql -f 02_seed_data.sql

# 3. Set up Brave Search external access
snowsql -f 03_external_access.sql

# 4. Create weekly intelligence refresh task
snowsql -f 04_weekly_task.sql

# 5. Create semantic view
snowsql -f 05_semantic_view.sql

# 6. Create the Cortex Agent
snowsql -f 06_cortex_agent.sql
```

### Post-Deployment

1. **Set your Brave API key:**
   ```sql
   ALTER SECRET TELCO_AI_DEMO.B2B_SALES.BRAVE_API_KEY_SECRET
     SET SECRET_STRING = 'your_actual_brave_api_key';
   ```

2. **Enable web search** (one-time, ACCOUNTADMIN):
   - Snowsight > AI & ML > Agents > Settings > toggle "Web search" ON

3. **Test the agent:**
   - Snowsight > AI & ML > Agents > B2B_SALES_AGENT > Playground

## Sample Questions

- "What is our total revenue from Shell this year?"
- "Which sales rep has the highest win rate?"
- "Top 5 companies by deal count in Q1 2025"
- "What products generate the most revenue?"
- "Which companies have contracts expiring in the next 3 months?"
- "What is the latest news about ASML?" (uses web search)
- "Search the internet for recent Adyen acquisitions" (uses web search)

## Cost Estimate

| Category | Monthly Cost |
|----------|-------------|
| Storage (< 5 MB) | < EUR 0.01 |
| Weekly Task (XS warehouse, ~2 min/week) | ~EUR 0.26 |
| Agent queries (~50/month, Cortex AI) | ~EUR 3.00 |
| Custom tool UDF calls (~10/month) | ~EUR 0.34 |
| Brave API (free tier, <1000 calls/month) | EUR 0.00 |
| **Total (light demo)** | **~EUR 3.60/month** |
| **Total (heavy demo, ~150 queries)** | **~EUR 10.00/month** |

See `07_finops_monitoring.sql` for detailed cost monitoring queries, budget alerts, optimization strategies, and health checks.

## Data Model

- **50 companies**: Shell, ASML, Philips, ING, Heineken, Unilever, Ahold Delhaize, and 43 more
- **10 products**: Enterprise SD-WAN, Cloud Connect, Private 5G, UCaaS, IoT Platform, etc.
- **8 sales reps**: Covering Randstad, Zuid-Holland, Noord-Brabant, Utrecht, Noord-Holland, Gelderland, Limburg
- **~1000 transactions**: 2 years of monthly deal data (WON/LOST/PENDING)
- **3 account tiers**: PLATINUM (10), GOLD (14), SILVER (26)

## Monitoring

Track costs with:
```sql
SELECT start_time::date AS day, service_type, SUM(credits_used) AS credits
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
WHERE service_type IN ('SERVERLESS_TASK', 'AI_SERVICES')
  AND start_time >= DATEADD(MONTH, -1, CURRENT_TIMESTAMP())
GROUP BY 1, 2 ORDER BY 1 DESC;
```
