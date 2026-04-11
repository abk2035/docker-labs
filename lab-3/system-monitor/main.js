const { app, BrowserWindow, ipcMain } = require('electron');
const { getStats } = require('./system');

function createWindow() {
    const win = new BrowserWindow({
        width: 600,
        height: 500,
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    win.loadFile('index.html');
}

ipcMain.handle('get-stats', async () => {
    return await getStats();
});

app.whenReady().then(createWindow);