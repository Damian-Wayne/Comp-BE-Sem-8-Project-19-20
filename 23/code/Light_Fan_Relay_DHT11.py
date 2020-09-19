import RPi.GPIO as GPIO
import time
import os
import datetime
import sys
import Adafruit_DHT

PIR_input = 5
LED = 12
Bulb = 2
FAN_PIN = 18
FAN_START = 28
FAN_END = 27

action = sys.argv.pop()

def GPIOsetup():
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(PIR_input, GPIO.IN)
    GPIO.setup(LED, GPIO.OUT)
    GPIO.setup(Bulb, GPIO.OUT)
    GPIO.setup(FAN_PIN, GPIO.OUT)
    GPIO.output(LED, GPIO.LOW)    
    
def fanON():
    GPIOsetup()
    GPIO.output(FAN_PIN, 0)
    return()

def fanOFF():
    GPIOsetup()
    GPIO.output(FAN_PIN, 1)
    return()

def get_temp_from_sensor():
    humidity, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, 4)
    return(temp)

def check_fan(pin):
    GPIOsetup()
    return GPIO.input(pin)

def run(pin):
    current_date = datetime.datetime.now()
    temp = get_temp_from_sensor()
    #print(temp)
    if((temp) >= FAN_START):
        print(temp)
        if(check_fan(pin) == 1):
            print("Fan is OFF ... Starting Fan")
            fanON()
        else:
            time.sleep(5)
            print("Fan is ON")
    elif((temp) <= FAN_END):
        print(temp)
        if(check_fan(pin) == 0):
            print("Fan is ON ... Shutting it down")
            fanOFF()
            GPIO.cleanup()
            return 1
        else:
            time.sleep(5)
            print("Fan is OFF")
    else:
        pass

while True:
    GPIOsetup()
    print(GPIO.input(PIR_input))
    if(GPIO.input(PIR_input)):
        GPIO.output(Bulb, True)
        GPIO.output(LED, GPIO.HIGH)
        temp = get_temp_from_sensor()
        print(temp)
        if((temp) < FAN_START):
            print("Laboratory under normal temperatures")
        else:
            try:
                tmp = run(FAN_PIN)
                time.sleep(5)
                if(tmp == 1):
                    break
            except KeyboardInterrupt:
                fanOFF()
                GPIO.output(Bulb, False)
                GPIO.cleanup()
            finally:
                fanOFF()
                GPIO.output(Bulb, False)
                GPIO.cleanup()

        #time.sleep(5)
    else:
        GPIO.output(Bulb, False)
        GPIO.output(LED, GPIO.LOW)
        fanOFF()
        GPIO.cleanup()
        #time.sleep(5)

