// This solution tightly couples the app and the database. Don't do it like this
// Do it as you have been shown which adheres to the principle of separation of concerns
// You should already have a better solution to this by now based on the lab exercises#

const express = require('express')
const app = express()
const mysql = require('mysql2')
const path = require('path')

// Note: I don't use dotenv here. I use defaults and .env in the compose file for the containers
// Initialise a connection string from defaults if local, or compose.yaml if using containers
let conStr = {}
conStr.host = process.env.MYSQL_SERVICE || 'localhost'
conStr.user = process.env.MYSQL_USER || 'admin'
conStr.password = process.env.MYSQL_PASSWORD || 'admin'
conStr.database = process.env.MYSQL_DATABASE || 'jokes'
const PORT = process.env.JOKES_PORT || 3000
const db = mysql.createConnection(conStr)

db.connect((err) => {
  if (err) throw err
  console.log(`Connected to ${conStr.database} database ...`)
})

// Point to static pages
app.use(express.static(path.join(__dirname, '/public/html')))   // Client requests files relative to here - i.e. no path needed
app.use(express.static(path.join(__dirname, '/public/img')))    // e.g. in index.html, <img src="http://localhost:3000/xx.jpg"> 
app.use(express.static(path.join(__dirname, '/public/css')))
app.use(express.static(path.join(__dirname, '/public/js')))


// ========================= Routes ==================================
// e.g. /jokes/any?count=3
app.get("/jokes/:type", async (req, res) => {
  if (!req.params.type)
    return res.sendStatus(400)  // We need at least the type. 400 is bad request

  let type = req.params.type
  let count = 1
  if (req.query.count) count = Number(req.query.count) 

  let jokes = await getJokes(count, type)
  if (jokes.length > 0) {
    res.setHeader('Content-Type', 'application/JSON')
    res.json(jokes)
  }
  else
    res.sendStatus(404) // 404 not found
})

app.get('/types', (req, res) => {
  let sql = `select * from tbl_type`
  db.query(sql, (err, results) => {
    if (err) {
      res.sendStatus(500) // 500 server error
    }
    res.json(results)
  })
})

// Just for demo to show simulate an app crash for testing restart policies
app.get('/kill', (req, res) => {
  console.log('Kill command received. Killing app')
  process.abort() // Kill ungracefully as if the app has crashed. Use process.exit(n)to gracefully exit
})


// If it get here without a match then resource not found
// The middleware with no path acts as a catch all for any method
app.use((req, res, next) => {
  res.status(404).json({ error: 'Endpoint not found' })
})


app.listen(PORT, () => console.log(`Listening on port ${PORT}`))


// ========================= Functions ==================================

// Use the mysql 2 promise. You don't need your own like this
let getJokes = async function (numJokes, type) {
  let jokes = []
  let selectedJokes = []
  let sql = ''

  if (!numJokes || numJokes < 1) numJokes = 1

  sql = `
   SELECT tbl_jokes.id, tbl_jokes.setup, tbl_jokes.punchline, tbl_type.type 
   FROM tbl_jokes 
   inner join tbl_type 
   on tbl_jokes.type = tbl_type.id 
  `

  // If not any, add a filter onto the query
  if (type !== 'any')
    sql += ` where tbl_type.type = "${type}"`  // MySQL wants " round search string

  sql += ` ORDER BY RAND() LIMIT ${numJokes}`

  jokes = await new Promise((resolve, reject) => {
    db.query(sql, (err, results) => {
      if (err) {
        reject(err)
        return []
      }
      resolve(results)
    })
  })

  return jokes  // Jokes is the result of the promise, selectedJokes
}

