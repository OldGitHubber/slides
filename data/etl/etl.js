const express = require('express')
const app = express()
require('dotenv').config() // Put .env in root or add path option parameter
const path = require('path') // No need to npm this anymore

const DB_TYPE = process.env.DB_TYPE || 'MONGO'
const MYSQL_MODULE = process.env.MYSQL_MODULE || './mysql-database-fns'
const MONGO_MODULE = process.env.MONGO_MODULE || './mongo-database-fns'
const db = (DB_TYPE === 'MYSQL') ? require(`${MYSQL_MODULE}`) : require(`${MONGO_MODULE}`) // import all mysql or mongo database functions as an object

// process.env is native to node - not the dotenv package. dotenv is used to read a .env file and write the values to the environment
const PORT = process.env.ETL_PORT || 3000
const STAGING_AREA = process.env.STAGING_AREA || './data'
const dataPath = path.resolve(__dirname, STAGING_AREA)

// Used to just check the app is alive
app.get('/', async (req, res) => {
 res.send('ETL Service is responding')
})


// This endpoint takes table and filename to ETL into. e.g. http://localhost:3000/etl/stuff/quiz.txt
// quiz.txt needs to be in the ./data dir
app.get('/etl/:table/:filename', async (req, res) => {
 try {
  await db.dropTable(req.params.table)   // Start from scratch for the demo
  await db.createTable(req.params.table)
  await db.etl(req.params.table, dataPath + '/' + req.params.filename)
  const result = await db.countRows(req.params.table)
  console.log(`Added ${result} rows.`)
  res.send(`Added ${result} rows.`)
 } catch (err) {
  console.log('Failed with error:', err)
  res.send(`Failed: ${err.message}`)
 }
})

// Return all data from the table. 
app.get('/data/:table', async (req, res) => {
 try {
  response = await db.getData(req.params.table)
  res.send(response)
 } catch (err) {
  res.status(500).send(err) // Server error
 }
})

app.listen(PORT, () => console.log(`ETL application listening on port ${PORT}`))


// **************** Functions not imported ********************
// Check if connected to database and output to console to confirm connection
async function checkDbConnected() {
 try {
  const dbName = await db.isConnected()
  console.log(`Connected to ${DB_TYPE} ${dbName} database`)
 } catch (err) {
  console.log(`Failed to connected to database. Error: ${err.message}. Application will terminate.`)
  process.exit(1)  // Kill the app as connection failed
 }
}


checkDbConnected() // Execute when all callbacks setup