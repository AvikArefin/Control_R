#include <Arduino.h>
#include <BluetoothSerial.h>
#include "motor.h"

Motor motor;

BluetoothSerial SerialBT;

void setup()
{
  SerialBT.begin("Group 3 Project"); // Bluetooth device name
  Serial.begin(115200);
  Serial.println("The device started, now you can pair it with bluetooth!");
}

float speed = 0.0;
String message;
void loop()
{
  message = "";
  if (SerialBT.available() > 0)
  {
    message = SerialBT.readStringUntil('\n');
    // Serial.println(message);
  }
  if (message != "")
  {
    speed = message.toFloat();
    if (speed >= -2.0 && speed <= 2.0) {
    	motor.stop();
    }
    else if (speed > 2.0 && speed <= 255.0)
    {
      motor.forward(speed);
    }
    else if (speed >= -255.0 && speed < 2.0) {
      motor.backward(-speed);
    }
  }
  // motor.forward(255);
}