DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS customer_reviews;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone_number TEXT NOT NULL,
    registration_date TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    user_tier TEXT DEFAULT 'Standard'
);

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    cost_price REAL NOT NULL,
    reorder_level INTEGER NOT NULL DEFAULT 15,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

CREATE TABLE inventory (
    inventory_id INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE,
    fulfillment_center TEXT NOT NULL,
    quantity_in_stock INTEGER NOT NULL,
    last_restock_date TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    total_amount REAL NOT NULL DEFAULT 0.00,
    order_status TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL,
    discount REAL DEFAULT 0.00,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_date TEXT NOT NULL,
    amount REAL NOT NULL,
    payment_status TEXT NOT NULL,
    gateway TEXT NOT NULL,
    transaction_ref TEXT NOT NULL UNIQUE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

CREATE TABLE shipments (
    shipment_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE,
    carrier TEXT NOT NULL,
    tracking_number TEXT NOT NULL UNIQUE,
    dispatch_date TEXT,
    estimated_delivery TEXT,
    actual_delivery TEXT,
    shipment_status TEXT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

CREATE TABLE customer_reviews (
    review_id INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    review_text TEXT,
    review_date TEXT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE audit_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity_name TEXT NOT NULL,
    action_type TEXT NOT NULL,
    entity_id INTEGER NOT NULL,
    performed_by TEXT DEFAULT 'SYSTEM',
    log_timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    details TEXT
);

CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_inventory_stock ON inventory(quantity_in_stock);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_users_city ON users(city);
