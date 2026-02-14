const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile',
    multipleStatements: true
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL Database');
    seedData();
});

const seedData = async () => {
    try {
        const query = (sql, params) => {
            return new Promise((resolve, reject) => {
                db.query(sql, params, (err, result) => {
                    if (err) reject(err);
                    else resolve(result);
                });
            });
        };

        console.log('Disabling FK Checks...');
        await query('SET FOREIGN_KEY_CHECKS = 0');

        console.log('Truncating tables...');
        await query('TRUNCATE TABLE order_items');
        await query('TRUNCATE TABLE orders');
        await query('TRUNCATE TABLE products');
        await query('TRUNCATE TABLE categories');
        await query('TRUNCATE TABLE restaurant_tables');
        // await query('TRUNCATE TABLE users'); // Dropping instead

        console.log('Seeding Users...');
        await query('DROP TABLE IF EXISTS users');
        await query(`CREATE TABLE users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            email VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            role ENUM('admin', 'staff', 'kitchen', 'customer') DEFAULT 'customer',
            token VARCHAR(255)
        )`);
        await query(`INSERT INTO users (name, email, password, role, token) VALUES 
        ('Admin User', 'admin@resto.com', 'admin123', 'admin', 'admin-token-123'),
        ('Staff User', 'staff@resto.com', 'staff123', 'staff', 'staff-token-123'),
        ('Chef User', 'chef@resto.com', 'chef123', 'kitchen', 'chef-token-123'),
        ('Customer User', 'user@resto.com', 'user123', 'customer', 'user-token-123')`);

        console.log('Seeding Tables...');
        // await query('DELETE FROM restaurant_tables'); // Already truncated
        await query(`INSERT INTO restaurant_tables (app_id, number, capacity, status, x, y) VALUES 
        ('table_1', '1', 4, 'available', 0, 0),
        ('table_2', '2', 2, 'available', 1, 0),
        ('table_3', '3', 6, 'available', 2, 0),
        ('table_4', '4', 4, 'occupied', 0, 1),
        ('table_5', '5', 2, 'available', 1, 1)`);

        console.log('Seeding Categories...');
        // await query('DELETE FROM categories'); // Already truncated
        await query(`INSERT INTO categories (id, name, description) VALUES 
        (1, 'Makanan Utama', 'Hidangan utama yang mengenyangkan'),
        (2, 'Minuman', 'Berbagai macam minuman segar'),
        (3, 'Camilan', 'Makanan ringan untuk teman ngobrol')`);

        console.log('Seeding Products...');
        // await query('DELETE FROM products'); // Already truncated
        await query(`INSERT INTO products (name, description, price, imageUrl, categoryId, stock, isAvailable) VALUES 
        ('Nasi Goreng Spesial', 'Nasi goreng dengan telur, ayam, dan sosis', 25000, 'https://via.placeholder.com/150', 1, 50, true),
        ('Ayam Bakar Madu', 'Ayam bakar dengan bumbu madu spesial', 30000, 'https://via.placeholder.com/150', 1, 20, true),
        ('Es Teh Manis', 'Teh manis dingin segar', 5000, 'https://via.placeholder.com/150', 2, 100, true),
        ('Jus Jeruk', 'Jus jeruk murni tanpa gula', 12000, 'https://via.placeholder.com/150', 2, 30, true),
        ('Kentang Goreng', 'Kentang goreng renyah dengan saus sambal', 15000, 'https://via.placeholder.com/150', 3, 40, true),
        ('Pisang Bakar Coklat', 'Pisang bakar dengan topping coklat dan keju', 18000, 'https://via.placeholder.com/150', 3, 25, true)`);

        console.log('Data seeded successfully!');

        const count = await query('SELECT count(*) as count FROM users');
        console.log('Users count:', count[0].count);

        await query('SET FOREIGN_KEY_CHECKS = 1');
        db.end();
    } catch (err) {
        console.error('Error seeding data:', err);
        db.end();
    }
};
