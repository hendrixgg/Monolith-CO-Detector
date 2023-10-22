#include <ArduinoBLE.h>

const int trigPin = 9;   // Trigger pin of the ultrasonic sensor
const int echoPin = 10;  // Echo pin of the ultrasonic sensor

BLEService customService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Define a custom Bluetooth service
BLEFloatCharacteristic distanceCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify); // Characteristic for distance

long duration;
float distance_cm;

bool deviceConnected = false;

void setup() {
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  if (!BLE.begin()) {
    Serial.println("Starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("UltrasonicSensor");
  BLE.setAdvertisedService(customService);
  customService.addCharacteristic(distanceCharacteristic);
  BLE.addService(customService);

  distanceCharacteristic.writeValue(0);

  BLE.advertise();
  Serial.println("Bluetooth device is now advertising. Scan for 'UltrasonicSensor' on your device to connect.");
}

void loop() {
  // Check if a Bluetooth device is connected
  if (BLE.connected() && !deviceConnected) {
    deviceConnected = true;
    Serial.println("Device connected");
  } else if (!BLE.connected() && deviceConnected) {
    deviceConnected = false;
    Serial.println("Device disconnected");
  }

  // Ultrasonic sensor code
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance_cm = duration * 0.034 / 2;

  // Update the Bluetooth characteristic with the distance value
  distanceCharacteristic.writeValue(distance_cm);

  // Print the distance to the Serial Monitor
  Serial.print("Distance: ");
  Serial.print(distance_cm);
  Serial.println(" cm");

  // Wait for a while before sending the next distance update
  delay(1000);
}

