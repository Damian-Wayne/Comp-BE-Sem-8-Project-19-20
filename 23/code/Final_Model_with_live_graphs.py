import smbus2
import time
import RPi.GPIO as GPIO
import os
import sys
import Adafruit_DHT
import json 
from web3 import Web3, HTTPProvider, IPCProvider
from web3.middleware import geth_poa_middleware
import matplotlib.pyplot as plt
import datetime

#initializing the graph
plt.ion()
fig, a = plt.subplots(2, 2)

#declaring lists for plotting graphs
temperature_graph, humidity_graph = [], []
motion_graph, luminosity_graph = [], []
timestamp_graph = []

#Declaring the GPIO pin numbers
LAMP = 23
PIR = 24
FAN_PIN = 22
PIR_sensor_id = 121
Temperature_and_humidity_sensor_id = 232
Luminosity_sensor_id = 343

#GPIO initialization
GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(LAMP, GPIO.OUT)
GPIO.setup(PIR, GPIO.IN)
GPIO.setup(FAN_PIN, GPIO.OUT)

#Setting up the Web3 Connection
web3 = Web3(HTTPProvider('http://localhost:8042')) 
web3.middleware_onion.inject(geth_poa_middleware, layer=0)
print("Web3 connection: ", web3.isConnected())

#Setting the default account for the transactions to happen from
web3.eth.defaultAccount = web3.eth.accounts[0] 

#Smart contract address and the ABI
address = "0xc0B8F046D02610b4e840Cc2BF2C9ce2f50Fff128" 
abi = json.loads('[{"constant":true,"inputs":[],"name":"valueCount","outputs":[{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint32"}],"name":"value","outputs":[{"name":"timestamp","type":"uint32"},{"name":"motion_sensor_id","type":"uint32"},{"name":"motion_sensor_value","type":"uint32"},{"name":"temperature_humidity_sensor_id","type":"uint32"},{"name":"temperature_value","type":"uint32"},{"name":"humidity_value","type":"uint32"},{"name":"luminosity_sensor_id","type":"uint32"},{"name":"luminosity_value","type":"uint32"},{"name":"fan_action","type":"uint32"},{"name":"light_action","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"timestamp","type":"uint32"},{"name":"motion_sensor_id","type":"uint32"},{"name":"motion_sensor_value","type":"uint32"},{"name":"temperature_humidity_sensor_id","type":"uint32"},{"name":"temperature_value","type":"uint32"},{"name":"humidity_value","type":"uint32"},{"name":"luminosity_sensor_id","type":"uint32"},{"name":"luminosity_value","type":"uint32"},{"name":"fan_action","type":"uint32"},{"name":"light_action","type":"uint32"}],"name":"addRecord","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"get_valueCount","outputs":[{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"index","type":"uint32"}],"name":"getValue","outputs":[{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"}]') 

#creating the contract instace - To interact with the smart contract
contract = web3.eth.contract(address = address, abi = abi)

#creating a transaction hash and waiting for the receipt - (Can comment out the tx_receipt if Blockchain is not syncing currently)
tx_hash = contract.constructor().transact()
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)

def fanON():
    GPIO.output(FAN_PIN, 0)
    return()

def fanOFF():
    GPIO.output(FAN_PIN, 1)
    return()

def get_temp_from_sensor():
    humidity, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, 27)
    return(temp, humidity)

def Lamp_on():
    GPIO.output(LAMP, True)    

def Lamp_off():
    GPIO.output(LAMP, False)

def Luminosity():
    bus = smbus2.SMBus(1)

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
    motion_graph.append(i)
    print("PIR Value: ", i)
    
    Lamp_action = 0
    Fan_action = 0
    
    temp, humidity = get_temp_from_sensor()
    temperature_graph.append(temp)
    humidity_graph.append(humidity)
    print("Temperature DHT11: ", temp)
    print("Humidity DHT11: ", humidity)
    
    chvalue = Luminosity()
    luminosity_graph.append(chvalue)
    print("Lux Value: ", chvalue)

    if(i == 0):
        Lamp_off()
        fanOFF()

    elif(i == 1):                                
        if(chvalue < 700):
            Lamp_on()
            Lamp_action = 1
        else:
            Lamp_off()
                        
        if(temp <= 28):
            fanOFF()
        else:
            fanON()
            Fan_action = 1
        
    print("Lamp action: ", Lamp_action)
    print("Fan action: ", Fan_action)
    print("-------------------------")
    timestamp_graph.append(datetime.datetime.now())
    tx_hash = contract.functions.addRecord(int(time.time()),
                                            PIR_sensor_id, i,
                                            Temperature_and_humidity_sensor_id, int(temp), int(humidity),
                                            Luminosity_sensor_id, chvalue,
                                            Lamp_action, Fan_action).transact() 
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)

    #Plotting the graphs
    a[0][0].clear()
    a[0][1].clear()
    a[1][0].clear()
    a[1][1].clear()

    a[0][0].set_title("Temperature")
    a[0][1].set_title("Humidity")
    a[1][0].set_title("Motion")
    a[0][1].set_title("Luminosity")

    a[0][0].plot(timestamp_graph, temperature_graph)
    a[0][1].plot(timestamp_graph, humidity_graph)
    a[1][0].plot(timestamp_graph, motion_graph)
    a[1][1].plot(timestamp_graph, luminosity_graph)

    figManager = plt.get_current_fig_manager()
    figManager.resize(*figManager.window.maxsize())

    plt.xticks(rotation = 90)
    plt.show()
    plt.pause(5)

    time.sleep(2)