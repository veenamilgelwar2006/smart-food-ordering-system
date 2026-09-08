-- Smart Food Ordering and Canteen Management System
-- Complete MySQL Database Design (3NF)
-- Created for DBMS Mini Project

-- =====================================================
-- CREATE DATABASE
-- =====================================================
CREATE DATABASE IF NOT EXISTS smart_canteen_db;
USE smart_canteen_db;

-- =====================================================
-- DROP EXISTING TABLES (For Fresh Install)
-- =====================================================
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS waste_log;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;

-- =====================================================
-- 1. USERS TABLE (Students & Admins)
-- =====================================================
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(15),
  password_hash VARCHAR(255) NOT NULL,
  user_type ENUM('student', 'admin') NOT NULL DEFAULT 'student',
  roll_number VARCHAR(20) UNIQUE,
  department VARCHAR(50),
  semester INT,
  wallet_balance DECIMAL(10, 2) DEFAULT 0.00,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_user_type (user_type),
  INDEX idx_roll_number (roll_number)
);

-- =====================================================
-- 2. CATEGORIES TABLE (Food Categories)
-- =====================================================
CREATE TABLE categories (
  category_id INT PRIMARY KEY AUTO_INCREMENT,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_category_name (category_name)
);

-- =====================================================
-- 3. MENU_ITEMS TABLE (Food Items)
-- =====================================================
CREATE TABLE menu_items (
  menu_item_id INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT NOT NULL,
  food_name VARCHAR(100) NOT NULL,
  description TEXT,
  price DECIMAL(8, 2) NOT NULL CHECK (price > 0),
  quantity_available INT NOT NULL DEFAULT 0 CHECK (quantity_available >= 0),
  image_url VARCHAR(255),
  preparation_time INT DEFAULT 15,
  is_vegetarian BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE,
  INDEX idx_category_id (category_id),
  INDEX idx_food_name (food_name),
  INDEX idx_is_available (is_available)
);

-- =====================================================
-- 4. ORDERS TABLE
-- =====================================================
CREATE TABLE orders (
  order_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  order_token VARCHAR(20) NOT NULL UNIQUE,
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
  status ENUM('Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled') DEFAULT 'Pending',
  payment_method ENUM('wallet', 'cash') DEFAULT 'wallet',
  delivery_time TIMESTAMP NULL,
  special_instructions TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_order_token (order_token),
  INDEX idx_status (status),
  INDEX idx_order_date (order_date)
);

-- =====================================================
-- 5. ORDER_ITEMS TABLE (Items in Each Order)
-- =====================================================
CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY AUTO_INCREMENT,
  order_id INT NOT NULL,
  menu_item_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(8, 2) NOT NULL,
  subtotal DECIMAL(10, 2) NOT NULL,
  special_requests TEXT,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE CASCADE,
  INDEX idx_order_id (order_id),
  INDEX idx_menu_item_id (menu_item_id)
);

-- =====================================================
-- 6. WASTE_LOG TABLE (Food Waste Tracking)
-- =====================================================
CREATE TABLE waste_log (
  waste_id INT PRIMARY KEY AUTO_INCREMENT,
  menu_item_id INT NOT NULL,
  quantity_wasted INT NOT NULL CHECK (quantity_wasted > 0),
  waste_date DATE NOT NULL,
  waste_time TIME,
  reason VARCHAR(100),
  estimated_value DECIMAL(10, 2),
  logged_by INT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE CASCADE,
  FOREIGN KEY (logged_by) REFERENCES users(user_id) ON DELETE SET NULL,
  INDEX idx_menu_item_id (menu_item_id),
  INDEX idx_waste_date (waste_date)
);

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert Users (Students & Admins)
INSERT INTO users (full_name, email, phone, password_hash, user_type, roll_number, department, semester, wallet_balance, is_active) VALUES
('Admin User', 'admin@canteen.com', '9876543210', '$2y$10$YourHashedPasswordHere', 'admin', NULL, 'Administration', NULL, 0.00, TRUE),
('Rajesh Kumar', 'rajesh@student.com', '9999999001', '$2y$10$StudentPassword123', 'student', 'CSE001', 'Computer Science', 4, 500.00, TRUE),
('Priya Singh', 'priya@student.com', '9999999002', '$2y$10$StudentPassword456', 'student', 'CSE002', 'Computer Science', 4, 750.50, TRUE),
('Amit Patel', 'amit@student.com', '9999999003', '$2y$10$StudentPassword789', 'student', 'ECE001', 'Electronics', 3, 1200.00, TRUE),
('Neha Verma', 'neha@student.com', '9999999004', '$2y$10$StudentPassword101', 'student', 'ECE002', 'Electronics', 3, 350.75, TRUE),
('Vikram Sharma', 'vikram@student.com', '9999999005', '$2y$10$StudentPassword202', 'student', 'ME001', 'Mechanical', 2, 600.00, TRUE),
('Pooja Gupta', 'pooja@student.com', '9999999006', '$2y$10$StudentPassword303', 'student', 'ME002', 'Mechanical', 2, 900.25, TRUE),
('Karan Desai', 'karan@student.com', '9999999007', '$2y$10$StudentPassword404', 'student', 'CIVIL001', 'Civil', 1, 2000.00, TRUE);

