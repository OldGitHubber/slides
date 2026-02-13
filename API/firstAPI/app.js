const express = require('express') 
const app = express() 
const APP_PORT = 3000

app.get('/', defaultFn)
app.get('/books', booksFn)
app.get('/time', timeFn)

app.listen(APP_PORT, serverUp)



// ------------ functions ---------------

function booksFn(req, res) {
    // more stuff 
    res.send('Book ordered. How easy was that?')
}

function defaultFn(req, res) {
  // ... more stuff
  res.send(`I'm in the root path`)
}

function timeFn(req, res) {
  let today = new Date()
  let time = `${today.getHours()}:${today.getMinutes()}:${today.getSeconds()}`
  res.send(time)
}

function serverUp(port) {
  console.log(`Listening on http://localhost:${APP_PORT}`)
}