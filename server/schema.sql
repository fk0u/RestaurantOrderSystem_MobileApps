-- Database: RestoMobile
CREATE DATABASE IF NOT EXISTS RestoMobile;
USE RestoMobile;

-- Drop Tables in Reverse Dependency Order
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS restaurant_tables;
DROP TABLE IF EXISTS users;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Should be hashed in prod
            role ENUM('admin', 'staff', 'kitchen', 'customer') DEFAULT 'customer',
    token VARCHAR(255) -- Simple token for demo
);

-- Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT
);

-- Products Table (Updated)
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    imageUrl VARCHAR(255),
    categoryId INT,
    description TEXT,
    stock INT DEFAULT 0,
    isAvailable BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE SET NULL
);

-- Tables Table
CREATE TABLE IF NOT EXISTS restaurant_tables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    app_id VARCHAR(50) UNIQUE, -- table_1, table_2 etc used in app
    number VARCHAR(10) NOT NULL,
    capacity INT NOT NULL,
    status ENUM('available', 'occupied', 'reserved') DEFAULT 'available',
    x DOUBLE NOT NULL,
    y DOUBLE NOT NULL
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    app_id VARCHAR(50) UNIQUE, -- ORD-XXXXX used in app
    userId INT, -- linkage to users table, could be NULL for guest
    guestName VARCHAR(255),
    totalPrice DECIMAL(10, 2) NOT NULL,
    status ENUM('Sedang Diproses', 'Sedang Dimasak', 'Siap Saji', 'Selesai', 'Dibatalkan') DEFAULT 'Sedang Diproses',
    orderType ENUM('dine_in', 'takeaway', 'delivery') NOT NULL,
    queueNumber INT,
    tableId INT, -- link to restaurant_tables.id
    paymentStatus ENUM('pending', 'paid') DEFAULT 'pending',
    paymentMethod VARCHAR(50),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tableId) REFERENCES restaurant_tables(id)
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    orderId INT NOT NULL,
    productId INT NOT NULL,
    productName VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    note TEXT,
    modifiers JSON, -- Storing modifier list as JSON array
    FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (productId) REFERENCES products(id)
);

-- Seed Data

-- Users
INSERT INTO users (name, email, password, role, token) VALUES 
('Admin User', 'admin@resto.com', 'admin123', 'admin', 'admin-token-123'),
('Staff User', 'staff@resto.com', 'staff123', 'staff', 'staff-token-123'),
('Chef User', 'chef@resto.com', 'chef123', 'kitchen', 'chef-token-123'),
('Customer User', 'user@resto.com', 'user123', 'customer', 'user-token-123')
ON DUPLICATE KEY UPDATE email=email;

-- Categories
INSERT INTO categories (name, description) VALUES
('Makanan', 'Aneka makanan berat dan ringan'),
('Minuman', 'Aneka minuman segar dan hangat')
ON DUPLICATE KEY UPDATE name=name;

-- Products
INSERT INTO products (name, price, imageUrl, categoryId, description, stock, isAvailable) VALUES
('Nasi Goreng Spesial', 25000, 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?q=80&w=1000&auto=format&fit=crop', 1, 'Nasi goreng dengan telur, ayam, dan sate', 50, TRUE),
('Ayam Bakar Madu', 30000, 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=1000&auto=format&fit=crop', 1, 'Ayam bakar dengan bumbu madu spesial', 30, TRUE),
('Sate Ayam Madura', 20000, 'https://images.unsplash.com/photo-1596701890104-d57b3286dc51?q=80&w=1000&auto=format&fit=crop', 1, 'Sate ayam dengan bumbu kacang khas Madura', 40, TRUE),
('Es Teh Manis', 5000, 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=1000&auto=format&fit=crop', 2, 'Teh manis segar dengan es batu', 100, TRUE),
('Es Jeruk Peras', 8000, 'https://images.unsplash.com/photo-1616118132534-381148898bb4?q=80&w=1000&auto=format&fit=crop', 2, 'Jeruk peras asli dengan es batu', 80, TRUE),
('Kopi Susu Gula Aren', 18000, 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=1000&auto=format&fit=crop', 2, 'Kopi susu kekinian dengan gula aren', 60, TRUE)
ON DUPLICATE KEY UPDATE name=name;

-- Tables (Grid Layout 4 columns)
-- T1(0,0), T2(1,0), T3(2,0), T4(3,0)
-- T5(0,1), T6(1,1), T7(2,1), T8(3,1)
-- T9(0,2), T10(1,2)
INSERT IGNORE INTO restaurant_tables (app_id, number, capacity, status, x, y) VALUES
('table_1', 'T1', 2, 'available', 0, 0),
('table_2', 'T2', 2, 'available', 1, 0),
('table_3', 'T3', 2, 'available', 2, 0),
('table_4', 'T4', 2, 'available', 3, 0),
('table_5', 'T5', 4, 'occupied', 0, 1),
('table_6', 'T6', 4, 'available', 1, 1),
('table_7', 'T7', 4, 'available', 2, 1),
('table_8', 'T8', 4, 'reserved', 3, 1),
('table_9', 'T9', 6, 'available', 0, 2),
('table_10', 'T10', 6, 'available', 1, 2);
