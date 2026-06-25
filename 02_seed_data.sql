-- ============================================================
-- B2B Sales Intelligence - Seed Data
-- Populates dimension tables with realistic Dutch company data
-- ============================================================

USE SCHEMA TELCO_AI_DEMO.B2B_SALES;

-- Sales Reps
INSERT INTO DIM_SALES_REP (REP_ID, REP_NAME, REGION, TEAM, HIRE_DATE, QUOTA_EUR)
VALUES
(1,'Jan de Vries','Randstad','Enterprise','2019-03-15',2500000),
(2,'Sophie van den Berg','Randstad','Enterprise','2020-06-01',2200000),
(3,'Lars Bakker','Zuid-Holland','Mid-Market','2021-01-10',1800000),
(4,'Emma Jansen','Noord-Brabant','Mid-Market','2020-09-01',1800000),
(5,'Pieter de Groot','Utrecht','Growth','2022-02-15',1500000),
(6,'Anna Visser','Noord-Holland','Growth','2022-08-01',1500000),
(7,'Thomas Mulder','Gelderland','Growth','2023-03-01',1200000),
(8,'Lisa de Jong','Limburg','Growth','2023-06-15',1200000);

-- Products
INSERT INTO DIM_PRODUCT (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, MONTHLY_LIST_PRICE_EUR, DESCRIPTION)
VALUES
(1,'Enterprise SD-WAN','Network',4500,'Software-defined wide area network for multi-site enterprise connectivity with dynamic routing'),
(2,'Dedicated Internet Access','Network',2800,'Guaranteed symmetric bandwidth with SLA-backed uptime for business-critical operations'),
(3,'Cloud Connect','Cloud',3200,'Private low-latency connections to AWS, Azure, and GCP cloud platforms'),
(4,'Managed Firewall','Security',1800,'Next-gen firewall as a service with threat detection, IPS, and 24/7 SOC monitoring'),
(5,'Unified Communications (UCaaS)','Collaboration',35,'Per-user unified communications with voice, video, messaging, and contact center'),
(6,'IoT Connectivity Platform','IoT',2200,'Managed connectivity for industrial IoT devices with global SIM management'),
(7,'Private 5G Network','Wireless',8500,'Dedicated on-premise 5G network for ultra-low latency industrial applications'),
(8,'Disaster Recovery as a Service','Cloud',4100,'Cloud-based DR with automated failover, RPO < 15min, RTO < 1 hour'),
(9,'Business Mobile Fleet','Mobile',28,'Per-device enterprise mobile plan with MDM integration and pooled data'),
(10,'Managed WiFi Enterprise','Wireless',1500,'End-to-end managed WiFi for large offices, warehouses, and retail locations');

