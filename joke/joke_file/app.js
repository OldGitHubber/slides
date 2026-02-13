const express = require('express')
const app = express()
const jokesList = require('./jokes.json') // Create an array of joke objects from file
const path = require('path')

app.use(express.static(path.join(__dirname, './public'), {index: 'jokes.html'}))  // Create static web server
const PORT = 3000


// Single endpoint to find and return requested jokes
app.get("/jokes/:type", (req, res) => {

  let type = req.params.type
  let count = 1

  if (req.query.count) count = req.query.count
  const jokes = getJokes(jokesList, count, type)

  if (jokes.length == 0) {
    res.sendStatus(404)
  } else {
    res.json(jokes) 
  }
})

// If we get here, the user has entered something wrong
app.get("/*", (req, res) => {
  res.sendStatus(400) // Bad request
})


app.listen(PORT, () => {
  console.log(`Listening on port ${PORT}`)
})



// *************** Functions **************


// Basic random number generator to pull jokes out of the table randomly
const getRand = function (max) {
 return Math.floor(Math.random() * max)
}

// Get the number of requested jokes of the requested type from the array and return a new array
function getJokes(allJokes, numJokes, type) {
 let jokes = []
 let selectedJokes = []

 if (type === 'any') jokes = allJokes
 else
   //  jokes = allJokes.filter(element => element.type === type) // Get all jokes of one type

   for (let i = 0, j = 0; i < allJokes.length; i++) { // Use filter as above or do it manually this way
     if (allJokes[i].type === type) {
       jokes[j++] = allJokes[i]
     }
   }

 if (jokes.length == 0) {
   return jokes // There are none so return empty array
 }

 if (numJokes < 1) numJokes = 1 // Some numpty has added count = -10 or similar

 for (let i = 0; i < numJokes; i++) {
   selectedJokes[i] = jokes[getRand(jokes.length)]
 }
 return selectedJokes
}



