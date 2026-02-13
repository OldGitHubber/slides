const express = require('express')
const app = express()
//require('dotenv').config() // DOn't need this as .env is included in the compose file so env vars set there
const jokesList = require('./jokes.json')
const path = require('path')
const publicFilePath = path.join(__dirname, 'public')  // Get the path to the front-end files
app.use(express.static(publicFilePath))                // Create static web page access using middleware
const { updateHostAddress } = require('./tnLib')       // Use to update the client js with .env ip:port

const APP_PORT = process.env.TN_JOKE_APP_PORT || 3000
const CONT_PORT = process.env.TN_JOKE_CONT_PORT  
const IP = process.env.TN_JOKE_IP || 'localhost' // If using terraform, i've added IP to TN_JOKE_IP on VM creation

let host // Form the host and path depending on environment and send to updateHostAddress so front-end points to right place

// Determine which environment we are in: vscode, local container or remote serverm
if (!!process.env.VSCODE_INSPECTOR_OPTIONS) { // If env var set must be in vscode. Use !! to convert to bool (falsy is empty string) then reinvert
  host = `${IP}:${APP_PORT}` // IP should be the default as there will be no real IP as terraform sets that
} else {                     // Must be container so use its port set by compose. IP will be localhost unless a real one set by treeaform
  host = `${IP}:${CONT_PORT}`
}

// updateHostAddress will copy the reference file to the front-end file, jokes.js in this case
// Then search for the API endpoint {{API_HOST}} and replace the host and port with the one for the correct env.
// Could use a template lib like ejs, handlebars etc., but not worth it for this simple example
updateHostAddress(host, publicFilePath + '/base.js', publicFilePath + '/jokes.js')


let getRand = function (max) {
  return Math.floor(Math.random() * max);
}

let getJokes = function (allJokes, numJokes, type) {
  let jokes = [];
  let selectedJokes = [];

  if (type === 'any') jokes = allJokes;
  else
    //  jokes = allJokes.filter(element => element.type === type); // Get all jokes of one type

    for (let i = 0, j = 0; i < allJokes.length; i++) { // Use filter or do it manually this way
      if (allJokes[i].type === type) {
        jokes[j++] = allJokes[i]
      }
    }

  if (numJokes > jokes.length) numJokes = jokes.length;
  if (numJokes < 1) numJokes = 1;

  for (let i = 0; i < numJokes; i++) {
    selectedJokes[i] = jokes[getRand(jokes.length)];
  }
  return selectedJokes;
}


app.get("/", (req, res) => {
  res.send("Joke Syntax: /jokes/{type}?count=num-jokes [default=1]")
})


app.get("/jokes/:type", (req, res) => {

  let type = req.params.type;
  let count = 1;

  if (req.query.count) count = req.query.count;

  res.send(getJokes(jokesList, count, type)); // Don't really need to pass jokesList as it's global but wouldn't be in reality
});


app.listen(APP_PORT, () => {
  console.log(`Application listening on port ${APP_PORT}`);
})



