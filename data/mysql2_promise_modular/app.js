// This file is now responsible only for routing and is fully decoupled
// from the database code 
const express = require('express')
const app = express()
const path = require('path')

// When vscode opens multiple projects for demos, code and .env not in root so specify
require('dotenv').config({path: path.resolve(__dirname, '.env')}) 

const db = require('./lib/tn-mysql2.js') // used db rather than {fn1, fn2 etc} - avoid scope issues

const PORT = process.env.PORT || 4000

db.createConnectionPool()
if (!db.isConnected()) process.exit(1)  // Kill the app id con fails

app.get('/names', async (req, res) => {
  try {
    const result =  await db.getNames() 
    res.json(result)                
  } catch (err) {                   
    res.status(500).send(err.message)       
  }
})

app.listen(PORT, () => console.log(`Listening on port ${PORT}`));
