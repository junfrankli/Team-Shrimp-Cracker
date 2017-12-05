/* This example shows how to use continuous mode to take
  range measurements with the VL53L0X. It is based on
  vl53l0x_ContinuousRanging_Example.c from the VL53L0X API.

  The range readings are in units of mm. */

#include <Wire.h>
#include <VL53L0X.h>

// Distance Sensors
#define XSHUT_pinLeft 6
#define XSHUT_pinCenter 5
// default VL53L0x address 41
#define SensorLeft_newAddress 42
#define SensorRight_newAddress 43
VL53L0X sensorLeft, sensorRight, sensorCenter;


void setup()
{
  pinMode(XSHUT_pinLeft, OUTPUT);
//  pinMode(XSHUT_pinRight, OUTPUT);
  pinMode(XSHUT_pinCenter, OUTPUT);

delay(2000);
  Serial.begin(9600);
  Wire.begin();

  sensorLeft.setAddress(SensorLeft_newAddress);
  pinMode(XSHUT_pinLeft, INPUT);
  delay(10);
  sensorRight.setAddress(SensorRight_newAddress);
  pinMode(XSHUT_pinCenter, INPUT);
  delay(10);

  sensorLeft.init();
  sensorRight.init();
  sensorCenter.init();

  sensorLeft.setTimeout(500);
  sensorRight.setTimeout(500);
  sensorCenter.setTimeout(500);

  sensorLeft.startContinuous();
  sensorRight.startContinuous();
  sensorCenter.startContinuous();
}

void loop()
{
  Serial.println(sensorLeft.readRangeContinuousMillimeters());
  Serial.print(",");              //seperator
  Serial.print(sensorCenter.readRangeContinuousMillimeters());
  Serial.print(",");              //seperator
  Serial.println(sensorRight.readRangeContinuousMillimeters());
}
