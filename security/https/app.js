
// With mkcert installed, go to the dir you want cert in and use
// mkcert -key-file key.pem -cert-file cert.pem 20.117.114.49, ssl.uksouth.cloudapp.azure.com or whatever IP and or domain is
// add localhost and remote domain to use both
// mkcert -key-file key.pem -cert-file cert.pem localhost  for localhost testing
const express = require('express')
const app = express()
const fs = require('fs')       // To read the keys and cert
const https = require('https') // To create https server
app.use(express.static(__dirname + "/public"))

const PORT = 80
const HTTPS_PORT = 443

let httpsServer

try {
  const privateKey = fs.readFileSync(__dirname + '/cert/key.pem', 'utf8')   // Get private key created by mkcert
  const certificate = fs.readFileSync(__dirname + '/cert/cert.pem', 'utf8') // Get cert created by mkcert
  const credentials = { key: privateKey, cert: certificate }                // Create an object to hold cert and key
  httpsServer = https.createServer(credentials, app)                        // Create the https server using the creds
} catch (err) {
  console.log(`Error returned: ${err.message}`)
}

app.get('/status', (req, res) => {
  res.send('Node server is running.')
})


// Middleware to handle HTTP requests
app.use((req, res, next) => {
  if (req.protocol === 'http') {
    res.sendFile(__dirname + '/public/http.html')
  } else {
    next() // Continue to the next middleware
  }
})

// Middleware to handle HTTPS requests
app.use((req, res, next) => {
  if (req.protocol === 'https') {
   res.sendFile(__dirname + '/public/https.html')
  } else {
    next() // Continue to the next middleware
  }
})

app.listen(PORT, () => {
  console.log(`http server listening on port:${PORT}`)
})

httpsServer.listen(HTTPS_PORT, () => {
  console.log(`https server listening on port:${HTTPS_PORT}`);
})


