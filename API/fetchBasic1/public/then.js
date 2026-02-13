
function callApiThen(endpoint) {
  fetch(endpoint)
    .then(response => response.json())
    .then(data => {
      document.getElementById('response').textContent = JSON.stringify(data, null, 2);
    })
    .catch(error => {
      document.getElementById('response').textContent = 'API failed: ' + error;
    });
}
