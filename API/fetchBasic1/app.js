const express = require('express')
const path = require('path')

const app = express()
const PORT = 3000

app.use(express.static(path.join(__dirname, 'public'), { index: 'async.html' }))

const books = [
  { "title": "Where Eagles Dare", "author": { "firstName": "Alistair", "lastName": "MacLean" }, "price": 12.99 },
  { "title": "The Silent Code", "author": { "firstName": "Jane", "lastName": "Holloway" }, "price": 9.50 },
  { "title": "Quantum Shadows", "author": { "firstName": "Elias", "lastName": "Trent" }, "price": 14.25 },
  { "title": "The Last Algorithm", "author": { "firstName": "Mira", "lastName": "Chen" }, "price": 11.75 },
  { "title": "Echoes of the Machine", "author": { "firstName": "Rafael", "lastName": "Cortez" }, "price": 13.40 },
  { "title": "Fragments of Tomorrow", "author": { "firstName": "Lena", "lastName": "Moritz" }, "price": 10.99 },
  { "title": "Binary Dreams", "author": { "firstName": "Omar", "lastName": "Vance" }, "price": 8.95 },
  { "title": "The Recursive Mind", "author": { "firstName": "Talia", "lastName": "Ng" }, "price": 15.20 },
  { "title": "Digital Dust", "author": { "firstName": "Harvey", "lastName": "Quinn" }, "price": 9.80 },
  { "title": "Code of Silence", "author": { "firstName": "Nina", "lastName": "Patel" }, "price": 13.75 },
  { "title": "Neural Drift", "author": { "firstName": "Zane", "lastName": "Hollow" }, "price": 12.30 },
  { "title": "The Compiler's Curse", "author": { "firstName": "Felicity", "lastName": "Rowe" }, "price": 10.45 },
  { "title": "Zero Day Elegy", "author": { "firstName": "Marcus", "lastName": "Lee" }, "price": 14.10 },
  { "title": "The Infinite Loop", "author": { "firstName": "Sophie", "lastName": "Tran" }, "price": 11.60 },
  { "title": "Encrypted Hearts", "author": { "firstName": "Devon", "lastName": "Clarke" }, "price": 12.85 }
]

app.get('/books', (req, res) => {
  if (req.query.max) {
    res.json(books.slice(0, req.query.max))
  } else {
    res.json(books)
  }
})

app.get('/books/:author', (req, res) => {
  if (req.params.author) {
    res.json(books.filter(index => index.author.lastName === req.params.author))
  }
})

app.get('/lengthyBlock/:ms', (req, res) => {
  sleepSync(req.params.ms)
  res.json({"msg": "Lengthy blocking process complete"})
})

app.get('/lengthyNoBlock/:ms', async (req, res) => {
  await sleep(req.params.ms)
  res.json({"msg": "Lengthy non-blocking process complete"})
})

function sleepSync(milliseconds) {
  const start = Date.now();
  while (Date.now() - start < milliseconds) {
    // Busy-wait loop: blocks the main thread
  }
}

async function sleepAsync() {
      await sleep(1000) // non-blocking delay
    }
  


 function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

app.listen(PORT, () => console.log(`Listening on port ${PORT}`))



