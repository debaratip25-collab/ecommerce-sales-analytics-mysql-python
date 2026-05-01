# 📊 E-Commerce Sales Insights System

A comprehensive **SQL analytics + Streamlit dashboard** project that transforms raw e-commerce data into actionable business intelligence.

**Stack:** MySQL 8.0 · Docker · SQL · Python · Pandas · Matplotlib

---

## 🎯 Project Overview

This project mirrors real-world e-commerce BI stacks used by D2C brands, marketplaces, and SMEs. It demonstrates:

✅ **Relational database design** with normalized schema  
✅ **Advanced SQL analytics** (CTEs, JOINs, aggregations, window functions)  
✅ **Business KPI calculations** (ROAS, CAC, AOV, margins)  
✅ **Real time dashboard** for real-time insights  
✅ **Data-driven decision making** for growth  

---

## 🏗️ System Architecture

### Database Schema (8 Tables)

```
┌─────────────┐
│ categories  │
├─────────────┤
│ category_id │ (PK)
│ name        │
└─────────────┘
        │
        ├─→ products
        │   ├─ product_id (PK)
        │   ├─ sku
        │   ├─ name
        │   ├─ cost_price
        │   └─ list_price
        │
customers   orders      order_items
  ├─→       │           ├─→ products
  │         │           │
  │         ├─→ order_items
  │         │
  │         ├─→ channel_id
  │         │
  └─→ payments
```

### Tables

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| **customers** | Customer master data | customer_id, email, first_name, last_name, country, signup_at |
| **products** | Product catalog | product_id, sku, product_name, category_id, cost_price, list_price |
| **categories** | Product categories | category_id, category_name |
| **orders** | Order transactions | order_id, customer_id, order_datetime, channel_id, status (PAID/REFUNDED/PENDING/CANCELLED) |
| **order_items** | Line items per order | order_item_id, order_id, product_id, quantity, unit_price, discount |
| **payments** | Payment records | payment_id, order_id, paid_amount, paid_at, method |
| **channels** | Marketing channels | channel_id, channel_name (Google Ads, Meta Ads, Email, Direct) |
| **channel_spend** | Daily ad spend tracking | spend_date, channel_id, spend |

---


## 📊 Dashboard Pages

### 1. 📈 Overview — KPI Summary
- **Total Orders:** Number of paid orders
- **Gross Revenue:** Total income (after discounts)
- **Average Order Value (AOV):** ₹44.59 (avg spend per order)
- **Gross Margin:** ₹81.31 (profit after cost of goods)
- **Margin %:** 45.59% (healthy for e-commerce)

### 2. 💰 Revenue Metrics — Financial Health
- **Daily Revenue Trend:** See revenue fluctuations
- **Daily Profit:** Earnings after COGS
- **Revenue vs COGS Breakdown:** Understand unit economics

**Insight:** Revenue shows fluctuations rather than steady growth, suggesting demand is campaign-driven or influenced by external factors.

### 3. 📢 Channel Performance — Marketing ROI
- **ROAS (Return on Ad Spend):** Revenue generated per ₹1 spent
- **Total Revenue by Channel:** Which channels drive most sales
- **Total Ad Spend by Channel:** Marketing budget allocation

**Key Metrics:**
- **ROAS 1.0** = Break-even
- **ROAS 3.0+** = Healthy
- **ROAS 5.0+** = Excellent

**Insight:** Certain channels contribute significantly more revenue than others. High-performing channels should receive more budget allocation.

### 4. 🏆 Product Analysis — Top Performers
- **Revenue by Product:** Which SKUs generate most ₹
- **Units Sold:** Sales volume per product
- **Revenue Share by Category:** Category contribution to total revenue

**Insight:** A few products contribute disproportionately to revenue. These should be prioritized for inventory, marketing, and bundling strategies.

### 5. 🌍 Geographic Split — Regional Performance
- **Revenue by Country (Pie):** Geographic revenue concentration
- **Orders by Country (Bar):** Volume per region

**Insight:** Revenue is concentrated in specific geographies (71% India, 29% US). Underperforming regions may need localized strategies.

### 6. ⚠️ Refunds — Churn & Quality
- **Total Refunded Orders:** Volume of refunds
- **Lost Revenue:** ₹ impact of refunds
- **COGS Lost:** Product cost of refunded items
- **Refund Rate:** % of orders refunded (healthy: <3%)

**Insight:** Refund volume is limited (1 out of 5 orders), indicating good product quality. Monitor refund trends for logistics or quality issues.

---

## 📈 Core SQL Analytics Queries

### Query 1: Revenue, AOV & Margin

```sql
WITH line AS (
  SELECT 
    oi.order_id,
    (oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0) AS line_revenue,
    (p.cost_price * oi.quantity) AS line_cost
  FROM order_items oi
  JOIN products p ON p.product_id = oi.product_id
),
paid_orders AS (
  SELECT order_id FROM orders WHERE status = 'PAID'
)
SELECT
  COUNT(DISTINCT po.order_id) AS total_orders,
  ROUND(SUM(l.line_revenue), 2) AS gross_revenue,
  ROUND(SUM(l.line_revenue) / COUNT(DISTINCT po.order_id), 2) AS avg_order_value,
  ROUND(SUM(l.line_revenue - l.line_cost), 2) AS gross_margin,
  ROUND((SUM(l.line_revenue - l.line_cost) / SUM(l.line_revenue)) * 100, 2) AS margin_percent
FROM line l
JOIN paid_orders po ON po.order_id = l.order_id;
```

