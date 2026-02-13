// Fetch a joke from the server and display it
async function renderJoke() {
  let url = '/jokes/'
  let numJokes = 1   // default

  const ddJokeTypeElem = document.getElementById('ddJokeType')
  url += ddJokeTypeElem.value

  const numBoxVal = parseInt(document.getElementById('numJokes').value, 10)

  if (Number.isInteger(numBoxVal) && numBoxVal > 1)
    numJokes = numBoxVal

  url += `?count=${numJokes}`

  const joke = await getJoke(url) // Will be an array of jokes
  const jokeSetupElem = document.getElementById("jokeSetup")
  const jokePunchlineElem = document.getElementById("jokePunchline")

  jokePunchlineElem.textContent = ''   // Clear the old punchline

  // If more than one then call renderTable to output jokes in a table
  if (joke.length > 1) renderTable(joke)
  else {
    jokeSetupElem.textContent = joke[0].setup
    setTimeout(() => { jokePunchlineElem.textContent = joke[0].punchline }, 3000) // Wait for it ...
  }
}

async function getJoke(endPoint) {
  try {
    let response = await fetch(endPoint)

    // Could look for status code and call a different page for each that could occur
    // Or just have a general one and look for response.ok as here
    if (!response.ok) {
      window.location.href = `error.html`
      return
    }
    let jsonObj = await response.json()   // response.json returns a promise so need a await this too
    return jsonObj
  } catch (error) {
    console.log(error)
    alert(error.message + '. Check the server is up.')
  }
}

// This is a simple approach using html as a string but you could create elements and appendChild etc which
// is a bit longer winded but easier to debug
let renderTable = function (jokeList) {
  let jokeSetupElem = document.getElementById("jokeSetup")
  let jokePunchlineElem = document.getElementById("jokePunchline")

  jokeSetupElem.textContent = ''   // Clear any old stuff
  let tableStr = '<table id="jokesTable"><th>ID</th><th>Type</th><th>Setup</th><th>Punchline</th>'
  jokeList.forEach(el => {
    tableStr += `<tr><td>${el.id}</td><td>${el.type}</td><td>${el.setup}</td><td>${el.punchline}</td></tr>`
  })
  tableStr += '</table>'

  jokePunchlineElem.innerHTML = tableStr
}


