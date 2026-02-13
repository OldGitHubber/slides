const express = require('express')
const app = express()
const mysql = require('mysql2/promise') // Load the promise lib

const PORT = 3000

let connection
let connectionStr = {
  host: 'localhost',
  user: 'admin',       // Remember to create a user for your database
  password: 'admin',
  database: 'basic'
}

async function connectToDatabase() {
  try {
    connection = await mysql.createConnection(connectionStr)
    const dbName=connection.config.database
    console.log(`Connected to MySQL server "${dbName}" database`) // Assure the user of the connection
  } catch (error) {
    console.error('Connection error:', error);
  }
}


// The make the callback an async function so we can use await
app.get('/names', async (req, res) => {
  try {
    const [result] = await connection.execute(`select * from names`) // connection.execute returns a promise
    res.json(result)                // Resolved successfully so send the promise success value
  } catch (err) {                   // Resolved to a failure
    res.status(500).send(err)       // Send the promise failed value. Wouldn't normally pass this much info to a user. Ok for testing
  }
})


app.listen(PORT, () => console.log(`App server listening on port ${PORT}`));

connectToDatabase() // Create the connection. Connection closes when app finishes

