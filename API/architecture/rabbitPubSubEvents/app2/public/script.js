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

// Submit button event handler. 
document.getElementById('submit').addEventListener('click', async () => {
  const sel = document.getElementById('components');
  const entered = document.getElementById('newComponent').value.trim();
  const component = entered || sel.value; // New or one from the list if new is empty
  if (!component) return alert('Enter a component or choose from the list');
  await fetch('/component', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ component: component }) });
  document.getElementById('newComponent').value = ""; // Posted so clear the new component box for next time
});

// Mouse over dropdown, call API to populate before clicking
document.getElementById('components').addEventListener('pointerenter', () => {
  load(); // Load the dropdown when dropdown pointer clicked
});

// Load the menu when the page loads or is refreshed
window.onload = load();