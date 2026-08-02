INSERT INTO categories (category_id, category_name, department) VALUES
(1, 'Laptops & Computing', 'Electronics'),
(2, 'Mobiles & Accessories', 'Electronics'),
(3, 'Audio & Wearables', 'Electronics'),
(4, 'Home & Kitchen Appliances', 'Home & Living'),
(5, 'Ethnic & Western Wear', 'Fashion'),
(6, 'Office & Productivity', 'Enterprise');

INSERT INTO products (product_id, product_name, category_id, unit_price, cost_price, reorder_level) VALUES
(101, 'MacBook Pro 16 M3 Max', 1, 249900.00, 195000.00, 10),
(102, 'Dell XPS 15 i9 32GB', 1, 189900.00, 145000.00, 12),
(103, 'Lenovo ThinkPad X1 Carbon', 1, 145000.00, 110000.00, 15),
(104, 'iPhone 15 Pro Max 256GB', 2, 134900.00, 98000.00, 20),
(105, 'Samsung Galaxy S24 Ultra', 2, 129990.00, 92000.00, 20),
(106, 'Anker 65W GaN Fast Charger', 2, 3499.00, 1800.00, 50),
(107, 'Sony WH-1000XM5 Headphones', 3, 29990.00, 21000.00, 25),
(108, 'Apple AirPods Pro 2nd Gen', 3, 24900.00, 16500.00, 30),
(109, 'Dyson V15 Detect Vacuum', 4, 62900.00, 44000.00, 8),
(110, 'Philips Digital Air Fryer 4.1L', 4, 8999.00, 5500.00, 25),
(111, 'Green Soul Ergonomic Gaming Chair', 6, 14990.00, 9500.00, 12),
(112, 'Jin Office Motorized Standing Desk', 6, 28990.00, 19000.00, 10);

INSERT INTO inventory (inventory_id, product_id, fulfillment_center, quantity_in_stock, last_restock_date) VALUES
(1, 101, 'FC-BLR-01 (Bengaluru Hub)', 35, '2024-01-10'),
(2, 102, 'FC-BOM-01 (Bhiwandi, Mumbai)', 18, '2024-01-12'),
(3, 103, 'FC-DEL-02 (Gurugram, NCR)', 6, '2024-01-05'),
(4, 104, 'FC-BLR-01 (Bengaluru Hub)', 85, '2024-01-20'),
(5, 105, 'FC-HYD-01 (Hyderabad Hub)', 42, '2024-01-18'),
(6, 106, 'FC-PNQ-01 (Chakan, Pune)', 280, '2024-01-22'),
(7, 107, 'FC-DEL-02 (Gurugram, NCR)', 12, '2024-01-15'),
(8, 108, 'FC-BLR-01 (Bengaluru Hub)', 95, '2024-01-25'),
(9, 109, 'FC-BOM-01 (Bhiwandi, Mumbai)', 4, '2024-01-08'),
(10, 110, 'FC-HYD-01 (Hyderabad Hub)', 45, '2024-01-14'),
(11, 111, 'FC-PNQ-01 (Chakan, Pune)', 20, '2024-01-19'),
(12, 112, 'FC-DEL-02 (Gurugram, NCR)', 8, '2024-01-11');

INSERT INTO users (user_id, full_name, email, phone_number, registration_date, city, state, user_tier) VALUES
(1001, 'Aarav Sharma', 'aarav.sharma@example.in', '+919876543210', '2023-01-15', 'Bengaluru', 'Karnataka', 'VIP Platinum'),
(1002, 'Priya Nair', 'priya.nair@example.in', '+919812345678', '2023-02-10', 'Mumbai', 'Maharashtra', 'Gold'),
(1003, 'Rohan Mehta', 'rohan.mehta@example.in', '+919711223344', '2023-03-05', 'Delhi', 'Delhi NCR', 'Silver'),
(1004, 'Ananya Iyer', 'ananya.iyer@example.in', '+919655443322', '2023-03-22', 'Chennai', 'Tamil Nadu', 'Standard'),
(1005, 'Vikram Verma', 'vikram.v@example.in', '+919544332211', '2023-04-18', 'Hyderabad', 'Telangana', 'Gold'),
(1006, 'Neha Kulkarni', 'neha.k@example.in', '+919433221100', '2023-05-12', 'Pune', 'Maharashtra', 'VIP Platinum'),
(1007, 'Aditya Banerjee', 'aditya.b@example.in', '+919322110099', '2023-06-01', 'Kolkata', 'West Bengal', 'Standard'),
(1008, 'Sneha Patel', 'sneha.patel@example.in', '+919211009988', '2023-07-14', 'Ahmedabad', 'Gujarat', 'Gold'),
(1009, 'Kabir Singh', 'kabir.s@example.in', '+919100998877', '2023-08-20', 'Chandigarh', 'Punjab', 'Silver'),
(1010, 'Diya Deshmukh', 'diya.d@example.in', '+919000887766', '2023-09-09', 'Nagpur', 'Maharashtra', 'Standard');

