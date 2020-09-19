import smbus
import time
import RPi.GPIO as GPIO
import os
import sys
import Adafruit_DHT

LAMP = 23
PIR = 24
FAN_PIN = 22

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(LAMP, GPIO.OUT)
GPIO.setup(PIR, GPIO.IN)
GPIO.setup(FAN_PIN, GPIO.OUT)
    
def fanON():
    GPIO.output(FAN_PIN, 0)
    return()

def fanOFF():
    GPIO.output(FAN_PIN, 1)
    return()

def get_temp_from_sensor():
    humidity, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, 27)
    return(temp)

def Lamp_on():
    GPIO.output(LAMP, True)    

def Lamp_off():
    GPIO.output(LAMP, False)

def Luminosity():
    bus = smbus.SMBus(1)

    bus.write_byte_data(0x39, 0x00 | 0x80, 0x03)
    bus.write_byte_data(0x39, 0x01 | 0x80, 0x02)

    time.sleep(0.5)
    
    data = bus.read_i2c_block_data(0x39, 0x0C | 0x80, 2)
    data1 = bus.read_i2c_block_data(0x39, 0x0E | 0x80, 2)

    ch0 = data[1] * 256 + data[0]
    ch1 = data1[1] * 256 + data1[0]
    
    chvalue = ch0 - ch1
    return chvalue

while(True):
    i = GPIO.input(PIR)
    if(i == 0):
        Lamp_off()
        fanOFF()
        print("PIR Value: ", i)
    elif(i == 1):
        print("PIR Value: ", i)
        
        chvalue = Luminosity()
        print("Lux Value: ", chvalue)
        
        if(chvalue < 700):
            Lamp_on()
        else:
            Lamp_off()
        
        temp = get_temp_from_sensor()
        print("Temperature DHT11: ", temp)
        print("----------")
        if(temp <= 28):
            fanOFF()
        else:
            fanON()
            
    time.sleep(2)