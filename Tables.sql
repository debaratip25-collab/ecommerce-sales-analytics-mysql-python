CREATE SCHEMA IF NOT EXISTS ec;
USE ec;

-- Categories table
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(255) UNIQUE NOT NULL
);

-- Products table
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(100) UNIQUE NOT NULL,
  product_name VARCHAR(255) NOT NULL,
  category_id INT,
  cost_price DECIMAL(10,2) NOT NULL CHECK (cost_price >= 0),
  list_price DECIMAL(10,2) NOT NULL CHECK (list_price >= 0),
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Customers table
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  country VARCHAR(100),
  signup_at DATE NOT NULL DEFAULT (CURDATE())
);

-- Channels table
CREATE TABLE channels (
  channel_id INT AUTO_INCREMENT PRIMARY KEY,
  channel_name VARCHAR(255) UNIQUE NOT NULL
);

-- Channel spend tracking
CREATE TABLE channel_spend (
  spend_date DATE NOT NULL,
  channel_id INT NOT NULL,
  spend DECIMAL(12,2) NOT NULL CHECK (spend >= 0),
  PRIMARY KEY (spend_date, channel_id),
  FOREIGN KEY (channel_id) REFERENCES channels(channel_id)
);

-- Orders table
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_datetime TIMESTAMP NOT NULL,
  channel_id INT,
  ship_country VARCHAR(100),
  status VARCHAR(50) NOT NULL CHECK (status IN ('PAID','PENDING','CANCELLED','REFUNDED')),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (channel_id) REFERENCES channels(channel_id)
);

-- Order items (line items per order)
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  discount DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (discount >= 0),
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Payments table
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  paid_amount DECIMAL(12,2) NOT NULL CHECK (paid_amount >= 0),
  paid_at TIMESTAMP NOT NULL,
  method VARCHAR(50) CHECK (method IN ('CARD','UPI','COD','PAYPAL','OTHER')),
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);