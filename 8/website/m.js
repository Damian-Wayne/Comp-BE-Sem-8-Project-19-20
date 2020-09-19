// Initialize Firebase (ADD YOUR OWN DATA)
  var firebaseConfig = {
    apiKey: "AIzaSyBruEDhy9jgU4QwnFlixJ-Y8urcBN_UqFM",
    authDomain: "mshms-15306.firebaseapp.com",
    databaseURL: "https://mshms-15306.firebaseio.com",
    projectId: "mshms-15306",
    storageBucket: "mshms-15306.appspot.com",
    messagingSenderId: "564679319047",
    appId: "1:564679319047:web:fa3e0b5a54f939a48494a2",
    measurementId: "G-VCL8PNJR7K"
  };
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
  var hospital = getInputVal('hospital');
  var email = getInputVal('email');
  var phone = getInputVal('phone');
  var message = getInputVal('message');

  // Save message
  saveMessage(name, hospital, email, phone, message);

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
function saveMessage(name, hospital, email, phone, message){
  var newMessageRef = messagesRef.push();
  newMessageRef.set({
    name: name,
    hospital:hospital,
    email:email,
    phone:phone,
    message:message
  });
  location.replace("index.html")
}
