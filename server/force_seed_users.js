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
    console.log('Connected to DB');

    const user = {
        name: 'Admin User',
        email: 'admin@resto.com',
        password: 'admin123',
        role: 'admin',
        token: 'admin-token-123'
    };

    const query = 'INSERT INTO users (name, email, password, role, token) VALUES (?, ?, ?, ?, ?)';

    db.query(query, [user.name, user.email, user.password, user.role, user.token], (err, result) => {
        if (err) {
            console.error('INSERT FAILED:', err);
        } else {
            console.log('INSERT SUCCESS:', result);
        }

        db.query('SELECT * FROM users', (err, rows) => {
            console.log('Current Users:', rows);
            db.end();
        });
    });
});
