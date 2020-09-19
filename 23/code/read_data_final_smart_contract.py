import json 
import time 
import RPi.GPIO as GPIO
import smbus2
from web3 import Web3, HTTPProvider, IPCProvider 
from web3.middleware import geth_poa_middleware
import Adafruit_DHT 

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(24, GPIO.IN)

web3 = Web3(HTTPProvider('http://localhost:8042')) 
web3.middleware_onion.inject(geth_poa_middleware, layer=0)
print(web3.isConnected()) 

address = "0xc0B8F046D02610b4e840Cc2BF2C9ce2f50Fff128" 
abi = json.loads('[{"constant":true,"inputs":[],"name":"valueCount","outputs":[{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint32"}],"name":"value","outputs":[{"name":"timestamp","type":"uint32"},{"name":"motion_sensor_id","type":"uint32"},{"name":"motion_sensor_value","type":"uint32"},{"name":"temperature_humidity_sensor_id","type":"uint32"},{"name":"temperature_value","type":"uint32"},{"name":"humidity_value","type":"uint32"},{"name":"luminosity_sensor_id","type":"uint32"},{"name":"luminosity_value","type":"uint32"},{"name":"fan_action","type":"uint32"},{"name":"light_action","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"timestamp","type":"uint32"},{"name":"motion_sensor_id","type":"uint32"},{"name":"motion_sensor_value","type":"uint32"},{"name":"temperature_humidity_sensor_id","type":"uint32"},{"name":"temperature_value","type":"uint32"},{"name":"humidity_value","type":"uint32"},{"name":"luminosity_sensor_id","type":"uint32"},{"name":"luminosity_value","type":"uint32"},{"name":"fan_action","type":"uint32"},{"name":"light_action","type":"uint32"}],"name":"addRecord","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"get_valueCount","outputs":[{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"index","type":"uint32"}],"name":"getValue","outputs":[{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"},{"name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"}]') 

web3.eth.defaultAccount = web3.eth.accounts[0] 

contract = web3.eth.contract(address = address, abi = abi) 

tx_hash = contract.constructor().transact()
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
#print(contract.functions.getValue(0).call()) 

#Code for DHT11--------- 
Temperature_and_humidity_sensor_id = 222
sensor = Adafruit_DHT.DHT11 
pin = 27 

humidity, temperature = Adafruit_DHT.read_retry(sensor, pin) 
temperature_value = int(temperature) 
humidity_value = int(humidity)
#----------------------- 

#Code for Luminosty-------
Luminosity_sensor_id = 333
bus = smbus2.SMBus(1)

bus.write_byte_data(0x39, 0x00 | 0x80, 0x03)
bus.write_byte_data(57, 1 | 128, 2)

time.sleep(0.5)

data = bus.read_i2c_block_data(0x39, 0x0C | 0x80, 2)
data1 = bus.read_i2c_block_data(0x39, 0x0E | 0x80, 2)

ch0 = data[1] * 256 + data[0]
ch1 = data1[1] * 256 + data1[0]

luminosity_value = ch0 - ch1
#-------------------------

#Code for PIR-------------
PIR_sensor_id = 111
PIR = 24
pir_value = GPIO.input(PIR)

#-------------------------

#Lamp and Fan action-----------
Lamp_action = 1
Fan_action = 1

#-------------------------------

tx_hash = contract.functions.addRecord(int(time.time()),
                                            PIR_sensor_id, pir_value,
                                            Temperature_and_humidity_sensor_id, temperature_value, humidity_value,
                                            Luminosity_sensor_id, luminosity_value,
                                            Lamp_action, Fan_action).transact() 
tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
count = contract.functions.get_valueCount().call() 
print(contract.functions.getValue(count-1).call()) 

print("Printing all values in the array") 

for i in range (count): 
	print("Value {}: {}".format(i+1, contract.functions.getValue(i).call()))

