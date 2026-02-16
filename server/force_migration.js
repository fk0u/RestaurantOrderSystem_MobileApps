const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile'
});

db.connect((err) => {
    if (err) {
        console.error('Connection failed:', err);
        process.exit(1);
    }
    console.log('Connected.');

    const columnsToAdd = [
        "ALTER TABLE orders ADD COLUMN paidAt TIMESTAMP NULL",
        "ALTER TABLE orders ADD COLUMN paymentMethod VARCHAR(50)",
        "ALTER TABLE orders ADD COLUMN paymentReference VARCHAR(255)",
        "ALTER TABLE orders ADD COLUMN subtotal DECIMAL(10, 2) DEFAULT 0.00",
        "ALTER TABLE orders ADD COLUMN tax DECIMAL(10, 2) DEFAULT 0.00"
    ];

    let processed = 0;

    columnsToAdd.forEach(query => {
        db.query(query, (err, res) => {
            if (err) {
                if (err.code === 'ER_DUP_FIELDNAME') {
                    console.log(`Column already exists (ignored): ${query}`);
                } else {
                    console.error(`Failed: ${query} -> ${err.message}`);
                }
            } else {
                console.log(`Success: ${query}`);
            }
            
            processed++;
            if (processed === columnsToAdd.length) {
                console.log('Done.');
                db.end();
            }
        });
    });
});
