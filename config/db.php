<?php
// Database Configuration File
// Smart Food Ordering and Canteen Management System

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');  // Default XAMPP password is empty
define('DB_NAME', 'smart_canteen_db');

// Create connection
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set charset to UTF-8
$conn->set_charset("utf8");

// Function to check if user is logged in
function isLoggedIn() {
    return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
}

// Function to check if user is admin
function isAdmin() {
    return isset($_SESSION['user_type']) && $_SESSION['user_type'] === 'admin';
}

// Function to check if user is student
function isStudent() {
    return isset($_SESSION['user_type']) && $_SESSION['user_type'] === 'student';
}

// Function to redirect to login if not authenticated
function requireLogin() {
    if (!isLoggedIn()) {
        header("Location: ../index.php");
        exit();
    }
}

// Function to redirect to login if not admin
function requireAdmin() {
    if (!isAdmin()) {
        header("Location: ../index.php");
        exit();
    }
}

// Function to generate unique order token
function generateOrderToken() {
    return 'ORD' . date('Ymd') . strtoupper(substr(uniqid(), -6));
}

// Function to sanitize input
function sanitizeInput($input) {
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

// Function to hash password
function hashPassword($password) {
    return password_hash($password, PASSWORD_BCRYPT);
}

// Function to verify password
function verifyPassword($password, $hash) {
    return password_verify($password, $hash);
}

// Function to get student orders
function getStudentOrders($user_id) {
    global $conn;
    $query = "SELECT o.*, COUNT(oi.order_item_id) as item_count 
              FROM orders o 
              LEFT JOIN order_items oi ON o.order_id = oi.order_id
              WHERE o.user_id = ? 
              GROUP BY o.order_id
              ORDER BY o.order_date DESC";
    
    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    return $stmt->get_result();
}

// Function to get menu items by category
function getMenuByCategory($category_id = null) {
    global $conn;
    if ($category_id) {
        $query = "SELECT m.*, c.category_name 
                  FROM menu_items m 
                  JOIN categories c ON m.category_id = c.category_id
                  WHERE m.category_id = ? AND m.is_available = TRUE
                  ORDER BY m.food_name";
        $stmt = $conn->prepare($query);
        $stmt->bind_param("i", $category_id);
    } else {
        $query = "SELECT m.*, c.category_name 
                  FROM menu_items m 
                  JOIN categories c ON m.category_id = c.category_id
                  WHERE m.is_available = TRUE
                  ORDER BY c.category_name, m.food_name";
        $stmt = $conn->prepare($query);
    }
    $stmt->execute();
    return $stmt->get_result();
}

// Function to get all categories
function getCategories() {
    global $conn;
    $query = "SELECT * FROM categories WHERE is_active = TRUE ORDER BY category_name";
    $stmt = $conn->prepare($query);
    $stmt->execute();
    return $stmt->get_result();
}

?>
