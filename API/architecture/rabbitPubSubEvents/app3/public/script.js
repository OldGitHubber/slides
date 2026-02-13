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

// Mouse over dropdown, call API to populate before clicking
document.getElementById('components').addEventListener('pointerenter', () => {
  load(); // Load the dropdown when dropdown pointer clicked
});

// Load the menu when the page loads or is refreshed
window.onload = load();