-- Insert Food Categories
INSERT INTO categories (category_name, description, is_active) VALUES
('Breakfast', 'Morning breakfast items', TRUE),
('Lunch', 'Lunch meals and curries', TRUE),
('Snacks', 'Quick snacks and appetizers', TRUE),
('Beverages', 'Drinks and beverages', TRUE),
('Desserts', 'Sweet items and desserts', TRUE);

-- Insert Menu Items
INSERT INTO menu_items (category_id, food_name, description, price, quantity_available, image_url, preparation_time, is_vegetarian, is_available) VALUES
-- Breakfast
(1, 'Aloo Parantha', 'Potato stuffed Indian bread', 40.00, 50, 'breakfast_parantha.jpg', 20, TRUE, TRUE),
(1, 'Idli Sambhar', 'South Indian steamed cakes with lentil stew', 35.00, 60, 'breakfast_idli.jpg', 15, TRUE, TRUE),
(1, 'Poha', 'Flattened rice breakfast', 30.00, 45, 'breakfast_poha.jpg', 10, TRUE, TRUE),
(1, 'Scrambled Eggs Toast', 'Eggs on toasted bread', 50.00, 40, 'breakfast_eggs.jpg', 12, FALSE, TRUE),

-- Lunch
(2, 'Chicken Biryani', 'Fragrant rice with spiced chicken', 120.00, 30, 'lunch_biryani_chicken.jpg', 30, FALSE, TRUE),
(2, 'Veg Biryani', 'Mixed vegetable biryani', 90.00, 35, 'lunch_biryani_veg.jpg', 30, TRUE, TRUE),
(2, 'Butter Chicken', 'Creamy tomato-based chicken curry', 110.00, 25, 'lunch_butter_chicken.jpg', 25, FALSE, TRUE),
(2, 'Dal Makhani', 'Creamy lentil curry', 80.00, 40, 'lunch_dal_makhani.jpg', 20, TRUE, TRUE),
(2, 'Paneer Tikka Masala', 'Cottage cheese in tomato gravy', 95.00, 30, 'lunch_paneer_tikka.jpg', 20, TRUE, TRUE),

-- Snacks
(3, 'Samosa', 'Crispy fried pastry with potato filling', 15.00, 100, 'snacks_samosa.jpg', 10, TRUE, TRUE),
(3, 'Pakora', 'Fried vegetable fritters', 20.00, 80, 'snacks_pakora.jpg', 8, TRUE, TRUE),
(3, 'Chaat Masala Fries', 'Spiced French fries', 35.00, 70, 'snacks_fries.jpg', 12, TRUE, TRUE),
(3, 'Chicken Momos', 'Steamed dumplings with chicken', 40.00, 50, 'snacks_momos.jpg', 15, FALSE, TRUE),
(3, 'Paneer Tikka', 'Grilled paneer cubes', 45.00, 40, 'snacks_paneer_tikka.jpg', 12, TRUE, TRUE),

