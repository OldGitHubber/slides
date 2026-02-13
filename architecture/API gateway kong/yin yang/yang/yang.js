const express = require('express')
const app = express()
const axios = require('axios')
const path = require('path')

// We can use env vars from a local .env. .env for compose would override these 
// Yin uses defaults no dotenv for demo. Use both if you want
require('dotenv').config({ path: './.env' }) // .env is in the same dir as the app. __dirname is the container app dir
console.log(`Project path for dotenv is ${__dirname}`)

const YANG_PORT = process.env.YANG_PORT
const YIN_PORT = process.env.YIN_PORT
const YIN_HOST = process.env.YIN_HOST
const YANG_HOST = process.env.YANG_HOST

app.use(express.static(path.join(__dirname, 'public'),{ index: 'yang.html'})) 

app.get('/callYang', (req, res) => {
  // If Yang calls itself then handle that. Yin is identified by a custom header
  console.log(`In Yang /callYang. Caller header is: ${req.headers['caller']}`)
  if (req.headers['caller'] === 'yin')
    res.send(`<h2>Hey Yin this is Yang. Thanks for calling me via Axios. I'll be your Yang. <br>Here is my address: ${req.headers.host} (${req.socket.localAddress}). <br>I know your IP address is: ${req.socket.remoteAddress}</h2>`)
  else
    res.send(`<h2>Hey Yang, you want yourself? This is Yin and Yang. Have a word with yourself</h2>`)
})

app.get('/callYin', async (req, res) => {
  try {
    const response = await axios.get(`http://${YIN_HOST}:${YIN_PORT}/callYin`, { headers: { 'caller': 'yang' } })
    res.send(response.data)
  } catch (err) {
    res.send(err)
  }
})

app.listen(YANG_PORT, '0.0.0.0', () => console.log(`Listening on port ${YANG_PORT}`))




