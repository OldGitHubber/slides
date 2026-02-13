
document.getElementById("btnGetJoke").addEventListener("click", getAndRenderJoke)

// Call getJoke to get the jokes from the server. Write a single joke setup, delay punchline
// Or for multiple jokes, call renderTable to output them all as a table
async function getAndRenderJoke() {
 let url = `/jokes/`
 let numJokes = 1; // default
 const ddJokeTypeElem = document.getElementById('ddJokeType')
 url += ddJokeTypeElem.value // Add the type to the url. e.g. /jokes/dad

 let textBoxElem = document.getElementById('numJokes')

 if (textBoxElem.value.length != 0)
  numJokes = textBoxElem.value

 url += `?count=${numJokes}` // Add num jokes to url. e.g., /jokes/dad/?count=10

 try {
  let response = await fetch(url)
  if (!response.ok) throw new Error("Failed to get data from server") // This is not a system error but still want to stop further processing

  let jokes = await response.json() // response.json returns a promise so need a await this too

  let jokeSetupElem = document.getElementById("jokeSetup")
  let jokePunchlineElem = document.getElementById("jokePunchline")
  let jokePunchlineStr = ''

  jokePunchlineElem.textContent = '' // Clear the old punchline

  // If more than one then output table
  if (jokes.length > 1) renderTable(jokes)
  else {
   jokeSetupElem.textContent = jokes[0].setup
   jokePunchlineStr = jokes[0].punchline
   setTimeout(() => { jokePunchlineElem.textContent = jokePunchlineStr; }, 3000)
  }
 } catch (err) {
  alert(err.message + '. Check the server is up.')
 }
}

// List all jokes in a table
function renderTable(jokeList) {
 let jokeSetupElem = document.getElementById("jokeSetup")
 let jokePunchlineElem = document.getElementById("jokePunchline")

 jokeSetupElem.textContent = '' // Clear any old stuff
 let tableStr = '<table class="jokesTable"><th>ID</th><th>Type</th><th>Setup</th><th>Punchline</th>'
 jokeList.forEach(el => {
  tableStr += `<tr><td>${el.id}</td><td>${el.type}</td><td>${el.setup}</td><td>${el.punchline}</td></tr>`
 })
 tableStr += '</table>'

 jokePunchlineElem.innerHTML = tableStr
}