-- Beverages
(4, 'Masala Chai', 'Spiced Indian tea', 20.00, 150, 'beverage_chai.jpg', 5, TRUE, TRUE),
(4, 'Coffee', 'Fresh brewed coffee', 25.00, 120, 'beverage_coffee.jpg', 5, TRUE, TRUE),
(4, 'Mango Lassi', 'Yogurt drink with mango', 40.00, 60, 'beverage_lassi.jpg', 5, TRUE, TRUE),
(4, 'Fresh Orange Juice', 'Freshly squeezed orange juice', 50.00, 50, 'beverage_orange_juice.jpg', 3, TRUE, TRUE),

-- Desserts
(5, 'Gulab Jamun', 'Sweet fried dough balls in syrup', 30.00, 40, 'dessert_gulab_jamun.jpg', 10, TRUE, TRUE),
(5, 'Kheer', 'Rice pudding with milk', 35.00, 35, 'dessert_kheer.jpg', 15, TRUE, TRUE),
(5, 'Ice Cream Sundae', 'Ice cream with toppings', 60.00, 50, 'dessert_ice_cream.jpg', 3, TRUE, TRUE),
(5, 'Brownie', 'Chocolate brownie', 45.00, 45, 'dessert_brownie.jpg', 8, TRUE, TRUE);

-- Insert Orders
INSERT INTO orders (user_id, order_token, total_amount, status, payment_method, special_instructions) VALUES
(2, 'ORD202501001', 155.00, 'Completed', 'wallet', 'Less spice please'),
(3, 'ORD202501002', 230.00, 'Completed', 'wallet', 'Extra butter in dal'),
(2, 'ORD202501003', 120.00, 'Ready', 'wallet', NULL),
(4, 'ORD202501004', 190.00, 'Preparing', 'wallet', 'No onion'),
(5, 'ORD202501005', 85.00, 'Pending', 'cash', NULL),
(3, 'ORD202501006', 275.50, 'Completed', 'wallet', 'Extra chaat masala'),
(6, 'ORD202501007', 110.00, 'Ready', 'wallet', NULL),
(7, 'ORD202501008', 150.00, 'Preparing', 'wallet', 'Very hot and spicy');

-- Insert Order Items
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price, subtotal, special_requests) VALUES
-- Order 1
(1, 1, 1, 40.00, 40.00, 'Extra oil'),
(1, 4, 2, 50.00, 100.00, 'Well done'),
(1, 16, 1, 20.00, 20.00, NULL),

-- Order 2
(2, 5, 1, 120.00, 120.00, 'Medium spice'),
(2, 8, 1, 80.00, 80.00, NULL),
(2, 17, 1, 25.00, 25.00, NULL),
(2, 20, 1, 50.00, 50.00, NULL),

-- Order 3
(3, 7, 1, 95.00, 95.00, NULL),
(3, 11, 1, 20.00, 20.00, NULL),
(3, 22, 1, 25.00, 25.00, NULL),

-- Order 4
(4, 6, 1, 90.00, 90.00, 'Less oil'),
(4, 13, 1, 35.00, 35.00, NULL),
(4, 18, 2, 40.00, 80.00, NULL),

-- Order 5
(5, 11, 2, 20.00, 40.00, NULL),
(5, 16, 1, 20.00, 20.00, NULL),
(5, 24, 1, 25.00, 25.00, NULL),

-- Order 6
(6, 8, 2, 80.00, 160.00, NULL),
(6, 12, 2, 35.00, 70.00, NULL),
(6, 23, 1, 45.00, 45.00, NULL),

-- Order 7
(7, 2, 2, 35.00, 70.00, NULL),
(7, 16, 2, 20.00, 40.00, NULL),

-- Order 8
(8, 5, 1, 120.00, 120.00, 'Extra spicy'),
(8, 11, 1, 20.00, 20.00, NULL),
(8, 21, 1, 30.00, 30.00, NULL);

