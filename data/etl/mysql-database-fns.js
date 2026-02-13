const mysql = require('mysql2/promise') // Needs newer mysql package for the version of container used
const extractData = require('./extractData')

let pool  // File scope obj holding the connection pool


// Doesn't actually connect but does initialise some connection objects ready for use
// Much easier to create a database outside - e.g. cli or workbench. Can do it here, connect to mysql without a database
// defined. Issue a create query. Disconnect and create new connection to the new database
function createConPool() {
 const connectionObj = {
  host: process.env.HOST_NAME || 'localhost',
  user: process.env.USER_NAME || 'admin',
  password: PASSWORD = process.env.PASSWORD || 'admin',
  database: DATABASE = process.env.DATABASE || 'triv',
  port: process.env.MYSQL_PORT || 3306,

  // Add database specific config performance settings 
  waitForConnections: true, // If all connections in use then queue & wait for one to be free rather than returning error
  connectionLimit: 10,      // Max concurrent connections
  queueLimit: 0             // Max queue length. Reject connections if nore then this number. 0 means infinite queue
 }

 pool = mysql.createPool(connectionObj)
}

// The pool creates connection objects but doesn't make a connection
// If you want to connect to make sure the database is there and to 
// make the user feel better, execute a query on the database
async function isConnected() {
 try {
  // const result = await queryDatabase('SELECT 1') // result is true if DB is up
  const [result] = await queryDatabase('SELECT DATABASE() AS CurrentDatabase')
  return result.CurrentDatabase
 } catch (err) {
  await pool.end() // Close all pool connections and wait until complete
  throw err
 }
}


// General purpose database query function. Pass in the query and any optional params
async function queryDatabase(query, params = []) {
 let connection
 try {
  connection = await pool.getConnection() // Get a connection from the pool. Wait for it to return
  const [rows] = await connection.execute(query, params) // Execute the query. Deconstruct array to just get the rows
  return rows
 } catch (err) {
  throw err
 } finally {
  if (connection) connection.release() // Release the connection back to the pool regardless of success or failure
 }
}

// Get all data from the table and return to caller. To test the exception stack
// change * to *q to make it fail then trace the exception back to the source
async function getData(table) {
 let sql = `SELECT * FROM ${table}`
 try {
  return await queryDatabase(sql)
 } catch (err) {
  throw err
 }
}

// Return number of rows in table
async function countRows(tableName) {
 const sql = `SELECT COUNT(*) FROM ${tableName};`
 const [result] = await queryDatabase(sql)
 return result['COUNT(*)'] // One of the few cases where can't use result. as the attribute is a string
}


async function createTable(tableName) {
 // Recreate during testing. 
 const sql = 'CREATE TABLE ' + tableName + '(    \
  `id` INT NOT NULL AUTO_INCREMENT,              \
  `question` TEXT NOT NULL,                      \
  `answer` TEXT NOT NULL,                        \
  PRIMARY KEY (`id`),                            \
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE);'

 return await queryDatabase(sql)
}


// Note: this function looks for tabs between Q and A and CR for end of question
// so last question in the data file must end with a CR 
async function etl(tableName, filename) {

 const [qArr, ansArr] = await extractData(filename) // Extract and transform data from text file

 // Load extracted and transformed data into table
 let sql = `insert into ${tableName} (question, answer) values`
 let i = 0
 while (i < qArr.length - 1) {               // Treat last one differently
  sql += `('${qArr[i]}','${ansArr[i]}'),`
  i++
 }
 sql += `('${qArr[i]}','${ansArr[i]}');` // Don't want a comma on this one

 const result = await queryDatabase(sql)
 return result
}

// Delete the named table
async function dropTable(tableName) {
 const sql = `DROP TABLE IF EXISTS ${tableName}`
 await queryDatabase(sql)
}

createConPool() // Create the connections pool once everything else has been initialised

// Export functions that avoid the user needing to know the type of database
module.exports = {
 isConnected,
 getData,
 countRows,
 createTable,
 etl,
 dropTable
}