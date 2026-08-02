-- Executive KPI Summary View
CREATE VIEW IF NOT EXISTS vw_executive_kpi_summary AS
SELECT
    COUNT(DISTINCT u.user_id) AS total_customers,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS gross_revenue_inr,
    ROUND(AVG(o.total_amount), 2) AS avg_order_value_inr
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed';


-- Fulfillment Center Reorder Alert View
CREATE VIEW IF NOT EXISTS vw_inventory_reorder_alerts AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    i.fulfillment_center,
    i.quantity_in_stock,
    p.reorder_level
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE i.quantity_in_stock <= p.reorder_level;


-- Customer 360 View
CREATE VIEW IF NOT EXISTS vw_customer_360 AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    u.city,
    u.state,
    u.user_tier,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spend_inr,
    MAX(o.order_date) AS last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.order_status = 'Completed'
GROUP BY u.user_id, u.full_name, u.email, u.city, u.state, u.user_tier;
