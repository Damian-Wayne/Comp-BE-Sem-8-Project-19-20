const {app, BrowserWindow} = require('electron');
const path = require('path');
const url = require('url');

let win;

function createWindow() {
    win = new BrowserWindow({
        width:1000,
        height:600,
        resizable: false,
        frame:false,
        webPreferences: {
            nodeIntegration: true
        }
    })

    // win.openDevTools()
    win.setAutoHideMenuBar(true)
    win.loadFile("index.html")

    win.on('closed', ()=>{
        win = null
    })
}

app.on('ready',createWindow)

app.on('window-all-closed',()=>{
    if (process.platform !== 'darwin'){
        app.quit()
    }
})

app.on('activate',()=>{
    if (win==null){
        createWindow()
    }
})