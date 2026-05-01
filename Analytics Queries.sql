USE ec;

-- Query 1: Total Revenue, AOV, Gross Margin (PAID orders only)
WITH line AS (
  SELECT 
    oi.order_id,
    (oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0) AS line_revenue,
    (p.cost_price * oi.quantity) AS line_cost
  FROM order_items oi
  JOIN products p ON p.product_id = oi.product_id
),
paid_orders AS (
  SELECT order_id 
  FROM orders 
  WHERE status = 'PAID'
)
SELECT
  COUNT(DISTINCT po.order_id) AS total_orders,
  ROUND(SUM(l.line_revenue), 2) AS gross_revenue,
  ROUND(SUM(l.line_revenue) / COUNT(DISTINCT po.order_id), 2) AS avg_order_value,
  ROUND(SUM(l.line_revenue - l.line_cost), 2) AS gross_margin,
  ROUND((SUM(l.line_revenue - l.line_cost) / SUM(l.line_revenue)) * 100, 2) AS margin_percent
FROM line l
JOIN paid_orders po ON po.order_id = l.order_id;

-- Query 2: Daily Revenue & ROAS (Return on Ad Spend) by Channel
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

-- Query 3: CAC (Customer Acquisition Cost) by Channel & Day
WITH new_customers AS (
  SELECT 
    DATE(c.signup_at) AS signup_date,
    o.channel_id,
    COUNT(DISTINCT c.customer_id) AS new_customers
  FROM customers c
  LEFT JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'PAID'
  WHERE o.order_id IS NOT NULL
  GROUP BY DATE(c.signup_at), o.channel_id
),
spend_data AS (
  SELECT 
    spend_date,
    channel_id,
    SUM(spend) AS total_spend
  FROM channel_spend
  GROUP BY spend_date, channel_id
)
SELECT 
  nc.signup_date,
  ch.channel_name,
  nc.new_customers,
  ROUND(s.total_spend, 2) AS spend,
  CASE 
    WHEN nc.new_customers = 0 THEN NULL
    ELSE ROUND(s.total_spend / nc.new_customers, 2)
  END AS cac
FROM new_customers nc
LEFT JOIN spend_data s ON nc.signup_date = s.spend_date AND nc.channel_id = s.channel_id
JOIN channels ch ON ch.channel_id = nc.channel_id
ORDER BY nc.signup_date, ch.channel_name;

-- Query 4: Top Products by Net Revenue
SELECT 
  p.product_name,
  cat.category_name,
  ROUND(SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)), 2) AS net_revenue,
  SUM(oi.quantity) AS units_sold,
  ROUND(SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)) / SUM(oi.quantity), 2) AS avg_price_per_unit
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN categories cat ON cat.category_id = p.category_id
WHERE o.status = 'PAID'
GROUP BY p.product_id, p.product_name, cat.category_name
ORDER BY net_revenue DESC
LIMIT 5;

-- Query 5: Refund Impact Analysis
SELECT 
  DATE(o.order_datetime) AS refund_date,
  COUNT(o.order_id) AS refunded_orders,
  ROUND(SUM((oi.unit_price * oi.quantity) - COALESCE(oi.discount, 0)), 2) AS refunded_revenue,
  ROUND(SUM(p.cost_price * oi.quantity), 2) AS refunded_cogs
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'REFUNDED'
GROUP BY DATE(o.order_datetime)
ORDER BY refund_date DESC;

-- Query 6: Revenue by Ship Country
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