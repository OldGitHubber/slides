const express = require('express')
const app = express();
const PORT=3000

app.get('/', (req, res) => {
  console.log('Received a request at /')
  res.send('The server is really happy')
})

// Just reflect back what we received as a test
// e.g. localhost:3000/tst/Tony?format=json
app.get('/tst/:name', (req, res) => {
  const response = {
    msg: 'Endpoint received the following:',
    path: req.path,
    params: req.params,
    query: req.query
  }
  console.log(response)
  res.json(response)
})


app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`)
})

