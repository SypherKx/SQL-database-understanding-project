-- 1. Executive KPI & MoM Growth
WITH MonthlyMetrics AS (
    SELECT
        STRFTIME('%Y-%m', order_date) AS order_month,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT user_id) AS unique_buyers,
        SUM(total_amount) AS monthly_revenue_inr,
        ROUND(AVG(total_amount), 2) AS avg_order_value_inr
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY STRFTIME('%Y-%m', order_date)
)
SELECT
    order_month,
    total_orders,
    unique_buyers,
    monthly_revenue_inr,
    avg_order_value_inr,
    LAG(monthly_revenue_inr) OVER (ORDER BY order_month) AS prev_month_revenue_inr,
    ROUND(
        (monthly_revenue_inr - LAG(monthly_revenue_inr) OVER (ORDER BY order_month)) 
        / LAG(monthly_revenue_inr) OVER (ORDER BY order_month) * 100, 2
    ) AS mom_growth_pct
FROM MonthlyMetrics
ORDER BY order_month DESC;


-- 2. Customer RFM Segmentation
WITH BaseRFM AS (
    SELECT
        u.user_id,
        u.full_name,
        u.city,
        u.email,
        CAST(JULIANDAY('2024-02-15') - JULIANDAY(MAX(o.order_date)) AS INT) AS recency_days,
        COUNT(o.order_id) AS frequency,
        SUM(o.total_amount) AS monetary_val_inr
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    WHERE o.order_status = 'Completed'
    GROUP BY u.user_id, u.full_name, u.city, u.email
),
RFMScores AS (
    SELECT
        user_id,
        full_name,
        city,
        email,
        recency_days,
        frequency,
        monetary_val_inr,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS R_Score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS F_Score,
        NTILE(4) OVER (ORDER BY monetary_val_inr DESC) AS M_Score
    FROM BaseRFM
)
SELECT
    user_id,
    full_name,
    city,
    email,
    recency_days,
    frequency,
    monetary_val_inr,
    (R_Score || F_Score || M_Score) AS rfm_code,
    CASE 
        WHEN R_Score = 4 AND F_Score = 4 AND M_Score = 4 THEN 'VIP Champion'
        WHEN F_Score >= 3 AND M_Score >= 3 THEN 'Loyal Customer'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN 'At Risk'
        WHEN R_Score = 1 THEN 'Inactive'
        ELSE 'Potential Loyalist'
    END AS customer_segment
FROM RFMScores
ORDER BY monetary_val_inr DESC;


