const express = require('express')
const app = express()
const https = require('https')
const fs = require('fs')
const multer = require('multer')  // This is used for multipart post i.e. from a form. Can send files
const cors = require('cors')
app.use(cors())                   // To call from swagger website which is cross origin

const PORT = 3000

app.use(express.urlencoded({ extended: false }))  // This is for put, post using url encoded so with multer covers both
const upload = multer()  // For post using multipart encoding to accomodate a file is uploaded
app.use(express.json())  // In case the data is in json format

let peopleList = { academics: ['Tony Nicol', 'John King'], students: ['Jim Smith', 'Jane Doe', 'Billy Wibble'], support: ['Joe Soap', 'Sue Smith'] }

const options = {
  key: fs.readFileSync('./cert/localhost-key.pem'),
  cert: fs.readFileSync('./cert/localhost.pem')
}

app.get('/', (req, res) => {
  res.send(`App is alive`)
})

app.get('/error', (req, res) => {
  res.sendStatus(404)
})


app.get('/people/:role', (req, res) => {
  switch (req.params.role) {
    case 'academics': res.send(peopleList.academics); break
    case 'students': res.send(peopleList.students); break
    case 'support': res.send(peopleList.support); break
    default: res.sendStatus(404)
  }
})

// An example returning an object
app.get('/people', (req, res) => {
  res.send(peopleList)
})

// GET is nice and easy. POST has a bit more to it: 
// need express.urlencoded for url encoded data and 
// express.json to recognise and decode json
// Use x-www-form-urlencoded in postman
// No file so wouldn't normally use this multipart encoding but added for completeness
// Need upload none for multer to indicate we don't intend to upload a file in this route
app.post('/person', upload.none(), (req, res) => {

  let firstName = req.body.f_name
  let lastName = req.body.l_name
  let age = req.body.age
  let ageStr = ''

  if (age >= 65) ageStr = 'ancient!'
  else
    ageStr = 'up and coming'

  res.send(`${firstName} ${lastName} is ${ageStr}`)

})

app.delete('/person', (req, res) => {
  res.send(`User ${req.body.userId}, Tony Nicol has been permanently deleted`)
})

app.put('/person', (req, res) => {
  let oldName = req.body.curName
  let newName = req.body.newName
  let userId = req.body.userId
  res.send(`User ${userId}, ${oldName} has been updated to ${newName} and all other record attributes deleted`)
})

app.patch('/person', (req, res) => {
  let oldName = req.body.curName
  let newName = req.body.newName
  let userId = req.body.userId
  res.send(`User ${req.body.userId}, ${oldName} has been updated to ${newName} and all other record attributes unchanged`)
})

// Start the https server
https.createServer(options, app).listen(PORT, () => console.log(`Listening for https on port ${PORT}`))