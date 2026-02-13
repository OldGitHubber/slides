const express = require('express')
const app = express()
const axios = require('axios')

// We do not need or want dotenv as compose will set the env vars for us in the container
// If we are not using compose, as there is no dotenv, the defaults will be used
// Yang uses a local .env to illustrate that is can be used - compose would override the env vars
const YIN_PORT = process.env.YIN_PORT   || 3000 
const YANG_PORT = process.env.YANG_PORT || 3001 
const YANG_HOST = process.env.YANG_HOST || 'localhost'
const YIN_HOST = process.env.YIN_HOST   || 'localhost'

app.use(express.static(__dirname, {index: 'yin.html'})) // Set default html file to be different to index.html

// If Yin calls itself then handle that. Yang is identified by a header
app.get('/callYin', (req, res) => {
  if (req.headers['caller'] === 'yang')
    res.send(`<h2>Hey Yang this is Yin. Thanks for calling me via Axios. I'll be your Yin. <br>Here is my address: ${req.headers.host} (${req.socket.localAddress}). <br>I know address is: ${req.socket.remoteAddress}</h2>`)
   else
    res.send(`<h2>Hey Yin, you want yourself? This is Yin and Yang. Have a word with yourself</h2>`)
})

app.get('/callYang', async (req, res) => {
  try {
    const response = await axios.get(`http://${YANG_HOST}:${YANG_PORT}/callYang`, {headers: { 'caller':'yin'}})
    res.send(`${response.data}`)
  } catch (err) {
    res.send(err)
  }
})

app.listen(YIN_PORT, () => console.log(`Listening on port ${YIN_PORT}`))




