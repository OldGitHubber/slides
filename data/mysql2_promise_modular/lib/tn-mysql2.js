const mysql = require('mysql2/promise') // Load the promise lib
let pool // pool has file scope

function createConnectionPool() {
  const connectionObj = {
    host: process.env.HOST_NAME,        
    user: process.env.USER_NAME,             
    password: process.env.PASSWORD,     
    database: process.env.DATABASE,      
  }

  // Add database specific config info
  connectionObj.waitForConnections = true
  connectionObj.connectionLimit = 10
  connectionObj.queueLimit = 0
  pool = mysql.createPool(connectionObj)
}

async function queryDatabase(query, params = []) {
  let connection;
  try {
    connection = await pool.getConnection() // Get a connection from the pool. Wait for it to return
    const [rows] = await connection.execute(query, params) // Execute the query. Deconstruct array to just get the rows
    return rows
  } catch (err) {
    throw err;
  } finally {
    if (connection) connection.release() // Release the connection back to the pool regardless of success or failure
  }
}

// Do a simple query to see if there is a response
async function isConnected() {
  try {
    const result = await queryDatabase('SELECT 1')
    console.log(`Database connection successful`)
    return true

  } catch (err) {
    console.error('Database connection FAILED:', err.message)
    await pool.end() // Close all pool connections and wait until complete
    return false
  }
}

async function getNames() {
  try {
    const results = await queryDatabase('SELECT * FROM names');
    return results

  } catch (err) {
    console.error('Error in running queries:', err.message)
    throw err
  }
}

module.exports = {
  createConnectionPool,
  isConnected,
  getNames
}