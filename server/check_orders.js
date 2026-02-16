const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile'
});

connection.connect(err => {
    if (err) {
        console.error('Error connecting:', err);
        return;
    }
    console.log('Connected to DB');

    connection.query('SELECT * FROM orders', (err, results) => {
        if (err) {
            console.error('Error querying orders:', err);
        } else {
            console.log('Orders found:', results.length);
            console.log(JSON.stringify(results, null, 2));
        }
        connection.end();
    });
});
