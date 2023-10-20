#include <ArduinoBLE.h>

BLEService ultrasonicService("19B10000-E8F2-537E-4F6C-D104768A1214");
BLEFloatCharacteristic distanceCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify);

const int trigPin = 8;
const int echoPin = 9;

void setup() {
  Serial.begin(9600); // Initialize Serial Monitor for debugging

  if (!BLE.begin()) {
    while (1);
  }

  BLE.setLocalName("UltrasonicSensor");
  BLE.setAdvertisedService(ultrasonicService);
  ultrasonicService.addCharacteristic(distanceCharacteristic);
  BLE.addService(ultrasonicService);
  distanceCharacteristic.setValue(0);

  BLE.advertise();

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop() {
  long duration, cm;

  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  duration = pulseIn(echoPin, HIGH);
  cm = duration / 29 / 2; // Calculate distance in centimeters

  Serial.print(cm);
  Serial.println(" cm");

  distanceCharacteristic.setValue(cm);
  BLE.poll();

  if (BLE.connected()) {
    Serial.println("Connection Successful"); // Output "Connection Successful" to Serial Monitor
  }

  delay(1000);
}
