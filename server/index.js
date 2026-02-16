const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const port = 8000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Database Connection
const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '', // Update with your MySQL password if any
    database: 'RestoMobile',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Test Connection
db.getConnection((err, connection) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
    } else {
        console.log('Connected to MySQL Database');
        connection.release();
    }
});

// --- Auth Routes ---

// Login
app.post('/api/auth/login', (req, res) => {
    const { email, password } = req.body;
    // In production, use hashed passwords!
    const query = 'SELECT * FROM users WHERE email = ? AND password = ?';
    db.query(query, [email, password], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

        const user = results[0];
        // Don't send password back
        delete user.password;

        res.json({
            token: user.token, // Simple token
            user: user
        });
    });
});

// Register
app.post('/api/auth/register', (req, res) => {
    const { name, email, password } = req.body;

    // Check if user exists
    db.query('SELECT * FROM users WHERE email = ?', [email], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length > 0) return res.status(400).json({ error: 'Email already registered' });

        // Simple token generation
        const token = 'user-token-' + Date.now();
        const role = 'customer'; // Default role

        const insertQuery = 'INSERT INTO users (name, email, password, role, token) VALUES (?, ?, ?, ?, ?)';
        db.query(insertQuery, [name, email, password, role, token], (err, result) => {
            if (err) return res.status(500).json({ error: err.message });

            res.status(201).json({
                message: 'Registration successful',
                user: { id: result.insertId, name, email, role, token }
            });
        });
    });
});

// --- Categories Routes ---

// Get Categories
app.get('/api/categories', (req, res) => {
    const query = 'SELECT * FROM categories';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Create Category
app.post('/api/categories', (req, res) => {
    const { name, description } = req.body;
    const query = 'INSERT INTO categories (name, description) VALUES (?, ?)';
    db.query(query, [name, description], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ id: result.insertId, name, description });
    });
});

// Update Category
app.put('/api/categories/:id', (req, res) => {
    const { id } = req.params;
    const { name, description } = req.body;
    const query = 'UPDATE categories SET name = ?, description = ? WHERE id = ?';
    db.query(query, [name, description, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Category not found' });
        res.json({ message: 'Category updated' });
    });
});

// Delete Category
app.delete('/api/categories/:id', (req, res) => {
    const { id } = req.params;
    const query = 'DELETE FROM categories WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Category not found' });
        res.json({ message: 'Category deleted' });
    });
});

// --- Products Routes ---