-- 50 Dutch Companies
INSERT INTO DIM_COMPANY (COMPANY_ID, COMPANY_NAME, INDUSTRY, SECTOR, HEADQUARTERS_CITY, EMPLOYEE_COUNT, ANNUAL_REVENUE_EUR, WEBSITE, ACCOUNT_TIER, ACCOUNT_MANAGER, CONTRACT_START_DATE, CONTRACT_END_DATE, IS_ACTIVE)
VALUES
(1,'Shell','Energy','Oil & Gas','The Hague',82000,261500000000,'shell.com','PLATINUM','Jan de Vries','2022-01-15','2027-01-14',TRUE),
(2,'ASML','Technology','Semiconductors','Veldhoven',42000,27600000000,'asml.com','PLATINUM','Jan de Vries','2022-03-01','2027-02-28',TRUE),
(3,'Philips','Healthcare','Medical Devices','Amsterdam',77000,17800000000,'philips.com','PLATINUM','Sophie van den Berg','2021-06-01','2026-05-31',TRUE),
(4,'ING Group','Financial Services','Banking','Amsterdam',57000,18900000000,'ing.com','PLATINUM','Sophie van den Berg','2022-09-01','2027-08-31',TRUE),
(5,'Rabobank','Financial Services','Banking','Utrecht',43000,13200000000,'rabobank.nl','PLATINUM','Jan de Vries','2023-01-01','2028-12-31',TRUE),
(6,'ABN AMRO','Financial Services','Banking','Amsterdam',21000,8100000000,'abnamro.nl','GOLD','Lars Bakker','2022-04-01','2025-03-31',TRUE),
(7,'Heineken','Consumer Goods','Beverages','Amsterdam',85000,28400000000,'heineken.com','PLATINUM','Sophie van den Berg','2021-11-01','2026-10-31',TRUE),
(8,'Unilever','Consumer Goods','FMCG','Rotterdam',128000,60100000000,'unilever.com','PLATINUM','Jan de Vries','2022-02-01','2027-01-31',TRUE),
(9,'Ahold Delhaize','Retail','Grocery','Zaandam',414000,86700000000,'aholddelhaize.com','PLATINUM','Lars Bakker','2023-03-01','2028-02-28',TRUE),
(10,'KPN','Telecommunications','Telecom','Rotterdam',10000,5400000000,'kpn.com','GOLD','Emma Jansen','2022-07-01','2025-06-30',TRUE),
(11,'Randstad','Professional Services','Staffing','Diemen',46000,27600000000,'randstad.com','GOLD','Lars Bakker','2023-06-01','2026-05-31',TRUE),
(12,'Wolters Kluwer','Technology','Information Services','Alphen aan den Rijn',21000,5600000000,'wolterskluwer.com','GOLD','Emma Jansen','2022-08-01','2025-07-31',TRUE),
(13,'NN Group','Financial Services','Insurance','The Hague',16000,17800000000,'nn-group.com','GOLD','Sophie van den Berg','2023-02-01','2026-01-31',TRUE),
(14,'Aegon','Financial Services','Insurance','The Hague',22000,7200000000,'aegon.com','GOLD','Lars Bakker','2022-05-01','2025-04-30',TRUE),
(15,'DSM-Firmenich','Chemicals','Specialty Chemicals','Maastricht',30000,12100000000,'dsm-firmenich.com','GOLD','Emma Jansen','2023-04-01','2026-03-31',TRUE),
(16,'Adyen','Technology','Fintech','Amsterdam',4000,1700000000,'adyen.com','GOLD','Pieter de Groot','2023-09-01','2026-08-31',TRUE),
(17,'AKZO Nobel','Chemicals','Paints & Coatings','Amsterdam',34000,10700000000,'akzonobel.com','GOLD','Emma Jansen','2022-10-01','2025-09-30',TRUE),
(18,'PostNL','Logistics','Postal & Parcels','The Hague',38000,3400000000,'postnl.nl','SILVER','Pieter de Groot','2023-01-15','2026-01-14',TRUE),
(19,'TomTom','Technology','Navigation','Amsterdam',4000,550000000,'tomtom.com','SILVER','Pieter de Groot','2023-05-01','2026-04-30',TRUE),
(20,'Booking Holdings','Technology','Travel','Amsterdam',22000,17100000000,'bookingholdings.com','PLATINUM','Sophie van den Berg','2022-06-01','2027-05-31',TRUE),
(21,'NXP Semiconductors','Technology','Semiconductors','Eindhoven',34000,13300000000,'nxp.com','GOLD','Jan de Vries','2022-11-01','2025-10-31',TRUE),
(22,'Signify','Manufacturing','Lighting','Eindhoven',35000,6900000000,'signify.com','SILVER','Lars Bakker','2023-07-01','2026-06-30',TRUE),
(23,'JDE Peets','Consumer Goods','Coffee','Amsterdam',20000,8200000000,'jdepeets.com','SILVER','Emma Jansen','2023-08-01','2026-07-31',TRUE),
(24,'Vopak','Energy','Tank Storage','Rotterdam',6000,1500000000,'vopak.com','SILVER','Pieter de Groot','2023-03-15','2026-03-14',TRUE),
(25,'SBM Offshore','Energy','Offshore','Schiedam',7000,5200000000,'sbmoffshore.com','SILVER','Lars Bakker','2022-12-01','2025-11-30',TRUE),
(26,'Arcadis','Professional Services','Engineering','Amsterdam',36000,4400000000,'arcadis.com','SILVER','Emma Jansen','2023-09-01','2026-08-31',TRUE),
(27,'Fugro','Professional Services','Geotechnical','Leidschendam',11000,1900000000,'fugro.com','SILVER','Pieter de Groot','2023-04-15','2026-04-14',TRUE),
(28,'Boskalis','Construction','Dredging','Papendrecht',11000,3200000000,'boskalis.com','SILVER','Lars Bakker','2022-09-01','2025-08-31',TRUE),
(29,'BAM Group','Construction','Building','Bunnik',18000,7100000000,'bam.com','SILVER','Pieter de Groot','2023-06-01','2026-05-31',TRUE),
(30,'Aalberts','Manufacturing','Industrial Products','Utrecht',16000,3300000000,'aalberts.com','SILVER','Emma Jansen','2023-10-01','2026-09-30',TRUE),
(31,'ASR Nederland','Financial Services','Insurance','Utrecht',4500,11400000000,'asrnl.com','GOLD','Sophie van den Berg','2023-01-01','2026-12-31',TRUE),
(32,'Van Lanschot Kempen','Financial Services','Wealth Management','s-Hertogenbosch',2100,1100000000,'vanlanschotkempen.com','SILVER','Lars Bakker','2023-11-01','2026-10-31',TRUE),
(33,'Flow Traders','Financial Services','Trading','Amsterdam',600,650000000,'flowtraders.com','SILVER','Pieter de Groot','2024-01-01','2026-12-31',TRUE),
(34,'Brunel International','Professional Services','Engineering Staffing','Amsterdam',12000,1300000000,'brunel.net','SILVER','Emma Jansen','2023-07-15','2026-07-14',TRUE),
(35,'Ordina','Technology','IT Consulting','Nieuwegein',3000,440000000,'ordina.nl','SILVER','Pieter de Groot','2023-12-01','2026-11-30',TRUE),
(36,'Exact','Technology','ERP Software','Delft',2200,320000000,'exact.com','SILVER','Emma Jansen','2024-02-01','2027-01-31',TRUE),
(37,'Just Eat Takeaway','Technology','Food Delivery','Amsterdam',7500,5100000000,'justeattakeaway.com','GOLD','Sophie van den Berg','2022-08-01','2025-07-31',TRUE),
(38,'Coolblue','Retail','Electronics','Rotterdam',6000,2400000000,'coolblue.nl','SILVER','Lars Bakker','2024-03-01','2027-02-28',TRUE),
(39,'Bol.com','Retail','E-commerce','Utrecht',2500,5500000000,'bol.com','GOLD','Sophie van den Berg','2023-05-01','2026-04-30',TRUE),
(40,'Tata Steel Netherlands','Manufacturing','Steel','IJmuiden',11000,7800000000,'tatasteel.nl','GOLD','Jan de Vries','2022-07-01','2025-06-30',TRUE),
(41,'Vattenfall Netherlands','Energy','Utilities','Amsterdam',3000,4200000000,'vattenfall.nl','SILVER','Lars Bakker','2023-08-01','2026-07-31',TRUE),
(42,'Eneco','Energy','Utilities','Rotterdam',3300,5100000000,'eneco.nl','SILVER','Emma Jansen','2023-09-15','2026-09-14',TRUE),
(43,'Essent','Energy','Utilities','s-Hertogenbosch',2800,4600000000,'essent.nl','SILVER','Pieter de Groot','2023-10-01','2026-09-30',TRUE),
(44,'T-Mobile Netherlands','Telecommunications','Mobile','The Hague',3200,2100000000,'t-mobile.nl','GOLD','Emma Jansen','2022-11-01','2025-10-31',TRUE),
(45,'VodafoneZiggo','Telecommunications','Convergent','Maastricht',8000,4400000000,'vodafoneziggo.nl','GOLD','Jan de Vries','2022-04-01','2025-03-31',TRUE),
(46,'Ziggo','Telecommunications','Cable','Utrecht',4000,2200000000,'ziggo.nl','SILVER','Lars Bakker','2023-06-01','2026-05-31',TRUE),
(47,'Picnic','Retail','Online Grocery','Amersfoort',15000,1800000000,'picnic.app','SILVER','Pieter de Groot','2024-01-15','2027-01-14',TRUE),
(48,'Swapfiets','Transportation','Bike Subscription','Delft',2000,120000000,'swapfiets.nl','SILVER','Emma Jansen','2024-04-01','2027-03-31',TRUE),
(49,'Mollie','Technology','Payments','Amsterdam',800,900000000,'mollie.com','SILVER','Pieter de Groot','2024-02-01','2027-01-31',TRUE),
(50,'Bunq','Financial Services','Digital Banking','Amsterdam',700,160000000,'bunq.com','SILVER','Emma Jansen','2024-05-01','2027-04-30',TRUE);