-- 3. Pareto 80/20 Revenue Drivers
WITH ProductPerformance AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.unit_price) AS gross_revenue_inr,
        SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_profit_inr
    FROM products p
    JOIN categories c ON p.category_id = c.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.product_id, p.product_name, c.category_name
),
CumulativeTotals AS (
    SELECT
        product_name,
        category_name,
        gross_revenue_inr,
        total_profit_inr,
        SUM(gross_revenue_inr) OVER () AS overall_revenue_inr,
        SUM(gross_revenue_inr) OVER (ORDER BY gross_revenue_inr DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue_inr
    FROM ProductPerformance
)
SELECT
    product_name,
    category_name,
    gross_revenue_inr,
    total_profit_inr,
    ROUND((running_revenue_inr / overall_revenue_inr) * 100, 2) AS cumulative_revenue_pct,
    CASE 
        WHEN (running_revenue_inr / overall_revenue_inr) <= 0.80 THEN 'Top 80% Revenue Driver'
        ELSE 'Tail Product'
    END AS pareto_classification
FROM CumulativeTotals
ORDER BY gross_revenue_inr DESC;


-- 4. Rolling 7-Day Revenue Trend
WITH DailySales AS (
    SELECT
        DATE(order_date) AS sales_date,
        SUM(total_amount) AS daily_revenue_inr,
        COUNT(order_id) AS daily_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE(order_date)
)
SELECT
    sales_date,
    daily_revenue_inr,
    daily_orders,
    ROUND(
        AVG(daily_revenue_inr) OVER (
            ORDER BY sales_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_7day_avg_revenue_inr
FROM DailySales
ORDER BY sales_date ASC;


-- 5. Fulfillment Center Stock & Reorder Risk
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    i.fulfillment_center,
    i.quantity_in_stock,
    p.reorder_level,
    (p.reorder_level - i.quantity_in_stock) AS stock_deficit,
    ROUND((i.quantity_in_stock * 1.0 / NULLIF(p.reorder_level, 0)), 2) AS stock_coverage_ratio,
    CASE 
        WHEN i.quantity_in_stock = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_in_stock <= (p.reorder_level * 0.5) THEN 'HIGH RISK'
        WHEN i.quantity_in_stock <= p.reorder_level THEN 'REORDER NEEDED'
        ELSE 'OPTIMAL'
    END AS restock_priority
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
ORDER BY stock_coverage_ratio ASC;


-- 6. Indian Payment Gateway & Payment Mode Reliability
SELECT
    gateway,
    COUNT(payment_id) AS total_transactions,
    SUM(CASE WHEN payment_status = 'Success' THEN 1 ELSE 0 END) AS success_count,
    SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) AS failure_count,
    SUM(CASE WHEN payment_status = 'Success' THEN amount ELSE 0 END) AS processed_volume_inr,
    ROUND(
        SUM(CASE WHEN payment_status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(payment_id), 2
    ) AS failure_rate_pct
FROM payments
GROUP BY gateway
ORDER BY failure_rate_pct DESC;


-- 7. Logistics Carrier SLA Performance in India
SELECT
    carrier,
    COUNT(shipment_id) AS total_shipments,
    ROUND(AVG(JULIANDAY(actual_delivery) - JULIANDAY(dispatch_date)), 1) AS avg_transit_days,
    SUM(CASE WHEN actual_delivery > estimated_delivery THEN 1 ELSE 0 END) AS delayed_count,
    ROUND(
        SUM(CASE WHEN actual_delivery > estimated_delivery THEN 1 ELSE 0 END) * 100.0 / COUNT(shipment_id), 2
    ) AS delay_rate_pct
FROM shipments
WHERE shipment_status = 'Delivered'
GROUP BY carrier
ORDER BY delay_rate_pct DESC;


-- 8. Metro City Level ARPU (Average Revenue Per User)
SELECT
    u.city,
    u.state,
    COUNT(DISTINCT u.user_id) AS total_users,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_revenue_inr,
    ROUND(COALESCE(SUM(o.total_amount), 0) / COUNT(DISTINCT u.user_id), 2) AS arpu_inr
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed'
GROUP BY u.city, u.state
ORDER BY total_revenue_inr DESC;


-- 9. Customer Lifetime Value (CLV) & Tier Ranking
WITH UserSpend AS (
    SELECT
        u.user_id,
        u.full_name,
        u.city,
        u.user_tier,
        COUNT(o.order_id) AS lifetime_orders,
        COALESCE(SUM(o.total_amount), 0) AS lifetime_value_inr
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed'
    GROUP BY u.user_id, u.full_name, u.city, u.user_tier
)
SELECT
    user_id,
    full_name,
    city,
    user_tier,
    lifetime_orders,
    lifetime_value_inr,
    DENSE_RANK() OVER (ORDER BY lifetime_value_inr DESC) AS clv_rank
FROM UserSpend
ORDER BY clv_rank ASC;


-- 10. Tier Progression Gap Analysis (INR Thresholds)
WITH CustomerSpend AS (
    SELECT
        u.user_id,
        u.full_name,
        u.user_tier,
        COALESCE(SUM(o.total_amount), 0) AS current_spend_inr
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed'
    GROUP BY u.user_id, u.full_name, u.user_tier
)
SELECT
    user_id,
    full_name,
    user_tier,
    current_spend_inr,
    CASE 
        WHEN user_tier = 'Standard' AND current_spend_inr < 50000 THEN (50000 - current_spend_inr)
        WHEN user_tier = 'Silver' AND current_spend_inr < 150000 THEN (150000 - current_spend_inr)
        WHEN user_tier = 'Gold' AND current_spend_inr < 300000 THEN (300000 - current_spend_inr)
        ELSE 0
    END AS spend_needed_for_next_tier_inr
FROM CustomerSpend
WHERE user_tier != 'VIP Platinum'
ORDER BY spend_needed_for_next_tier_inr ASC;
