// Setup event listeners
document.getElementById('ddJokeType').addEventListener('focus', populateDropdown) // Focus will trigger on dropdown but not selection which is correct
document.getElementById('btnGetJoke').addEventListener('click', renderJoke)       // Get joke button listener

// Call the endpoint. If joke not found, request and render an error web page, otherwise return array of jokes
async function getJoke(endPoint) {
  try {
    let response = await fetch(endPoint)
    if (response.status === 404) {
      const notFound = await fetch('404.html');
      const notFoundPage = await notFound.text();
      document.body.innerHTML = notFoundPage;
    } else {
      let jsonObj = await response.json() // response.json returns a promise so need a await this too
      return jsonObj
    }
  } catch (error) {
    console.log(error)
    alert(error.message + '. Check the server is up.')
  }
}

// Dynamically create a table and add each joke to it
function renderTable(jokeList) {
  document.getElementById("jokeSetup").textContent = ''  // Clear any previous joke setup
  const jokePunchlineElem = document.getElementById("jokePunchline") // Use this element to write the table to

  // Create table element and ad a class to it
  const table = document.createElement('table')
  table.classList.add('jokesTable') // Add cless for styling

  // Create table header
  let headerRow = document.createElement('tr')       // This will create <tr></tr>
  let headers = ['ID', 'Type', 'Setup', 'Punchline'] // Could read from databse if they were likely to change regularly
  headers.forEach(headerText => {                    // Iterate the headers array
    let th = document.createElement('th')            // Create <th></th>
    th.textContent = headerText                      // insert text. e.g. <th>ID</th>
    headerRow.appendChild(th)                        // Append it to the header row. e.g. <tr><th>ID</th> ... </tr>
  })
  table.appendChild(headerRow)  // Add the header row to the table

  // Create table rows
  jokeList.forEach(el => {
    let row = document.createElement('tr')    // <tr></tr>

    let idCell = document.createElement('td') // <td></td>
    idCell.textContent = el.id                // <td>1</td>
    row.appendChild(idCell)                   // <tr><td>1</td></tr>

    let typeCell = document.createElement('td') // <td></td>
    typeCell.textContent = el.type              // <td>programming</td>
    row.appendChild(typeCell)                   // <tr><td>1</td><td>programming</td></tr>

    let setupCell = document.createElement('td') // etc
    setupCell.textContent = el.setup
    row.appendChild(setupCell)

    let punchlineCell = document.createElement('td')
    punchlineCell.textContent = el.punchline
    row.appendChild(punchlineCell)

    table.appendChild(row) // Add row to table
  })

  // Clear existing content and append the new table to the punchline element. Could have its own div
  jokePunchlineElem.innerHTML = ''
  jokePunchlineElem.appendChild(table)
}


// Get one or more jokes
// Render a single joke. If multiple jokes, call renderTable()
async function renderJoke() {
  let numJokes = document.getElementById('numJokes').value * 1 // Should add various checks such as is a number etc

  const ddJokeTypeElem = document.getElementById('ddJokeType')
  let url = `/jokes/${ddJokeTypeElem.value}?count=${numJokes}`

  let joke = await getJoke(url)  // Because getJoke returns a promise, we need to await it resolving
  let jokeSetupElem = document.getElementById("jokeSetup")
  let jokePunchlineElem = document.getElementById("jokePunchline")
  let jokePunchlineStr = ''

  jokePunchlineElem.textContent = '' // Clear the old punchline

  // If more than one then output table
  if (joke.length > 1) renderTable(joke)
  else {
    jokeSetupElem.textContent = joke[0].setup
    jokePunchlineStr = joke[0].punchline
    setTimeout(() => { jokePunchlineElem.textContent = jokePunchlineStr }, 3000)
  }
}

// When the dropdown is clicked, call API to get types from database and populate dropdown
async function populateDropdown() {
  try {
    const response = await fetch('/types')
    if (!response.ok) {
      throw new Error('No response from server')
    }
    const types = await response.json()

    const dropdown = document.getElementById('ddJokeType')
    dropdown.innerHTML = '' // Clear existing options

    types.forEach(type => {
      const option = document.createElement('option')
      option.value = type.type // Assuming each type object has an 'id' property
      option.textContent = type.type // Assuming each type object has a 'name' property
      dropdown.appendChild(option)
    })
  } catch (error) {
    console.error('Error fetching and populating dropdown:', error)
  }
}

// Call the function to populate the dropdown to get started
populateDropdown()
