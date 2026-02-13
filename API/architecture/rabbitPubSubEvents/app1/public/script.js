// Call API to load the dropdown
async function load() {
  try {
    const res = await fetch('/components');
    const list = await res.json();
    const select = document.getElementById('components');
    select.innerHTML = '';
    list.forEach(item => {
      const opt = document.createElement('option');
      opt.value = item;
      opt.textContent = item;
      select.appendChild(opt);
    });
  } catch (err) {
    alert('Failed to load component list');
  }
}

// When dropdown is accessed by moving the pointer over it, call the API to repopulate it in case it has changed
document.getElementById('components').addEventListener('pointerenter', () => load());

// Load the menu when the page loads or is refreshed
window.onload = load();

