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

    const users = [
        {
            name: 'Admin User',
            email: 'admin@resto.com',
            password: 'admin123',
            role: 'admin',
            token: 'admin-token-123'
        },
        {
            name: 'Cashier Staff',
            email: 'cashier@resto.com',
            password: 'cashier123',
            role: 'cashier',
            token: 'cashier-token-123'
        },
        {
            name: 'Kitchen Staff',
            email: 'kitchen@resto.com',
            password: 'kitchen123',
            role: 'kitchen',
            token: 'kitchen-token-123'
        }
    ];

    const query = `
        INSERT INTO users (name, email, password, role, token) VALUES ?
        ON DUPLICATE KEY UPDATE 
        name = VALUES(name), 
        password = VALUES(password), 
        role = VALUES(role), 
        token = VALUES(token)
    `;
    const values = users.map(u => [u.name, u.email, u.password, u.role, u.token]);

    db.query(query, [values], (err, result) => {
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