-- Date Dimension (Jan 2024 - Dec 2025)
INSERT INTO DIM_DATE (DATE_ID, FULL_DATE, YEAR, QUARTER, MONTH, MONTH_NAME, WEEK_OF_YEAR, DAY_OF_WEEK, IS_WEEKEND, FISCAL_YEAR, FISCAL_QUARTER)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.FULL_DATE) AS DATE_ID,
    d.FULL_DATE,
    YEAR(d.FULL_DATE),
    QUARTER(d.FULL_DATE),
    MONTH(d.FULL_DATE),
    MONTHNAME(d.FULL_DATE),
    WEEKOFYEAR(d.FULL_DATE),
    DAYOFWEEK(d.FULL_DATE),
    CASE WHEN DAYOFWEEK(d.FULL_DATE) IN (0, 6) THEN TRUE ELSE FALSE END,
    CASE WHEN MONTH(d.FULL_DATE) >= 4 THEN YEAR(d.FULL_DATE) + 1 ELSE YEAR(d.FULL_DATE) END,
    CASE 
        WHEN MONTH(d.FULL_DATE) IN (4,5,6) THEN 1
        WHEN MONTH(d.FULL_DATE) IN (7,8,9) THEN 2
        WHEN MONTH(d.FULL_DATE) IN (10,11,12) THEN 3
        ELSE 4
    END
