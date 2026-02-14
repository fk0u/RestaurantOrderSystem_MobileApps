const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function setupDatabase() {
    const config = {
        host: 'localhost',
        user: 'root',
        password: '', // Default XAMPP password
        multipleStatements: true // Allow multiple queries in one call
    };

    try {
        // 1. Connect without DB selected to create it if needed
        let connection = await mysql.createConnection(config);
        console.log('Connected to MySQL server.');

        // 2. Read schema file
        const schemaPath = path.join(__dirname, 'schema.sql');
        const sql = fs.readFileSync(schemaPath, 'utf8');

        // 3. Execute schema
        console.log('Executing schema.sql...');
        await connection.query(sql);
        console.log('Database setup complete!');

        await connection.end();
    } catch (err) {
        console.error('Error setting up database:', err);
        process.exit(1);
    }
}

setupDatabase();
