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
        console.error('Error connecting to database:', err);
        process.exit(1);
    }
    console.log('Connected to database.');

    const alterQueries = [
        "ALTER TABLE orders ADD COLUMN IF NOT EXISTS paidAt TIMESTAMP NULL;",
        "ALTER TABLE orders ADD COLUMN IF NOT EXISTS paymentMethod VARCHAR(50);",
        "ALTER TABLE orders ADD COLUMN IF NOT EXISTS paymentReference VARCHAR(255);",
        "ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal DECIMAL(10, 2) DEFAULT 0.00;",
        "ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax DECIMAL(10, 2) DEFAULT 0.00;",
        "ALTER TABLE orders MODIFY COLUMN paymentReference VARCHAR(255);" 
    ];

    let completed = 0;

    alterQueries.forEach(query => {
        db.query(query, (err, result) => {
            if (err) {
                // Ignore "Duplicate column" checks if IF NOT EXISTS fails on some versions or other benign errors
                console.warn(`Query failed (might be harmless if column exists): ${query} - ${err.message}`);
            } else {
                console.log(`Executed: ${query}`);
            }
            completed++;
            if (completed === alterQueries.length) {
                console.log('Migration completed.');
                db.end();
            }
        });
    });
});
