#include <WiFi.h>

// defines pins numbers
const int trigPin1 = 13;
const int echoPin1 = 12;
//const int trigPin2 = 4;
//const int echoPin2 = 2;

// defines variables
long duration1, duration2;
int distance1, distance2;

const char* wifi_name = "Le"; //Your Wifi name
const char* wifi_pass = "12345678";    //Your Wifi password
WiFiServer server(80);                  //Port 80

void setup()
{
    pinMode(trigPin1, OUTPUT); // Sets the trigPin as an Output
    pinMode(echoPin1, INPUT); // Sets the echoPin as an Input
    //pinMode(trigPin2, OUTPUT); // Sets the trigPin as an Output
    //pinMode(echoPin2, INPUT); // Sets the echoPin as an Input
    Serial.begin(115200);
 
    // Let's connect to wifi network 
    Serial.print("Connecting to ");
    Serial.print(wifi_name);
    WiFi.begin(wifi_name, wifi_pass);       //Connecting to wifi network

    while (WiFi.status() != WL_CONNECTED) { //Waiting for the responce of wifi network
        delay(500);
        Serial.print(".");
    }
    Serial.println("");
    Serial.println("Connection Successful");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());         //Getting the IP address at which our webserver will be created
    server.begin();                         //Starting the server
}

void loop()
{
 WiFiClient client = server.available();   //Checking for incoming clients
digitalWrite(trigPin1, LOW);
delayMicroseconds(2);

// Sets the trigPin on HIGH state for 10 micro seconds
digitalWrite(trigPin1, HIGH);
delayMicroseconds(10);
digitalWrite(trigPin1, LOW);

// Reads the echoPin, returns the sound wave travel time in microseconds
duration1 = pulseIn(echoPin1, HIGH);
distance1= duration1*0.034/2;
Serial.println(distance1);

  if (client)                 
  {                             
    if(distance1<150)
    {
      client.print("<body><h1>l</h1>");
    }
    else
    {
      client.print("<body><h1>d</h1>");
    }
  }
    delay(2000);
}
