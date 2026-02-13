const express = require('express')
const app = express()

app.get('/', rootResponse)

app.listen(3000, serverStatus)



// ------------- Functions -----------------
function rootResponse (req, res) {
  res.send('API working. How easy is that!')
}

function serverStatus () {
  console.log('Server running at http://localhost:3000/')
}
