const {remote} = require('electron');

var win = remote.getCurrentWindow();

document.getElementById('close-button').addEventListener('click',()=>{
    console.log('Close Button Pressed. CLosing the App.');
    win.close();
})

document.getElementById('minimize-button').addEventListener('click',()=>{
    console.log('Minimize Button Pressed. Minimizing the App.'); 
    win.minimize();
})
