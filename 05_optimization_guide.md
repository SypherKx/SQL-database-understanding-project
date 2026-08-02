# Database Optimization & Query Tuning Notes

Notes on indexing strategies, query optimization, and execution plan benchmarks applied to the e-commerce schema.

---

## 1. Indexing Strategy

Filtering on `user_id` + `order_date` or checking `order_status` on unindexed tables causes full table scans once table sizes grow. 

Added composite and single-column indexes:

```sql
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_inventory_stock ON inventory(quantity_in_stock);
```

---

## 2. EXPLAIN Plan Benchmarks

### Target Query
```sql
SELECT user_id, COUNT(order_id), SUM(total_amount)
FROM orders
WHERE user_id = 1001 AND order_date >= '2023-01-01'
GROUP BY user_id;
```

#### Without Composite Index (`idx_orders_user_date`)
- **Scan Type**: Table Scan (`ALL`)
- **Rows Examined**: 12,000
- **Execution Time**: ~42.8 ms

```text
-> Filter: (orders.user_id = 1001 and orders.order_date >= '2023-01-01')
    -> Table scan on orders (rows=12000)
```

#### With Composite Index (`idx_orders_user_date`)
- **Scan Type**: Index Range Scan (`range`)
- **Rows Examined**: 4
- **Execution Time**: ~0.9 ms

```text
-> Aggregate: sum(orders.total_amount), count(orders.order_id)
    -> Index range scan on orders using idx_orders_user_date (user_id = 1001 AND order_date >= '2023-01-01')
```

---

## 3. Optimization Guidelines Applied

- **Avoid SELECT \***: Requesting specific columns allows index-only scans without reading full data pages.
- **SARGable Clauses**: Avoid function calls on indexed columns in `WHERE` clauses (e.g. use range bounds instead of `YEAR(order_date)`).
- **Composite Index Column Order**: Equality column first (`user_id`), range column second (`order_date`).
