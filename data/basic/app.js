const express = require('express')
const app = express()
const mysql = require('mysql2')    // V2 as using the new authentication in MySql
const PORT = 3000

let conStr = {
  host: 'localhost',
  user: 'admin',
  password: 'admin',
  database: 'basic',
}

const db = mysql.createConnection(conStr)

// On completion of connect, if it failed, the callback is called with an error object so
// we can manage it - e.g. report it in console.log. If successful, err value is null 
// and db holds and file scope connection to the database
// Note if this fails then so will any api call so we should really close the server
// process.exit(1) will do that - fairly ungracefully
db.connect((err) => {
  if (err) {
    console.log(`Failed to connect to MySQL database: ${conStr.database}`)
    process.exit(1)
  } else
    console.log(`Connected to MySQL database: ${conStr.database}`)
})

// Issuing default path uses the file scope variable db connection to the database
// to execute a basic query.
app.get('/', (req, res) => {
  const sql = `select *  from names`
  db.query(sql, (err, results) => {
    if (err) {
      console.log(`Database error: ${err.message}`)
    } else {
      res.json(results)
    }
  })
})


app.listen(PORT, () => console.log(`Listening on port ${PORT}`));