FROM (
    SELECT DATEADD(DAY, SEQ4(), '2024-01-01'::DATE) AS FULL_DATE
    FROM TABLE(GENERATOR(ROWCOUNT => 731))
) d
WHERE d.FULL_DATE <= '2025-12-31';

-- Fact Sales (generates ~1000+ realistic transactions)
INSERT INTO FACT_SALES (COMPANY_ID, PRODUCT_ID, REP_ID, DATE_ID, SALE_DATE, QUANTITY, UNIT_PRICE_EUR, DISCOUNT_PCT, TOTAL_REVENUE_EUR, DEAL_STATUS, CONTRACT_LENGTH_MONTHS)
WITH monthly_dates AS (
    SELECT DATE_ID, FULL_DATE
    FROM DIM_DATE
    WHERE DAY(FULL_DATE) IN (5, 12, 19, 26)
),
sales_raw AS (
    SELECT 
        c.COMPANY_ID,
        p.PRODUCT_ID,
        CASE 
            WHEN c.ACCOUNT_MANAGER = 'Jan de Vries' THEN 1
            WHEN c.ACCOUNT_MANAGER = 'Sophie van den Berg' THEN 2
            WHEN c.ACCOUNT_MANAGER = 'Lars Bakker' THEN 3
            WHEN c.ACCOUNT_MANAGER = 'Emma Jansen' THEN 4
            WHEN c.ACCOUNT_MANAGER = 'Pieter de Groot' THEN 5
            ELSE MOD(c.COMPANY_ID, 8) + 1
        END AS REP_ID,
        md.DATE_ID,
        md.FULL_DATE AS SALE_DATE,
        CASE 
            WHEN p.PRODUCT_ID IN (5, 9) THEN UNIFORM(75, 600, RANDOM())
            ELSE UNIFORM(1, 10, RANDOM())
        END AS QUANTITY,
        p.MONTHLY_LIST_PRICE_EUR AS UNIT_PRICE_EUR,
        ROUND(UNIFORM(0, 20, RANDOM()) / 100.0, 2) AS DISCOUNT_PCT,
        CASE 
            WHEN UNIFORM(0, 100, RANDOM()) < 55 THEN 'WON'
            WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'LOST'
            ELSE 'PENDING'
        END AS DEAL_STATUS,
        UNIFORM(12, 48, RANDOM()) AS CONTRACT_LENGTH_MONTHS
    FROM DIM_COMPANY c
    CROSS JOIN DIM_PRODUCT p
    CROSS JOIN monthly_dates md
    WHERE UNIFORM(0, 1000, RANDOM()) < 
        CASE c.ACCOUNT_TIER 
            WHEN 'PLATINUM' THEN 12
            WHEN 'GOLD' THEN 8
            ELSE 5
        END
)
SELECT 
    COMPANY_ID, PRODUCT_ID, REP_ID, DATE_ID, SALE_DATE, QUANTITY, UNIT_PRICE_EUR, DISCOUNT_PCT,
    ROUND(QUANTITY * UNIT_PRICE_EUR * (1 - DISCOUNT_PCT), 2) AS TOTAL_REVENUE_EUR,
    DEAL_STATUS, CONTRACT_LENGTH_MONTHS
FROM sales_raw;
