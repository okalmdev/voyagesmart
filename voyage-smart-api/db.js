// db.js
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'voyage_smart_db',
  password: 'okalm',
  port: 5432
});

module.exports = pool;
