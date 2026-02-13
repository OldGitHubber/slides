const express = require('express')
const app = express()
const axios = require('axios')

// We can use env vars from a local .env. .env for compose would override these 
// Yin uses defaults no dotenv for demo. Use both if you want
require('dotenv').config({ path: './yang/.env' })

const YIN_PORT = process.env.YIN_PORT
const YANG_PORT = process.env.YANG_PORT
const YANG_HOST = process.env.YANG_HOST
const YIN_HOST = process.env.YIN_HOST

app.use(express.static(__dirname, { index: 'yang.html' })) // Set default html file to be different to index.html

app.get('/callYang', (req, res) => {
  // If Yang calls itself then handle that. Yin is identified by a custom header
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

app.listen(YANG_PORT, () => console.log(`Listening on port ${YANG_PORT}`))




