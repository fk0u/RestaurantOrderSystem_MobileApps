const mysql = require('mysql2/promise');

async function check() {
    try {
        const conn = await mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: '',
            database: 'RestoMobile'
        });
        const [rows] = await conn.execute('SHOW CREATE TABLE users');
        console.log(rows);
        await conn.end();
    } catch (e) {
        console.error(e);
    }
}

check();
