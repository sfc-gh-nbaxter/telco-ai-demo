-- ============================================================
-- B2B Sales Intelligence - Semantic View
-- Powers the Cortex Analyst tool in the agent
-- ============================================================

USE SCHEMA TELCO_AI_DEMO.B2B_SALES;

CREATE OR REPLACE SEMANTIC VIEW B2B_SALES_SEMANTIC_VIEW

  TABLES (
    fact_sales AS TELCO_AI_DEMO.B2B_SALES.FACT_SALES PRIMARY KEY (SALE_ID),
    dim_company AS TELCO_AI_DEMO.B2B_SALES.DIM_COMPANY PRIMARY KEY (COMPANY_ID)
      COMMENT = 'Top 50 Dutch enterprise B2B customer accounts',
    dim_product AS TELCO_AI_DEMO.B2B_SALES.DIM_PRODUCT PRIMARY KEY (PRODUCT_ID)
      COMMENT = 'B2B telecom product catalog',
    dim_sales_rep AS TELCO_AI_DEMO.B2B_SALES.DIM_SALES_REP PRIMARY KEY (REP_ID)
      COMMENT = 'Sales representatives',
    dim_date AS TELCO_AI_DEMO.B2B_SALES.DIM_DATE PRIMARY KEY (DATE_ID)
      COMMENT = 'Date dimension for time-based analysis'
  )

  RELATIONSHIPS (
    fact_sales (COMPANY_ID) REFERENCES dim_company,
    fact_sales (PRODUCT_ID) REFERENCES dim_product,
    fact_sales (REP_ID) REFERENCES dim_sales_rep,
    fact_sales (DATE_ID) REFERENCES dim_date
  )

  FACTS (
    fact_sales.sale_quantity AS QUANTITY
      COMMENT = 'Number of units or licenses in the deal',
    fact_sales.sale_revenue AS TOTAL_REVENUE_EUR
      COMMENT = 'Total deal value in EUR after discount'
  )

  DIMENSIONS (
    dim_company.company_name AS COMPANY_NAME
      COMMENT = 'Name of the Dutch enterprise customer',
    dim_company.industry AS INDUSTRY
      COMMENT = 'Industry vertical: Technology, Financial Services, Energy, Consumer Goods, Retail',
    dim_company.sector AS SECTOR
      COMMENT = 'Specific sector within the industry',
    dim_company.headquarters_city AS HEADQUARTERS_CITY
      COMMENT = 'City in the Netherlands where company is headquartered',
    dim_company.account_tier AS ACCOUNT_TIER
      COMMENT = 'Customer tier: PLATINUM (largest), GOLD (mid), SILVER (smaller)',
    dim_company.account_manager AS ACCOUNT_MANAGER
      COMMENT = 'Name of the assigned account manager',
    dim_company.contract_end_date AS CONTRACT_END_DATE
      COMMENT = 'End date of the current contract',
    dim_product.product_name AS PRODUCT_NAME
      COMMENT = 'Name of the B2B telecom product',
    dim_product.product_category AS PRODUCT_CATEGORY
      COMMENT = 'Category: Network, Cloud, Security, Collaboration, IoT, Wireless, Mobile',
    dim_sales_rep.rep_name AS REP_NAME
      COMMENT = 'Full name of the sales representative',
    dim_sales_rep.rep_region AS REGION
      COMMENT = 'Geographic region the rep covers',
    dim_sales_rep.team AS TEAM
      COMMENT = 'Sales team: Enterprise, Mid-Market, or Growth',
    dim_date.sale_full_date AS FULL_DATE
      COMMENT = 'Date of the transaction',
    dim_date.year_dim AS YEAR
      COMMENT = 'Calendar year (2024 or 2025)',
    dim_date.quarter_dim AS QUARTER
      COMMENT = 'Calendar quarter (1-4)',
    dim_date.month_name_dim AS MONTH_NAME
      COMMENT = 'Three-letter month abbreviation',
    fact_sales.deal_status AS DEAL_STATUS
      COMMENT = 'Status of the deal: WON, LOST, or PENDING'
  )

  METRICS (
    fact_sales.total_revenue AS SUM(TOTAL_REVENUE_EUR)
      COMMENT = 'Total revenue in EUR across all deals',
    fact_sales.won_revenue AS SUM(CASE WHEN DEAL_STATUS = 'WON' THEN TOTAL_REVENUE_EUR ELSE 0 END)
      COMMENT = 'Total revenue from WON deals only',
    fact_sales.deal_count AS COUNT(SALE_ID)
      COMMENT = 'Total number of deals',
    fact_sales.won_deal_count AS COUNT(CASE WHEN DEAL_STATUS = 'WON' THEN SALE_ID END)
      COMMENT = 'Number of WON deals',
    fact_sales.avg_deal_size AS AVG(CASE WHEN DEAL_STATUS = 'WON' THEN TOTAL_REVENUE_EUR END)
      COMMENT = 'Average deal size in EUR for WON deals',
    fact_sales.total_quantity AS SUM(QUANTITY)
      COMMENT = 'Total units or licenses sold'
  )

  COMMENT = 'B2B Sales Intelligence - 50 top Dutch enterprise accounts, 10 telecom products, 8 sales reps, 2 years of data';
