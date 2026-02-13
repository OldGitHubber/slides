const express = require('express')
const app = express()
const mysql = require('mysql2/promise') // Load the promise lib

const PORT = 3000

let connection
let connectionStr = {
  host: 'localhost',
  user: 'admin',            // Remember to create a user for your database
  password: 'admin',
  database: 'basic',
  multipleStatements: true  // Enable for multiple queries in one call
}

// Connect the app to the database and authenticate
async function connectToDatabase() {
  try {
    connection = await mysql.createConnection(connectionStr)
    const dbName=connection.config.database
    console.log(`Connected to MySQL server "${dbName}" database`) // Assure the user of the connection
  } catch (error) {
    console.error('Connection error:', error);
  }
}

// Using localhost:3000/name/martin works fine and as expected
// localhost:3000/name/`'; show tables; -- `
// This evaluates SELECT * FROM names WHERE last_name = '${req.params.name}'
// to: SELECT * FROM names WHERE last_name = ''; show tables; --'
// With the table names we can query them, alter them, drop them
// 
// Using localhost:3000/name/`'; SELECT * FROM names; -- ` returns all names - we can do what we want
// The query evaluates to "SELECT * FROM names WHERE last_name = '`'; SELECT * FROM names; -- `'"
// which is two statements: SELECT * FROM names WHERE last_name = ''; SELECT * FROM names; -- `'
// A database needs to be able to evaluate multiple sql statements for this to work. By default mysql2 doesn't
// If only one statement is allowed, 
// localhost:3000/name/`' OR 1=1;  -- ` will dump the whole table of personal details and ID may be NI number
// because it evaluates to "SELECT * FROM names WHERE last_name = '`' OR 1=1;  -- `'
// so returns every row where last_name='' OR if the row satisfies the OR which is true for every row
// The -- is a comment to comment out the final ' in the string or the statement would be malformed

// We could alter the table or even drop it
// localhost:3000/name/`'; INSERT INTO names (first_name, last_name, age) VALUES ('tony', 'nicol', 25);  -- `
app.get('/name/:name', async (req, res) => {
  const sql = `SELECT * FROM names WHERE last_name = '${req.params.name}'`

  try {
    const [result] = await connection.query(sql)
    res.json(result)            // Resolved successfully so send the promise success value
  } catch (err) {                 // Resolved to a failure
    res.status(500).send(err)  // Send the promise failed value. Wouldn't normally pass this much info to a user. Ok for testing
  }
})




// Use ? as a placeholder so the data passed in is not added to the SQL string directly
// If you have more data items, just add more ?
// The query function has the basic SQL as arg1, but arg2 is an array of the data passed in 
// which will replace the ? in the order they are in the array. A bit like printf in C
// 
app.get('/nameSafe/:name', async (req, res) => {
  const sql = 'SELECT * FROM names WHERE last_name = ?'; // Use ? as a placeholder
  try {
    const [result] = await connection.query(sql, [req.params.name]); // Pass values separately
    res.json(result);
  } catch (err) {
    res.status(500).send(err);
  }
});


// You may need to pass multiple data items
// SELECT * FROM basic.names WHERE first_name='jane' AND last_name='doe' AND age = 80;
app.get('/nameSafe/:fName/:lName/:age', async (req, res) => {
  const params = [req.params.fName, req.params.lName, req.params.age]
  const sql = "SELECT * FROM names WHERE first_name=? AND last_name=? AND age =?"
  try {
    const [result] = await connection.query(sql, params); // Pass values separately
    if (result.length == 0)
      res.sendStatus(404)
    else
      res.json(result)
  } catch (err) {
    res.status(500).send(err);
  }
})


app.listen(PORT, () => console.log(`App server listening on port ${PORT}`));

connectToDatabase() // Create the connection. Connection closes when app finishes