INSERT INTO orders (order_id, user_id, order_date, total_amount, order_status, payment_method) VALUES
(5001, 1001, '2023-10-01 10:15:00', 253399.00, 'Completed', 'UPI'),
(5002, 1002, '2023-10-03 14:30:00', 189900.00, 'Completed', 'Credit Card'),
(5003, 1003, '2023-10-10 11:45:00', 29990.00, 'Completed', 'UPI'),
(5004, 1001, '2023-11-05 09:20:00', 134900.00, 'Completed', 'Cred'),
(5005, 1004, '2023-11-12 16:10:00', 62900.00, 'Completed', 'Net Banking'),
(5006, 1005, '2023-11-20 18:05:00', 145000.00, 'Completed', 'Credit Card'),
(5007, 1006, '2023-12-01 12:00:00', 379890.00, 'Completed', 'UPI'),
(5008, 1002, '2023-12-15 15:40:00', 24900.00, 'Completed', 'Cred'),
(5009, 1007, '2023-12-24 20:15:00', 3499.00, 'Cancelled', 'COD'),
(5010, 1008, '2024-01-04 13:25:00', 129990.00, 'Completed', 'UPI'),
(5011, 1009, '2024-01-10 17:50:00', 43980.00, 'Completed', 'Net Banking'),
(5012, 1010, '2024-01-15 08:30:00', 8999.00, 'Processing', 'COD'),
(5013, 1001, '2024-01-22 19:10:00', 29990.00, 'Completed', 'UPI'),
(5014, 1006, '2024-01-28 11:00:00', 249900.00, 'Completed', 'Credit Card'),
(5015, 1003, '2024-02-02 14:00:00', 3499.00, 'Refunded', 'UPI');

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price, discount) VALUES
(1, 5001, 101, 1, 249900.00, 0.00),
(2, 5001, 106, 1, 3499.00, 0.00),
(3, 5002, 102, 1, 189900.00, 0.00),
(4, 5003, 107, 1, 29990.00, 0.00),
(5, 5004, 104, 1, 134900.00, 0.00),
(6, 5005, 109, 1, 62900.00, 0.00),
(7, 5006, 103, 1, 145000.00, 0.00),
(8, 5007, 101, 1, 249900.00, 0.00),
(9, 5007, 105, 1, 129990.00, 0.00),
(10, 5008, 108, 1, 24900.00, 0.00),
(11, 5009, 106, 1, 3499.00, 0.00),
(12, 5010, 105, 1, 129990.00, 0.00),
(13, 5011, 111, 1, 14990.00, 0.00),
(14, 5011, 112, 1, 28990.00, 0.00),
(15, 5012, 110, 1, 8999.00, 0.00),
(16, 5013, 107, 1, 29990.00, 0.00),
(17, 5014, 101, 1, 249900.00, 0.00),
(18, 5015, 106, 1, 3499.00, 0.00);

INSERT INTO payments (payment_id, order_id, payment_date, amount, payment_status, gateway, transaction_ref) VALUES
(9001, 5001, '2023-10-01 10:16:00', 253399.00, 'Success', 'PhonePe', 'PAYIN_UPI_9001_BLR'),
(9002, 5002, '2023-10-03 14:31:00', 189900.00, 'Success', 'Razorpay', 'PAYIN_RZP_9002_BOM'),
(9003, 5003, '2023-10-10 11:46:00', 29990.00, 'Success', 'Google Pay', 'PAYIN_GPay_9003_DEL'),
(9004, 5004, '2023-11-05 09:21:00', 134900.00, 'Success', 'Cred Pay', 'PAYIN_CRED_9004_BLR'),
(9005, 5005, '2023-11-12 16:11:00', 62900.00, 'Success', 'HDFC NetBanking', 'PAYIN_HDFC_9005_MAA'),
(9006, 5006, '2023-11-20 18:06:00', 145000.00, 'Success', 'Razorpay', 'PAYIN_RZP_9006_HYD'),
(9007, 5007, '2023-12-01 12:01:00', 379890.00, 'Success', 'PhonePe', 'PAYIN_UPI_9007_PNQ'),
(9008, 5008, '2023-12-15 15:41:00', 24900.00, 'Success', 'Cred Pay', 'PAYIN_CRED_9008_BOM'),
(9009, 5009, '2023-12-24 20:16:00', 3499.00, 'Failed', 'COD', 'PAYIN_COD_9009_CCU'),
(9010, 5010, '2024-01-04 13:26:00', 129990.00, 'Success', 'Paytm UPI', 'PAYIN_PTM_9010_AMD'),
(9011, 5011, '2024-01-10 17:51:00', 43980.00, 'Success', 'ICICI NetBanking', 'PAYIN_ICICI_9011_IXC'),
(9012, 5012, '2024-01-15 08:31:00', 8999.00, 'Pending', 'COD', 'PAYIN_COD_9012_NAG'),
(9013, 5013, '2024-01-22 19:11:00', 29990.00, 'Success', 'PhonePe', 'PAYIN_UPI_9013_BLR'),
(9014, 5014, '2024-01-28 11:01:00', 249900.00, 'Success', 'Razorpay', 'PAYIN_RZP_9014_PNQ'),
(9015, 5015, '2024-02-02 14:01:00', 3499.00, 'Refunded', 'Google Pay', 'PAYIN_GPay_9015_DEL');

