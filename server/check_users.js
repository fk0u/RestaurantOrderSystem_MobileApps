const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile'
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting:', err);
        return;
    }
    console.log('Connected');

    db.query('SELECT * FROM users', (err, results) => {
        if (err) {
            console.error(err);
        } else {
            console.log('Users found:', results.length);
            console.log(JSON.stringify(results, null, 2));
        }
        db.end();
    });
});
