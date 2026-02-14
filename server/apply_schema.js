const mysql = require('mysql2');
const fs = require('fs');
const path = require('path');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'RestoMobile',
    multipleStatements: true
});

db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        return;
    }
    console.log('Connected to MySQL Database');
    applySchema();
});

const applySchema = () => {
    const schemaPath = path.join(__dirname, 'schema.sql');
    fs.readFile(schemaPath, 'utf8', (err, schemaQuery) => {
        if (err) {
            console.error('Error reading schema.sql:', err);
            db.end();
            return;
        }

        db.query(schemaQuery, (err, results) => {
            if (err) {
                console.error('Error applying schema:', err);
            } else {
                console.log('Schema applied successfully!');
            }
            db.end();
        });
    });
};
