

document.getElementById("btnGetJoke").addEventListener("click", btnGetJokeHandler)

function btnGetJokeHandler() {
  renderJoke()
}

async function getJoke(URI) {
  try {
    let response = await fetch(URI)
    let jsonObj = await response.json() // response.json returns a promise so need a await this too
    return jsonObj
  } catch (error) {
    console.log(error);
    alert(error.message + '. Check the server is up.')
  }
}

function renderTable(jokeList) {
  let jokeSetupElem = document.getElementById("jokeSetup")
  let jokePunchlineElem = document.getElementById("jokePunchline")

  jokeSetupElem.textContent = '' // Clear any old stuff
  let tableStr = '<table id="jokesTable"><th>ID</th><th>Type</th><th>Setup</th><th>Punchline</th>'
  jokeList.forEach(el => {
    tableStr += `<tr><td>${el.id}</td><td>${el.type}</td><td>${el.setup}</td><td>${el.punchline}</td></tr>`
  })
  tableStr += '</table>'

  jokePunchlineElem.innerHTML = tableStr
}


 async function renderJoke() {
  let URI = 'http://localhost:3000/jokes/'
  
  let numJokes = 1; // default

  let ddJokeTypeElem = document.getElementById('ddJokeType')
  URI += ddJokeTypeElem.value

  let textBoxElem = document.getElementById('numJokes')

  if (textBoxElem.value.length != 0)
    numJokes = textBoxElem.value

  URI += `?count=${numJokes}`

  let joke = await getJoke(URI)  // Because getJoke returns a promise, we need to await it resolving
  let jokeSetupElem = document.getElementById("jokeSetup")
  let jokePunchlineElem = document.getElementById("jokePunchline")
  let jokePunchlineStr = ''

  jokePunchlineElem.textContent = '' // Clear the old punchline

  // If more than one then output table
  if (joke.length > 1) renderTable(joke)
  else {
    jokeSetupElem.textContent = joke[0].setup
    jokePunchlineStr = joke[0].punchline
    setTimeout(() => { jokePunchlineElem.textContent = jokePunchlineStr; }, 3000)
  }
}