INSERT INTO shipments (shipment_id, order_id, carrier, tracking_number, dispatch_date, estimated_delivery, actual_delivery, shipment_status) VALUES
(7001, 5001, 'Delhivery', 'DELHIVERY_7001_IN', '2023-10-02', '2023-10-04', '2023-10-04', 'Delivered'),
(7002, 5002, 'BlueDart', 'BD_7002_IN', '2023-10-04', '2023-10-07', '2023-10-06', 'Delivered'),
(7003, 5003, 'XpressBees', 'XB_7003_IN', '2023-10-11', '2023-10-14', '2023-10-13', 'Delivered'),
(7004, 5004, 'Ekart Logistics', 'EK_7004_IN', '2023-11-06', '2023-11-09', '2023-11-08', 'Delivered'),
(7005, 5005, 'Delhivery', 'DELHIVERY_7005_IN', '2023-11-13', '2023-11-16', '2023-11-15', 'Delivered'),
(7006, 5006, 'BlueDart', 'BD_7006_IN', '2023-11-21', '2023-11-24', '2023-11-24', 'Delivered'),
(7007, 5007, 'Delhivery', 'DELHIVERY_7007_IN', '2023-12-02', '2023-12-05', '2023-12-04', 'Delivered'),
(7008, 5008, 'Ekart Logistics', 'EK_7008_IN', '2023-12-16', '2023-12-19', '2023-12-18', 'Delivered'),
(7010, 5010, 'Shadowfax', 'SF_7010_IN', '2024-01-05', '2024-01-08', '2024-01-08', 'Delivered'),
(7011, 5011, 'XpressBees', 'XB_7011_IN', '2024-01-11', '2024-01-14', '2024-01-13', 'Delivered'),
(7013, 5013, 'Delhivery', 'DELHIVERY_7013_IN', '2024-01-23', '2024-01-25', '2024-01-25', 'Delivered'),
(7014, 5014, 'BlueDart', 'BD_7014_IN', '2024-01-29', '2024-02-01', '2024-02-01', 'Delivered');

INSERT INTO customer_reviews (review_id, product_id, user_id, rating, review_text, review_date) VALUES
(1, 101, 1001, 5, 'Ordered in Bengaluru, delivered in 18 hours! M3 Max monster performance.', '2023-10-10'),
(2, 102, 1002, 4, 'Great dev machine. Bhiwandi warehouse packaging was very secure.', '2023-10-12'),
(3, 107, 1003, 5, 'ANC is crucial for working from noisy cafes in Delhi NCR.', '2023-10-18'),
(4, 104, 1001, 5, 'Seamless UPI payment on PhonePe. Titanium iPhone feels premium.', '2023-11-15'),
(5, 109, 1004, 4, 'Great vacuum for Chennai humidity & dust. Fast delivery.', '2023-11-22'),
(6, 103, 1005, 5, 'Keyboard is iconic. Perfect Linux laptop for Hyderabad dev hub.', '2023-11-30'),
(7, 105, 1006, 5, 'S-Pen and camera zoom are great. Paid via CRED Pay, got instant cashback.', '2023-12-10'),
(8, 108, 1002, 4, 'Authentic product with Apple India warranty.', '2023-12-25'),
(9, 101, 1006, 5, 'Purchased 2nd unit for Pune software studio. Excellent.', '2024-02-05');