// Get Products (with Category Name)
app.get('/api/products', (req, res) => {
    const query = `
        SELECT p.*, c.name as categoryName 
        FROM products p 
        LEFT JOIN categories c ON p.categoryId = c.id
    `;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Create Product
app.post('/api/products', (req, res) => {
    const { name, price, imageUrl, categoryId, description, stock, isAvailable } = req.body;
    const query = `
        INSERT INTO products (name, price, imageUrl, categoryId, description, stock, isAvailable) 
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    db.query(query, [name, price, imageUrl, categoryId, description, stock || 0, isAvailable !== undefined ? isAvailable : true], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ id: result.insertId, message: 'Product created' });
    });
});

// Update Product
app.put('/api/products/:id', (req, res) => {
    const { id } = req.params;
    const { name, price, imageUrl, categoryId, description, stock, isAvailable } = req.body;
    const query = `
        UPDATE products 
        SET name=?, price=?, imageUrl=?, categoryId=?, description=?, stock=?, isAvailable=?
        WHERE id=?
    `;
    db.query(query, [name, price, imageUrl, categoryId, description, stock, isAvailable, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Product not found' });
        res.json({ message: 'Product updated' });
    });
});

// Delete Product
app.delete('/api/products/:id', (req, res) => {
    const { id } = req.params;
    const query = 'DELETE FROM products WHERE id = ?';
    db.query(query, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Product not found' });
        res.json({ message: 'Product deleted' });
    });
});

// --- Tables Routes ---

// Get Tables
app.get('/api/tables', (req, res) => {
    const query = 'SELECT * FROM restaurant_tables';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Update Table Status
app.put('/api/tables/:id', (req, res) => {
    const { id } = req.params; // Expecting app_id (table_1)
    const { status } = req.body;

    // We store tables with app_id in DB to match frontend IDs for now
    // Or we can query by app_id column
    const query = 'UPDATE restaurant_tables SET status = ? WHERE app_id = ?';
    db.query(query, [status, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Table not found' });
        res.json({ message: 'Table updated' });
    });
});

// --- Orders Routes ---

// Get Orders
app.get('/api/orders', (req, res) => {
    const { userId } = req.query;
    
    // Updated query to join tables
    let query = 'SELECT o.*, t.number as tableNumber, t.app_id as tableAppId FROM orders o LEFT JOIN restaurant_tables t ON o.tableId = t.id';
    const params = [];

    if (userId) {
        query += ' WHERE o.userId = ?';
        params.push(userId);
    }
    
    query += ' ORDER BY o.createdAt DESC';

    db.query(query, params, async (err, orders) => {
        if (err) return res.status(500).json({ error: err.message });

        // Fetch items for each order
        // Not optimal (N+1), but simple for now
        const enrichedOrders = await Promise.all(orders.map(async (order) => {
            return new Promise((resolve, reject) => {
                const itemQuery = 'SELECT * FROM order_items WHERE orderId = ?';
                db.query(itemQuery, [order.id], (err, items) => {
                    if (err) reject(err);
                    // Parse modifiers if they are strings
                    const parsedItems = items.map(item => {
                        let modifiers = item.modifiers;
                        if (typeof modifiers === 'string') {
                            try {
                                modifiers = JSON.parse(modifiers);
                            } catch (e) {
                                modifiers = [];
                            }
                        }
                        return {
                            ...item,
                            modifiers,
                            price: parseFloat(item.price),
                            quantity: parseInt(item.quantity)
                        };
                    });
                    
                    order.items = parsedItems;
                    order.totalPrice = parseFloat(order.totalPrice);
                    resolve(order);
                });
            });
        }));

        res.json(enrichedOrders);
    });
});

// Get Next Queue Number
app.get('/api/orders/queue', (req, res) => {
    const today = new Date().toISOString().split('T')[0];
    const query = 'SELECT MAX(queueNumber) as maxQueue FROM orders WHERE DATE(createdAt) = ?';
    db.query(query, [today], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        const maxQueue = results[0].maxQueue || 0;
        res.json({ nextQueueResponse: maxQueue + 1 });
    });
});

// Create Order
app.post('/api/orders', (req, res) => {
    const order = req.body;
    const {
        id, userId, userName, totalPrice, status,
        orderType, queueNumber, tableId, items, paymentMethod,
        subtotal, tax
    } = order;

    db.getConnection((err, connection) => {
        if (err) return res.status(500).json({ error: err.message });

        connection.beginTransaction(async (err) => {
            if (err) { connection.release(); return res.status(500).json({ error: err.message }); }

            try {
                // 1. Check and Decrement Stock
                if (items && items.length > 0) {
                    for (const item of items) {
                        const productId = item.productId || item.product.id;
                        const qty = item.quantity;

                        // Skip stock check for non-tracked items if needed, but for now we enforce it
                        // Use Promise wrap for query
                        await new Promise((resolve, reject) => {
                            const stockQuery = 'UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?';
                            connection.query(stockQuery, [qty, productId, qty], (err, result) => {
                                if (err) return reject(err);
                                if (result.affectedRows === 0) {
                                    return reject(new Error(`Insufficient stock for product ID ${productId}`));
                                }
                                resolve();
                            });
                        });
                    }
                }

                // 2. Resolve Table ID
                const findTableQuery = 'SELECT id FROM restaurant_tables WHERE app_id = ?';
                const tables = await new Promise((resolve, reject) => {
                    connection.query(findTableQuery, [tableId], (err, res) => {
                        if (err) reject(err); else resolve(res);
                    });
                });
                const realTableId = tables.length > 0 ? tables[0].id : null;

                // 3. Insert Order
                const insertOrderQuery = `
                    INSERT INTO orders (
                        app_id, userId, guestName, totalPrice, status, 
                        orderType, queueNumber, tableId, paymentStatus, paymentMethod,
                        subtotal, tax
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?)
                `;
                const realUserId = (userId === 'guest' || isNaN(userId)) ? null : userId;
                
                const finalSubtotal = subtotal || (totalPrice / 1.11);
                const finalTax = tax || (totalPrice - finalSubtotal);

                const orderValues = [
                    id, realUserId, userName, totalPrice, status || 'Sedang Diproses',
                    orderType, queueNumber, realTableId, paymentMethod || null,
                    finalSubtotal, finalTax
                ];

                const orderResult = await new Promise((resolve, reject) => {
                    connection.query(insertOrderQuery, orderValues, (err, res) => {
                        if (err) reject(err); else resolve(res);
                    });
                });

                const orderDbId = orderResult.insertId;

                // 4. Insert Items
                if (items && items.length > 0) {
                    const itemValues = items.map(item => [
                        orderDbId,
                        item.productId || item.product.id,
                        item.name || item.product.name,
                        item.price || item.product.price,
                        item.quantity,
                        item.note,
                        JSON.stringify(item.modifiers || [])
                    ]);

                    const insertItemsQuery = `
                        INSERT INTO order_items (orderId, productId, productName, price, quantity, note, modifiers)
                        VALUES ?
                    `;

                    await new Promise((resolve, reject) => {
                        connection.query(insertItemsQuery, [itemValues], (err, res) => {
                            if (err) reject(err); else resolve(res);
                        });
                    });
                }

                // 5. Commit
                connection.commit(err => {
                    if (err) {
                        connection.rollback(() => connection.release());
                        return res.status(500).json({ error: err.message });
                    }
                    connection.release();
                    res.status(201).json({ message: 'Order created', id: id });
                });

            } catch (error) {
                connection.rollback(() => connection.release());
                console.error("Transaction Error:", error);
                return res.status(400).json({ error: error.message });
            }
        });
    });
});

// Update Order Status
app.patch('/api/orders/:id/status', (req, res) => {
    const { id } = req.params; // app_id
    const { status } = req.body;

    const query = 'UPDATE orders SET status = ? WHERE app_id = ?';
    db.query(query, [status, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Order not found' });
        res.json({ message: 'Order updated' });
    });
});

// Payment
app.post('/api/orders/:id/payment', (req, res) => {
    const { id } = req.params; // app_id
    const { method, amount, reference } = req.body;

    // Update order: mark payment as paid and move to kitchen processing
    // Status flow: Menunggu Pembayaran -> (payment) -> Sedang Diproses -> (kitchen) -> Siap Saji -> (served) -> Selesai
    const query = 'UPDATE orders SET paymentStatus = "paid", status = "Sedang Diproses", paymentMethod = ?, paymentReference = ?, paidAt = NOW() WHERE app_id = ?';
    db.query(query, [method, reference || null, id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        if (result.affectedRows === 0) return res.status(404).json({ error: 'Order not found' });
        res.json({ message: 'Payment processed' });
    });
});

// Sales Stats (Dashboard)
app.get('/api/sales/stats', (req, res) => {
    // Total Orders
    const queryTotal = 'SELECT COUNT(*) as count FROM orders';
    // Revenue
    const queryRevenue = 'SELECT SUM(totalPrice) as total FROM orders WHERE paymentStatus = "paid"';
    // Active Orders
    const queryActive = "SELECT COUNT(*) as count FROM orders WHERE status NOT IN ('completed', 'cancelled', 'Selesai', 'Dibatalkan')"; // Match enum values and localized strings

    Promise.all([
        db.promise().query(queryTotal),
        db.promise().query(queryRevenue),
        db.promise().query(queryActive)
    ]).then(([[totalRows], [revRows], [activeRows]]) => {
        res.json({
            count: totalRows[0].count,
            revenue: parseFloat(revRows[0].total || 0),
            active_orders: activeRows[0].count
        });
    }).catch(err => {
        res.status(500).json({ error: err.message });
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
