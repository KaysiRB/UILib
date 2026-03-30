const RESOURCE = GetParentResourceName();

let state = {
    visible: false,
    items: [],
    selected: 0
};

function nui(event, data = {}) {
    fetch(`https://${RESOURCE}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

function render(menu) {
    const app = document.getElementById('app');
    state.items = menu.items || [];
    state.visible = true;
    state.selected = 0;

    let html = `
        <div class="header">${menu.title || 'Menu'}</div>
        <div class="menu-list">`;

    state.items.forEach((item, i) => {
        if (item.type === 'button' || item.type === 'toggle' || item.type === 'submenu') {
            html += `
                <div class="btn ${i===0?'selected':''}" data-index="${i}">
                    ${item.label}
                    ${item.desc ? `<div class="desc">${item.desc}</div>` : ''}
                </div>`;
        } else if (item.type === 'slider') {
            html += `
                <div class="slider-container">
                    <div class="slider-label">${item.label}</div>
                    <div class="slider-value">${item.value || item.min || 0}</div>
                </div>`;
        } else if (item.type === 'back') {
            html += `<div class="btn ${i===0?'selected':''}" data-index="${i}">${item.label}</div>`;
        }
    });

    html += `
        </div>
        <div class="footer">↑ ↓ • ENTER • ESC</div>`;

    app.innerHTML = html;
    app.classList.add('visible');
    update();
}

function update() {
    document.querySelectorAll('.btn, .slider-container').forEach((el, i) => {
        el.classList.toggle('selected', i === state.selected);
    });
}

function move(dir) {
    const max = state.items.length - 1;
    state.selected = (state.selected + dir + max + 1) % (max + 1);
    update();
}

function select() {
    const item = state.items[state.selected];
    if (!item) return;
    
    const data = { index: state.selected };
    if (item.type === 'slider') {
        // Slider value via input ou default
        data.value = item.value || 50;
    }
    nui("select", data);
}

function closeMenu() {
    document.getElementById('app').classList.remove('visible');
    state.visible = false;
    nui('closeMenu');
}

// Key navigation
document.addEventListener('keydown', (e) => {
    if (!state.visible) return;

    e.preventDefault();
    switch (e.key.toLowerCase()) {
        case 'arrowup':
        case 'z': case 'w':
            move(-1); break;
        case 'arrowdown':
        case 's':
            move(1); break;
        case 'enter':
            select(); break;
        case 'escape':
            closeMenu(); break;
    }
});

// NUI Messages
window.addEventListener('message', (e) => {
    switch(e.data.action) {
        case 'openMenu':
            render(e.data.menu);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'updateItem':
            const el = document.querySelector(`[data-index="${e.data.index}"]`);
            if (el && e.data.label) {
                el.innerHTML = e.data.label + (el.querySelector('.desc') ? el.innerHTML.match(/<div class="desc">.*<\/div>$/) || '' : '');
            }
            if (e.data.value !== undefined) {
                const valEl = document.querySelector('.slider-value');
                if (valEl) valEl.textContent = e.data.value;
            }
            break;
    }
});