-- Insert Waste Log
INSERT INTO waste_log (menu_item_id, quantity_wasted, waste_date, waste_time, reason, estimated_value, logged_by, notes) VALUES
(1, 5, '2025-09-07', '14:30:00', 'Expired', 200.00, 1, 'Parantha not sold, disposal done'),
(5, 2, '2025-09-07', '15:45:00', 'Burnt', 240.00, 1, 'Cooking error'),
(11, 10, '2025-09-06', '13:20:00', 'Spoiled', 200.00, 1, 'Quality issue'),
(16, 20, '2025-09-05', '16:00:00', 'Not sold', 400.00, 1, 'End of day disposal'),
(24, 3, '2025-09-04', '17:30:00', 'Damaged', 135.00, 1, 'Packaging damage');

-- =====================================================
-- CREATE USEFUL VIEWS
-- =====================================================

-- View 1: Student Order Summary
CREATE OR REPLACE VIEW student_order_summary AS
SELECT 
    u.user_id,
    u.full_name,
    u.roll_number,
    u.email,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    u.wallet_balance
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.status != 'Cancelled'
WHERE u.user_type = 'student'
GROUP BY u.user_id, u.full_name, u.roll_number, u.email, u.wallet_balance
ORDER BY total_spent DESC;

-- View 2: Daily Sales Report
CREATE OR REPLACE VIEW daily_sales_report AS
SELECT 
    DATE(o.order_date) AS order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS unique_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.total_amount) AS min_order_value,
    MAX(o.total_amount) AS max_order_value
FROM orders o
WHERE o.status != 'Cancelled'
GROUP BY DATE(o.order_date)
ORDER BY order_date DESC;

-- View 3: Menu Item Sales Performance
CREATE OR REPLACE VIEW menu_item_sales_performance AS
SELECT 
    m.menu_item_id,
    m.food_name,
    c.category_name,
    m.price,
    COUNT(oi.order_item_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.quantity) AS avg_quantity_per_order,
    ROUND(SUM(oi.subtotal) / COUNT(oi.order_item_id), 2) AS avg_revenue_per_order
FROM menu_items m
LEFT JOIN order_items oi ON m.menu_item_id = oi.menu_item_id
LEFT JOIN categories c ON m.category_id = c.category_id
GROUP BY m.menu_item_id, m.food_name, c.category_name, m.price
ORDER BY total_revenue DESC;

-- View 4: Category-wise Sales
CREATE OR REPLACE VIEW category_sales_analysis AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(DISTINCT m.menu_item_id) AS total_items,
    COUNT(DISTINCT oi.order_item_id) AS total_items_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS category_revenue,
    ROUND(AVG(oi.subtotal), 2) AS avg_item_value,
    ROUND(SUM(oi.subtotal) / SUM(oi.quantity), 2) AS avg_price_per_item
FROM categories c
LEFT JOIN menu_items m ON c.category_id = m.category_id
LEFT JOIN order_items oi ON m.menu_item_id = oi.menu_item_id
GROUP BY c.category_id, c.category_name
ORDER BY category_revenue DESC;

-- View 5: Waste Report Analysis
CREATE OR REPLACE VIEW waste_analysis_report AS
SELECT 
    DATE(w.waste_date) AS date,
    m.food_name,
    c.category_name,
    SUM(w.quantity_wasted) AS total_quantity_wasted,
    SUM(w.estimated_value) AS total_waste_value,
    GROUP_CONCAT(DISTINCT w.reason) AS waste_reasons,
    COUNT(w.waste_id) AS waste_incidents
FROM waste_log w
LEFT JOIN menu_items m ON w.menu_item_id = m.menu_item_id
LEFT JOIN categories c ON m.category_id = c.category_id
GROUP BY DATE(w.waste_date), m.food_name, c.category_name
ORDER BY DATE(w.waste_date) DESC, total_waste_value DESC;

-- View 6: Order Status Summary
CREATE OR REPLACE VIEW order_status_summary AS
SELECT 
    o.status,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_amount,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.order_date) AS oldest_order,
    MAX(o.order_date) AS newest_order
FROM orders o
GROUP BY o.status
ORDER BY order_count DESC;

-- =====================================================
-- USEFUL SQL QUERIES FOR DBMS CONCEPTS DEMONSTRATION
-- =====================================================

-- Query 1: INNER JOIN - Orders with student details
-- Demonstrates INNER JOIN between orders and users
SELECT 
    o.order_id,
    o.order_token,
    u.full_name,
    u.roll_number,
    o.order_date,
    o.total_amount,
    o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id
