const express = require('express')
const app = express()
const axios = require('axios')
const path = require('path')
const YANG_PORT = process.env.YANG_PORT || 3001
const YIN_PORT = process.env.YIN_PORT   || 3000
const YIN_HOST = process.env.YIN_HOST   || 'localhost'  // Use when in debugger. Need to change yin or yang port too
const YANG_HOST = process.env.YANG_HOST || 'localhost'

app.use(express.static(path.join(__dirname, 'public'), { index: 'yin.html'}))


// If Yin calls itself then handle that. Yang is identified by a header
app.get('/callYin', (req, res) => {
  if (req.headers['caller'] === 'yang')
    res.send(`<h2>Hey Yang this is Yin. Thanks for calling me via Axios. I'll be your Yin. <br>Here is my address: ${req.headers.host} (${req.socket.localAddress}). <br>I know your IP address is: ${req.socket.remoteAddress}</h2>`)
   else
    res.send(`<h2>Hey Yin, you want yourself? This is Yin and Yang. Have a word with yourself</h2>`)
})

app.get('/callYang', async (req, res) => {
  try {
    const response = await axios.get(`http://${YANG_HOST}:${YANG_PORT}/callYang`, {headers: { 'caller':'yin'}})
    console.log(`Called: http://${YANG_HOST}:${YANG_PORT}/callYang from Yin in callYang`)
    res.send(`${response.data}`)
  } catch (err) {
    res.send(err)
  }
})

// If you want to listen on any source IP, not just local host then use '0,0,0,0'
// This is needed if in vscode and trying to reach your app in debug mode from kong
app.listen(YIN_PORT, '0.0.0.0', () => console.log(`Listening on port ${YIN_PORT}`))




