const express = require('express')
const app = express()
const APP_PORT = 3000


app.get('/', (req, res) => {
  // more stuff); 
  res.send('Tell me what to get!')
})

app.get('/books', (req, res) => {
  // more stuff); 
  res.send('Book ordered. How easy was that?')
})

app.get('/time', (req, res) => {
  let today = new Date()
  let time = `${today.getHours()}:${today.getMinutes()}:${today.getSeconds()}`
  res.send(time)
})

app.listen(APP_PORT, () => console.log(`Listening on port ${APP_PORT}`))