USE ec;

-- Insert categories
INSERT INTO categories (category_name) VALUES
('Apparel'),
('Electronics'),
('Home');

-- Insert products
INSERT INTO products (sku, product_name, category_id, cost_price, list_price) VALUES
('TSHIRT-RED', 'T-Shirt Red', 1, 5.00, 12.99),
('TSHIRT-BLK', 'T-Shirt Black', 1, 5.50, 14.99),
('EARBUD-100', 'Wireless Earbuds', 2, 18.00, 39.99),
('MUG-001', 'Coffee Mug', 3, 2.20, 7.99);

-- Insert channels
INSERT INTO channels (channel_name) VALUES
('Google Ads'),
('Meta Ads'),
('Email'),
('Direct');

-- Insert channel spend
INSERT INTO channel_spend (spend_date, channel_id, spend) VALUES
('2025-08-15', 1, 120.00), ('2025-08-15', 2, 80.00), ('2025-08-15', 3, 10.00),
('2025-08-16', 1, 150.00), ('2025-08-16', 2, 60.00), ('2025-08-16', 3, 12.00),
('2025-08-17', 1, 90.00), ('2025-08-17', 2, 90.00), ('2025-08-17', 3, 8.00),
('2025-08-18', 1, 100.00), ('2025-08-18', 2, 70.00), ('2025-08-18', 3, 11.00),
('2025-08-19', 1, 110.00), ('2025-08-19', 2, 85.00), ('2025-08-19', 3, 9.00);

-- Insert customers
INSERT INTO customers (email, first_name, last_name, country, signup_at) VALUES
('riya@example.com', 'Riya', 'Sharma', 'IN', '2025-08-10'),
('arjun@example.com', 'Arjun', 'Patel', 'IN', '2025-08-12'),
('neha@example.com', 'Neha', 'Khan', 'US', '2025-08-12');

-- Insert orders
INSERT INTO orders (customer_id, order_datetime, channel_id, ship_country, status) VALUES
(1, '2025-08-15 09:10:00', 1, 'IN', 'PAID'),
(2, '2025-08-15 11:30:00', 2, 'IN', 'PAID'),
(1, '2025-08-16 18:05:00', 3, 'IN', 'PAID'),
(3, '2025-08-17 14:22:00', 4, 'US', 'PAID'),
(2, '2025-08-18 20:10:00', 1, 'IN', 'REFUNDED');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 2, 12.99, 0.00),
(1, 4, 1, 7.99, 0.00),
(2, 3, 1, 39.99, 5.00),
(3, 2, 1, 14.99, 2.00),
(3, 4, 2, 7.99, 0.50),
(4, 3, 2, 39.99, 0.00),
(5, 1, 1, 12.99, 0.00);

-- Insert payments
INSERT INTO payments (order_id, paid_amount, paid_at, method) VALUES
(1, 33.97, '2025-08-15 09:12:00', 'CARD'),
(2, 34.99, '2025-08-15 11:31:00', 'UPI'),
(3, 28.47, '2025-08-16 18:06:00', 'PAYPAL'),
(4, 79.98, '2025-08-17 14:23:00', 'CARD'),
(5, 12.99, '2025-08-18 20:11:00', 'CARD');
