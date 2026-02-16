const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile'
});

db.connect(err => {
    if (err) throw err;
    console.log('Connected to database');

    const query = "ALTER TABLE orders ADD COLUMN paymentReference VARCHAR(255) AFTER paymentMethod";

    db.query(query, (err, result) => {
        if (err) {
            if (err.code === 'ER_DUP_FIELDNAME') {
                console.log('Column paymentReference already exists');
            } else {
                console.error('Error adding column:', err.message);
            }
        } else {
            console.log('Column paymentReference added successfully');
        }
        process.exit();
    });
});