WHERE o.order_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY o.order_date DESC;

-- Query 2: LEFT JOIN - All students with their order count
-- Demonstrates LEFT JOIN to show students who may not have ordered
SELECT 
    u.user_id,
    u.full_name,
    u.roll_number,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.total_amount), 0) AS total_spending
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.status != 'Cancelled'
WHERE u.user_type = 'student'
GROUP BY u.user_id, u.full_name, u.roll_number
ORDER BY total_spending DESC;

-- Query 3: Multiple JOINs - Complete order details with items
-- Demonstrates joining multiple tables
SELECT 
    o.order_id,
    o.order_token,
    u.full_name,
    o.order_date,
    m.food_name,
    c.category_name,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_item_id = m.menu_item_id
INNER JOIN categories c ON m.category_id = c.category_id
ORDER BY o.order_date DESC, o.order_id;

-- Query 4: GROUP BY and HAVING - Students who spent more than 500
-- Demonstrates GROUP BY with aggregate functions and HAVING clause
SELECT 
    u.user_id,
    u.full_name,
    u.department,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_amount,
    AVG(o.total_amount) AS avg_order_value
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
WHERE u.user_type = 'student' AND o.status != 'Cancelled'
GROUP BY u.user_id, u.full_name, u.department
HAVING SUM(o.total_amount) > 100
ORDER BY total_amount DESC;

-- Query 5: Aggregate Functions - Sales Statistics
-- Demonstrates COUNT, SUM, AVG, MIN, MAX
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.user_id) AS total_customers,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.total_amount) AS min_order_value,
    MAX(o.total_amount) AS max_order_value,
    ROUND(STDDEV(o.total_amount), 2) AS revenue_stddev
FROM orders o
WHERE o.status != 'Cancelled';

-- Query 6: Subquery - Top 5 Most Ordered Items
-- Demonstrates subqueries with aggregate functions
SELECT 
    m.menu_item_id,
    m.food_name,
    c.category_name,
    (SELECT SUM(oi.quantity) FROM order_items oi WHERE oi.menu_item_id = m.menu_item_id) AS total_quantity,
    (SELECT COUNT(DISTINCT oi.order_id) FROM order_items oi WHERE oi.menu_item_id = m.menu_item_id) AS order_count,
    m.price
FROM menu_items m
LEFT JOIN categories c ON m.category_id = c.category_id
WHERE (SELECT COUNT(DISTINCT oi.order_id) FROM order_items oi WHERE oi.menu_item_id = m.menu_item_id) > 0
ORDER BY total_quantity DESC
LIMIT 5;

-- Query 7: UNION - Combined report of active and completed orders
-- Demonstrates UNION operator
SELECT 
    order_id,
    order_token,
    'Pending/Processing' AS order_status,
    total_amount
FROM orders
WHERE status IN ('Pending', 'Preparing', 'Ready')
UNION
SELECT 
    order_id,
    order_token,
    'Completed' AS order_status,
    total_amount
FROM orders
WHERE status = 'Completed'
ORDER BY order_status;

-- Query 8: Complex Subquery - Students who ordered the most expensive item
-- Demonstrates nested subqueries
SELECT DISTINCT
    u.user_id,
    u.full_name,
    u.roll_number,
    m.food_name,
    m.price
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN menu_items m ON oi.menu_item_id = m.menu_item_id
WHERE m.price = (SELECT MAX(price) FROM menu_items);

-- Query 9: Window Function Style - Ranking items by sales
-- Demonstrates ranking and ordering
SELECT 
    @rank := @rank + 1 AS rank,
    m.food_name,
    c.category_name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS revenue
FROM menu_items m
LEFT JOIN order_items oi ON m.menu_item_id = oi.menu_item_id
LEFT JOIN categories c ON m.category_id = c.category_id
LEFT JOIN orders o ON oi.order_id = o.order_id
CROSS JOIN (SELECT @rank := 0) AS init
WHERE o.status != 'Cancelled'
GROUP BY m.menu_item_id, m.food_name, c.category_name
ORDER BY revenue DESC
LIMIT 10;