### Query 2: Daily Revenue & ROAS by Channel

```sql
WITH revenue_by_channel AS (
  SELECT 
    DATE(o.order_datetime) AS order_date,
    o.channel_id,
    SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)) AS daily_revenue
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = 'PAID'
  GROUP BY DATE(o.order_datetime), o.channel_id
),
spend_by_channel AS (
  SELECT 
    spend_date,
    channel_id,
    SUM(spend) AS daily_spend
  FROM channel_spend
  GROUP BY spend_date, channel_id
)
SELECT 
  r.order_date,
  c.channel_name,
  ROUND(r.daily_revenue, 2) AS revenue,
  ROUND(COALESCE(s.daily_spend, 0), 2) AS ad_spend,
  CASE 
    WHEN COALESCE(s.daily_spend, 0) = 0 THEN NULL
    ELSE ROUND(r.daily_revenue / s.daily_spend, 2)
  END AS roas
FROM revenue_by_channel r
LEFT JOIN spend_by_channel s ON r.order_date = s.spend_date AND r.channel_id = s.channel_id
JOIN channels c ON c.channel_id = r.channel_id
ORDER BY r.order_date, c.channel_name;
```

### Query 3: Top Products by Revenue

```sql
SELECT 
  p.product_name,
  cat.category_name,
  ROUND(SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)), 2) AS net_revenue,
  SUM(oi.quantity) AS units_sold
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.status = 'PAID'
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY net_revenue DESC
LIMIT 5;
```

### Query 4: Revenue by Country

```sql
SELECT 
  o.ship_country,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)), 2) AS revenue,
  ROUND(AVG((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'PAID'
GROUP BY o.ship_country
ORDER BY revenue DESC;
```

## 💡 Key Insights from Sample Data

### 1. KPI Summary
✅ Healthy unit economics with 45.59% gross margin  
⚠️ AOV of ₹44.59 suggests moderate basket size (not bulk purchases)

### 2. Revenue Trends
📉 Revenue fluctuates across dates, no clear upward trend  
💡 Demand appears campaign-driven; limited data points

### 3. Channel Performance
🎯 Uneven performance across marketing channels  
💼 High-performers should receive more budget allocation

### 4. Product Analysis
⭐ A few products drive disproportionate revenue (Wireless Earbuds: 42% of revenue)  
🔧 Prioritize inventory, marketing, bundling for top products

### 5. Geographic Split
🌏 Revenue concentrated in India (72%) vs US (28%)  
📍 Underperforming regions need localized strategies

### 6. Refund Impact
✅ Low refund rate (20%) indicates good quality  
⚠️ Monitor refund trends for early warning signs

---

## 🔧 SQL Concepts Used

| Concept | Used For |
|---------|----------|
| **CTEs (WITH clauses)** | Breaking complex queries into readable steps |
| **JOINs (INNER/LEFT)** | Combining data from multiple tables |
| **GROUP BY** | Aggregating metrics by date, channel, product |
| **HAVING** | Filtering groups after aggregation |
| **SUM, COUNT, AVG** | Calculating financial metrics |
| **CASE/WHEN** | Conditional logic (e.g., ROAS calculation) |
| **COALESCE** | Handling null values in ad spend |
| **DATE functions** | Extracting date from timestamps |
| **Subqueries** | Status-based filtering |

---

## 📁 Project Structure

```
ecommerce-sales-analytics-mysql-python/
├── README.md                      # This file
├── python/
    ├── dashboard.ipynb            # Python dashboard
├── sql dataset/
│   ├── Tables.sql                 # Table creation (DDL)
│   ├── Insertion.sql              # Test data (INSERT)
│   └── Analytics_Queries.sql      # All 6 KPI queries
    └── ERR diagram.png            # Table relation diagram
└── screenshots/                   # Dashboard screenshots
    ├── dashboard 1.png
    ├── dashboard 2.png
    ├── dashboard 3.png
    ├── dashboard 4.png
└── docker.png                     # Docker screenshot 
```

---

## 🎓 What I Learnt

### SQL Skills
- ✅ Normalized schema design (1NF, 2NF, 3NF)
- ✅ Foreign keys & referential integrity
- ✅ Complex queries with CTEs
- ✅ Query optimization with indexes
- ✅ Aggregate functions & grouping
- ✅ Date/time functions
- ✅ Join strategies (INNER/LEFT/GROUP)

### Data Analytics
- ✅ Business KPI definitions (ROAS, CAC, AOV, margin)
- ✅ Cohort analysis (first-purchase cohorts)
- ✅ Retention metrics (30-day repeat rate)
- ✅ Geographic & channel performance analysis
- ✅ Refund impact quantification

### Python & Visualization
- ✅ Pandas for data manipulation
- ✅ Matplotlib for dashboard building and charts
- ✅ MySQL connector for database connections

### Business Insights
- ✅ How to read ROAS & optimize ad spend
- ✅ Understanding gross margin & profitability
- ✅ Identifying top products & SKUs
- ✅ Geographic market analysis
- ✅ Refund rate monitoring

---

### Future Improvements
Build interactive dashboard using Streamlit or Power BI
Add larger dataset for stronger trend analysis
Implement customer segmentation & cohort analysis
Automate ETL pipeline

---

### Final Note

This project demonstrates how raw transactional data can be transformed into meaningful business insights using SQL and Python.
