const express = require('express')
const app = express()
const path = require('path')
const mysql = require('mysql2/promise')
const fs = require('fs')       // To read the keys and cert
const https = require('https')

const httpPort = process.env.JOKE_HTTP_PORT || 3000
const httpsPort = process.env.JOKE_HTTPS_PORT || 3443
const cert = process.env.CERT || "./localcerts/cert.pem"             // Use mkcert gen cert for testing on local machine
const privKey = process.env.PRIV_KEY || "./localcerts/privkey.pem"   // Don't use same folder name as that mapped in the cert bind mount
//console.log(process.env)

// Point to static pages
app.use(express.static(path.join(__dirname, '/public/html')))
app.use(express.static(path.join(__dirname, '/public/img')))
app.use(express.static(path.join(__dirname, '/public/css')))
app.use(express.static(path.join(__dirname, '/public/js')))

// The jokes are returned as json. Type is mandatory. Count query is optional, defaults to 1
app.get("/jokes/:type", async (req, res) => {
  const type = req.params.type
  let count = 1

  if (req.query.count) count = req.query.count * 1 // coerse the count string into a number
  let jokes = await getJokes(count, type)
  if (jokes.length == 0) {
    res.sendStatus(404)
  } else {
    res.json(jokes)
  }
})

// Return all the joke types from the database
app.get('/types', async (req, res) => {
  try {
    const types = await getTypes()
    res.json(types)
  } catch (err) {
    res.status(500).send(err.message)
  }
})


// If it get here without a match then resource not found
app.get('/*', (req, res) => {
  res.status(404).sendFile(path.join(__dirname, '/public/html/404.html'))
})


let httpsServer;

// Try to load certificates, and start HTTPS server only if they exist
// readfile functions are called as the object is created and results assigned to key and cert
if (fs.existsSync(cert) && fs.existsSync(privKey)) {
  const certOptions = {
    key: fs.readFileSync(privKey),
    cert: fs.readFileSync(cert),
  }

  httpsServer = https.createServer(certOptions, app)
  httpsServer.listen(httpsPort, () => {
    console.log(`HTTPS server listening on port ${httpsPort}`)
  })
} else {
  console.warn('SSL certificates not found. HTTPS server will not start.')
}


app.listen(httpPort, () => console.log(`HTTP server listening on port ${httpPort}`))


// ========================= Functions ==================================

// Get required number of jokes in a random order from the database
// Return jokes to the caller
async function getJokes(numJokes, type) {
  if (!numJokes && numJokes < 1) numJokes = 1

  sql = `
   SELECT tbl_jokes.id, tbl_jokes.setup, tbl_jokes.punchline, tbl_type.type 
   FROM tbl_jokes 
   inner join tbl_type 
   on tbl_jokes.type = tbl_type.id 
  `

  // If not of type "any", add a filter onto the query for a specific type
  const params = []  // Parameter array for parameterised query to avoid SQL injection

  if (type !== 'any') {
    sql += ` where tbl_type.type = ? ` // MySQL wants " round search string
    params.push(type)
  }
  sql += `ORDER BY RAND() LIMIT ${numJokes}`

  const jokes = await queryDatabase(sql, params)
  return jokes // Jokes is the result of the promise, selectedJokes
}

// Get all joke types
async function getTypes() {
  let sql = `select * from tbl_type`
  const types = await queryDatabase(sql)
  return types
}

// The pool creates connection objects but doesn't make a connection
// If you want to connect to make sure the database is there and to 
// make the user feel better, execute a query on the database
async function isConnected() {
  try {
    const [result] = await queryDatabase('SELECT DATABASE() AS CurrentDatabase')
    return result.CurrentDatabase // result is a 1 element array with an object so deconstruct
  } catch (err) {
    await pool.end() // Close all pool connections and wait until complete
    throw err
  }
}

// Initialise a connection string from the .env file. Remember to add .env to .gitignore
function createConPool() {
  const connectionObj = {
    host: process.env.MYSQL_HOST || 'localhost',
    user: process.env.MYSQL_USER || 'admin',
    password: PASSWORD = process.env.MYSQL_PASSWORD || 'admin',
    database: DATABASE = process.env.MYSQL_DATABASE || 'jokes',
    port: process.env.MYSQL_PORT || 3306,

    // Add database specific config performance settings 
    waitForConnections: true, // If all connections in use then queue & wait for one to be free rather than returning error
    connectionLimit: 10,      // Max concurrent connections
    queueLimit: 0             // Max queue length. Reject connections if more then this number. 0 means infinite queue
  }
  pool = mysql.createPool(connectionObj)
  // console.log(`Created connection pool to database: ${connectionObj.database} using`, connectionObj)
}

// General purpose database query function. Pass in the query and any optional params
// This is a private function and not exported
async function queryDatabase(query, params = []) {
  let connection
  try {
    connection = await pool.getConnection() // Get a connection from the pool. Wait for it to return
    const [rows] = await connection.execute(query, params) // Execute the query. Deconstruct array to just get the rows
    return rows
  } catch (err) {
    console.log(`Connection failed - will throw error ${err}`)
    throw err
  } finally {
    if (connection) connection.release() // Release the connection back to the pool regardless of success or failure
  }
}

// Need this to call the async functions to kick things off
async function initialise() {
  createConPool() // Create the connections pool
  console.log(`Connected to ${await isConnected()} database`)
}

initialise()