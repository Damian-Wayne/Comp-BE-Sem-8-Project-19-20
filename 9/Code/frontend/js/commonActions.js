var initHome = document.getElementById('home')
initHome.style.backgroundColor = "white"
initHome.style.color = "black"
initHome.style.fontWeight = "bold"
document.getElementById("home-icon-black").style.display = "inline-block"


// function deactivateTab(tabName){

//     document.getElementById(tabName+"-content").style.display = "none"
//     document.getElementById(tabName+"-content").style.display = "none"
// }
function activateTab(tabName){
    console.log(tabName) 
    if (tabName!="settings"){
        document.getElementById("settings-content").style.display = "none"
        document.getElementById("settings-content").style.display = "none"
    }
    var i, allTabs
    allTabs = document.getElementsByClassName("menu-item")
    allContents = document.getElementsByClassName("content-card")
    allBlackIcons = document.getElementsByClassName("menu-icon-black")
    for (i=0; i<allTabs.length; i++){
        allTabs[i].style.backgroundColor = "black"
        allTabs[i].style.color = "white"
        allContents[i].style.display = "none"
        allBlackIcons[i].style.display = "none"
    }
var request = {
    "scantype":"",
}
    var tab = document.getElementById(tabName)
    tab.style.backgroundColor = "white"
    tab.style.color = "black"
    tab.style.fontWeight = "bold"
    document.getElementById(tabName+"-content").style.display = "inline-block"
    document.getElementById(tabName+"-content").style.display = "inline-block"
    document.getElementById(tabName+"-icon-black").style.display = "inline-block"
}
function activateInternalTab(tabName){
    console.log(tabName) 
    var i, allTabs
    allTabs = document.getElementsByClassName("menu-item")
    allContents = document.getElementsByClassName("content-card")
    allBlackIcons = document.getElementsByClassName("menu-icon-black")
    for (i=0; i<allTabs.length; i++){
        allTabs[i].style.backgroundColor = "black"
        allTabs[i].style.color = "white"
        allContents[i].style.display = "none"
        allBlackIcons[i].style.display = "none"
    }
var request = {
    "scantype":"",
}
    var tab = document.getElementById(tabName)
    tab.style.backgroundColor = "white"
    tab.style.color = "black"
    tab.style.fontWeight = "bold"
    document.getElementById(tabName+"-content").style.display = "inline-block"
    document.getElementById(tabName+"-content").style.display = "inline-block"
    // document.getElementById(tabName+"-icon-black").style.display = "inline-block"
}

function videoCheck(){
    var isChecked = document.getElementById("video-scan-checkbox");
    var precisionSlider = document.getElementById("slider-container");
    precisionSlider.style.display = isChecked.checked ? "inline-block" : "none"; 
}

function scan_trigger(scan_type){
    var img_s = document.getElementById("image-scan-checkbox").value
    var img_scan = document.getElementById("image-scan-checkbox");
    var vid_s = document.getElementById("video-scan-checkbox").value;
    var vid_scan = document.getElementById("video-scan-checkbox");
    var scan_opt = document.getElementById("scan-options");
    var progress_bar = document.getElementById("progress-bar");
    var precision = document.getElementById("precisionSlider").value;
    var precisionSlider = document.getElementById("precisionSlider");
    var data={
        "img_s":img_scan.checked,
        "scantype":scan_type,
        "vid_s":vid_scan.checked,
        "precision":precision};
    // console.log(img_scan.checked);
    // console.log(img_s);
    // console.log(precision);

    let ld_bar = new ldBar(".ldBar")
    if(img_scan.checked || vid_scan.checked){
        if ((scan_type === "quick") | (scan_type === "deep")){
            scan_opt.style.display = "none"
            progress_bar.style.display = "inline-block"
            // Disable Checkboxes
            img_scan.setAttribute('disabled','')
            vid_scan.setAttribute('disabled','')
            precisionSlider.setAttribute('disabled','')
             //Progress Bar scene
             console.log(ld_bar);
             ld_bar.set(30)
             timer = setTimeout(()=>{
                 ld_bar.set(50)
             },3000)
             timer = setTimeout(()=>{
                ld_bar.set(75);},8000)
             timer = setTimeout(()=>{
                 ld_bar.set(100);},10000) 
            
            //Begin scanning through server
                $.ajax({
                    url: "http://localhost:8882/",
                    data: data,
                    type:"GET",
                    success: function(result){
                    var explicit_list = result;
                    console.log("In success");
                    resultPanelOutput(explicit_list);
                    // console.log(explicit_list);
                    },
                    error: function (error){
                    console.log(error);
                }
                
                });
        }
    }
    else{
        myFunction()
    }
    if (scan_type === "stop"){
        console.log("Hit stop");
        scan_opt.style.display = "inline-block";
        img_scan.removeAttribute('disabled');
        vid_scan.removeAttribute('disabled');
        progress_bar.removeAttribute('disabled');
        precisionSlider.removeAttribute('disabled','');
        clearTimeout(timer);
        progress_bar.style.display = "none";
        ld_bar.set(0);
    }   

    if (scan_type === "ok"){
        console.log("Hit ok");
        ld_bar.set(0);
        scan_opt.style.display = "inline-block";
        img_scan.removeAttribute('disabled');
        vid_scan.removeAttribute('disabled');
        progress_bar.removeAttribute('disabled');
        precisionSlider.removeAttribute('disabled','');
        clearTimeout(timer);
        progress_bar.style.display = "none";
        activateTab('home');
    }
}

    function resultPanelOutput(explicit_list){
        console.log(explicit_list);
        activateInternalTab('showResults');
        console.log("In results panel");
        document.getElementById("explicitList").innerHTML = "";

        if(Object.keys(explicit_list).length == 0) {
            document.getElementById("explicitListHeader").innerHTML = "Nothing found";
        }
        else {
            document.getElementById("explicitListHeader").innerHTML = "Here's all that you should worry about";
            for(o in explicit_list){
                console.log(explicit_list[o]);
                var node = document.createElement("LI");                 // Create a <li> node
                var textnode = document.createTextNode(explicit_list[o]);         // Create a text node
                node.appendChild(textnode);                              // Append the text to <li>
                document.getElementById("explicitList").appendChild(node);
            }
        }
        // console.log("Resetting shit");
        // scan_opt.style.display = "inline-block";
        // img_scan.removeAttribute('disabled');
        // vid_scan.removeAttribute('disabled');
        // progress_bar.removeAttribute('disabled');
        // precisionSlider.removeAttribute('disabled','');
        // clearTimeout(timer);
        // progress_bar.style.display = "none";
        // ld_bar.set(0);
    }

    // function resetScanPanel(){
    //     console.log("Resetting shit");
    //     // scan_opt.style.display = "inline-block";
    //     img_scan.removeAttribute('disabled');
    //     vid_scan.removeAttribute('disabled');
    //     progress_bar.removeAttribute('disabled');
    //     precisionSlider.removeAttribute('disabled','');
    //     clearTimeout(timer);
    //     progress_bar.style.display = "none";
    //     ld_bar.set(0);
    //     activateTab('home');
    // }



function myFunction() {
    // Get the snackbar DIV
    var x = document.getElementById("snackbar");
  
    // Add the "show" class to DIV
    x.className = "show";
  
    // After 3 seconds, remove the show class from DIV
    setTimeout(function(){ x.className = x.className.replace("show", ""); }, 3000);
  } 