// Initialize Firebase (ADD YOUR OWN DATA)0
 var firebaseConfig = {
    apiKey: "AIzaSyAYpzq_Vu4fE_O9w7XHDENBB1OcH7f2Ugc",
    authDomain: "medical-dab86.firebaseapp.com",
    databaseURL: "https://medical-dab86.firebaseio.com",
    projectId: "medical-dab86",
    storageBucket: "medical-dab86.appspot.com",
    messagingSenderId: "495056003775",
    appId: "1:495056003775:web:e419ea08eb1c17e8a69c0a",
    measurementId: "G-RFZZF2SSDN"
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
  firebase.analytics();

// Reference messages collection
var messagesRef = firebase.database().ref('About');

// Listen for form submit
document.getElementById('contactForm').addEventListener('submit', submitForm);

// Submit form
function submitForm(e){
  e.preventDefault();

  // Get values
  var name = getInputVal('name');
  var address = getInputVal('address');
  var email = getInputVal('email');
  var phone = getInputVal('phone');
    var password = getInputVal('password');

  var message = getInputVal('message');

  // Save message
  saveMessage(name, address, email, phone,password, message);

  // Show alert
  document.querySelector('.alert').style.display = 'block';

  // Hide alert after 3 seconds
  setTimeout(function(){
    document.querySelector('.alert').style.display = 'none';
  },3000);

  // Clear form
  document.getElementById('contactForm').reset();
}

// Function to get get form values
function getInputVal(id){
  return document.getElementById(id).value;
}

// Save message to firebase
function saveMessage(name, address, email, phone,password, message){
  var newMessageRef = messagesRef.push();
  newMessageRef.set({
    name: name,
    address:address,
    email:email,
    phone:phone,
    message:message
  });
  location.replace("index.html")
}
