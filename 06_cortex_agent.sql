-- ============================================================
-- B2B Sales Intelligence - Cortex Agent
-- 4 tools: SalesAnalytics, WebSearch, CompanyIntelligenceSearch, data_to_chart
-- ============================================================

-- PREREQUISITE: Enable web search at account level:
-- Snowsight > AI & ML > Agents > Settings > toggle "Web search" ON

USE SCHEMA TELCO_AI_DEMO.B2B_SALES;

CREATE OR REPLACE AGENT B2B_SALES_AGENT
  COMMENT = 'B2B Sales Intelligence Agent for top 50 Dutch enterprise accounts'
  FROM SPECIFICATION
$$
{
  "models": {
    "orchestration": "auto"
  },
  "orchestration": {
    "budget": {
      "seconds": 60,
      "tokens": 16000
    }
  },
  "instructions": {
    "response": "You are a B2B sales intelligence assistant for a Dutch telecom company. You help account managers understand their enterprise customers (top 50 Dutch companies), analyze sales performance, and access the latest company news and intelligence. Always be specific with numbers and cite the data source. When discussing revenue, use EUR currency formatting. Present data in tables when comparing multiple items.",
    "orchestration": "For sales performance questions (revenue, deals, pipeline, trends, quotas, products, reps), use the SalesAnalytics tool. For real-time current news or live internet information about a specific company or market event, use the WebSearch tool. For stored historical intelligence from past weekly Brave API scans, use CompanyIntelligenceSearch. When the user asks for charts or visualizations, use data_to_chart after retrieving data.",
    "sample_questions": [
      {"question": "What is our total revenue from Shell this year?"},
      {"question": "Which companies have contracts expiring in the next 3 months?"},
      {"question": "Show me the revenue trend by quarter for our top 5 accounts"},
      {"question": "What is the latest news about ASML?"},
      {"question": "Which sales rep has the best win rate?"},
      {"question": "Search the internet for recent Adyen acquisitions"}
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "SalesAnalytics",
        "description": "Queries the B2B sales data warehouse containing sales transactions, company information, product details, and sales rep performance for the top 50 Dutch enterprise accounts. Use for questions about revenue, deals, pipeline, quotas, win rates, product mix, account health, contract dates, and account tiers. Covers data from 2024-2025."
      }
    },
    {
      "tool_spec": {
        "type": "web_search",
        "name": "WebSearch",
        "description": "Searches the live public internet in real-time for the very latest news, financial updates, market events, and current information about companies or the Dutch telecom industry. Use when the user asks about recent events or breaking news."
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "CompanyIntelligenceSearch",
        "description": "Calls the Brave Search API to search for recent news about a specific company. Returns up to 5 web search results with title, snippet, and URL. Input: company_name (string) and optional search_context (string, defaults to Netherlands business news).",
        "input_schema": {
          "type": "object",
          "properties": {
            "company_name": {
              "type": "string",
              "description": "The name of the company to search for"
            },
            "search_context": {
              "type": "string",
              "description": "Additional context for the search query"
            }
          },
          "required": ["company_name"]
        }
      }
    },
    {
      "tool_spec": {
        "type": "data_to_chart",
        "name": "data_to_chart",
        "description": "Generates visualizations from data returned by other tools"
      }
    }
  ],
  "tool_resources": {
    "SalesAnalytics": {
      "semantic_view": "TELCO_AI_DEMO.B2B_SALES.B2B_SALES_SEMANTIC_VIEW",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "COMPUTE_WH",
        "query_timeout": 120
      }
    },
    "CompanyIntelligenceSearch": {
      "type": "function",
      "identifier": "TELCO_AI_DEMO.B2B_SALES.BRAVE_COMPANY_SEARCH",
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "COMPUTE_WH",
        "query_timeout": 30
      }
    }
  }
}
$$;
