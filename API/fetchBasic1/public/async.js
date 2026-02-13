
async function callApiAsync(endpoint) {
  try {
    const response = await fetch(endpoint);
    const data = await response.json();
    document.getElementById('response').textContent = JSON.stringify(data, null, 2);
  } catch (error) {
    document.getElementById('response').textContent = 'API failed: ' + error;
  }
}

 

  
async function callCounter() {
  outElem = document.getElementById('counter')
    for (let i = 0; i <= 10; i++) {
      outElem.innerText = i;
      await sleep(1000); // non-blocking delay
    }
  }


 function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

