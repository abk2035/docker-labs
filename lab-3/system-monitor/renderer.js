const { ipcRenderer } = require('electron');

async function refresh() {
    const stats = await ipcRenderer.invoke('get-stats');

    document.getElementById('ram').innerText =
        `${stats.ram.used} / ${stats.ram.total} MB (${stats.ram.percent.toFixed(2)}%)`;

    document.getElementById('cpu').innerText =
        `${stats.cpu} %`;

    document.getElementById('disk').innerText =
        `${stats.disk.percent} % utilisé`;
}

setInterval(refresh, 2000);