-- Query 10: Waste Analysis - Total waste by category
-- Demonstrates GROUP BY with waste data
SELECT 
    c.category_name,
    COUNT(w.waste_id) AS waste_incidents,
    SUM(w.quantity_wasted) AS total_quantity_wasted,
    SUM(w.estimated_value) AS total_waste_value,
    ROUND(AVG(w.estimated_value), 2) AS avg_waste_per_incident,
    GROUP_CONCAT(DISTINCT w.reason) AS common_reasons
FROM waste_log w
INNER JOIN menu_items m ON w.menu_item_id = m.menu_item_id
INNER JOIN categories c ON m.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_waste_value DESC;

-- Query 11: Date-based Analysis - Weekly sales trend
-- Demonstrates DATE functions and ordering
SELECT 
    WEEK(o.order_date) AS week_number,
    DATE(o.order_date) AS date,
    COUNT(DISTINCT o.order_id) AS orders_placed,
    SUM(o.total_amount) AS weekly_revenue,
    AVG(o.total_amount) AS avg_order_value
FROM orders o
WHERE o.status != 'Cancelled' AND o.order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY WEEK(o.order_date), DATE(o.order_date)
ORDER BY date DESC;

-- Query 12: Inventory Status - Items by availability
-- Demonstrates CASE statement with counts
SELECT 
    c.category_name,
    m.food_name,
    m.quantity_available,
    CASE 
        WHEN m.quantity_available = 0 THEN 'Out of Stock'
        WHEN m.quantity_available < 10 THEN 'Low Stock'
        WHEN m.quantity_available < 50 THEN 'Medium Stock'
        ELSE 'Adequate Stock'
    END AS stock_status,
    m.price,
    m.is_available
FROM menu_items m
INNER JOIN categories c ON m.category_id = c.category_id
ORDER BY c.category_name, m.quantity_available ASC;

-- =====================================================
-- UPDATE EXAMPLES
-- =====================================================

-- Update 1: Update order status
-- UPDATE orders SET status = 'Ready', updated_at = NOW() WHERE order_id = 1;

-- Update 2: Update menu item availability
-- UPDATE menu_items SET quantity_available = quantity_available - 5 WHERE menu_item_id = 1;

-- Update 3: Update student wallet balance
-- UPDATE users SET wallet_balance = wallet_balance - 100 WHERE user_id = 2;

-- =====================================================
-- DELETE EXAMPLES
-- =====================================================

-- Delete 1: Delete cancelled orders older than 30 days
-- DELETE FROM orders WHERE status = 'Cancelled' AND order_date < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Delete 2: Delete waste log entries older than 90 days
-- DELETE FROM waste_log WHERE waste_date < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- =====================================================
-- COMPLEX QUERY EXAMPLES FOR REPORTS
-- =====================================================

-- Report 1: Daily Dashboard Summary
SELECT 
    DATE(NOW()) AS report_date,
    (SELECT COUNT(*) FROM orders WHERE DATE(order_date) = DATE(NOW())) AS orders_today,
    (SELECT SUM(total_amount) FROM orders WHERE DATE(order_date) = DATE(NOW()) AND status != 'Cancelled') AS revenue_today,
    (SELECT COUNT(*) FROM users WHERE DATE(created_at) = DATE(NOW()) AND user_type = 'student') AS new_students_today,
    (SELECT SUM(estimated_value) FROM waste_log WHERE DATE(waste_date) = DATE(NOW())) AS waste_today;

-- Report 2: Student Spending Profile
SELECT 
    u.user_id,
    u.full_name,
    u.department,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.total_amount) AS spending,
    AVG(o.total_amount) AS avg_order,
    MAX(o.order_date) AS last_order,
    DATEDIFF(NOW(), MAX(o.order_date)) AS days_since_order
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.status != 'Cancelled'
WHERE u.user_type = 'student'
GROUP BY u.user_id, u.full_name, u.department
ORDER BY spending DESC;

-- Report 3: Order Fulfillment Analysis
SELECT 
    status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage,
    SUM(total_amount) AS revenue,
    AVG(total_amount) AS avg_amount
FROM orders
WHERE order_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY status;

-- =====================================================
-- END OF DATABASE SCHEMA AND QUERIES
-- =====================================================
