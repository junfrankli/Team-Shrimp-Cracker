/* This example shows how to use continuous mode to take
  range measurements with the VL53L0X. It is based on
  vl53l0x_ContinuousRanging_Example.c from the VL53L0X API.

  The range readings are in units of mm. */

#include <Wire.h>
#include <VL53L0X.h>
#include <DRV8835MotorShield.h>
#include <QTRSensors.h>

// Distance Sensors
#define XSHUT_pinRight 11
#define XSHUT_pinLeft 12
#define XSHUT_pinCenter 13
// default VL53L0x address 41
#define SensorLeft_newAddress 42
#define SensorRight_newAddress 43
VL53L0X sensorLeft, sensorRight, sensorCenter;

// Line Sensors
#define NUM_SENSORS   6     // number of line sensors used
#define TIMEOUT       2500  // waits for 2500 microseconds for sensor outputs to go low
#define EMITTER_PIN   QTR_NO_EMITTER_PIN     // emitter is controlled by digital pin 2, jk not
// sensors 0 through 7 are connected to digital pins 3 through 10, respectively
QTRSensorsRC qtrrc((unsigned char[]) {
  A5, A4, 2, 3, 4, 5,
},
NUM_SENSORS, TIMEOUT, EMITTER_PIN);
unsigned int sensorValues[NUM_SENSORS];


// Motor driver
DRV8835MotorShield motors;
unsigned short speed = 400;
// uses pins 10, 9, 8, 7, 6


void setup()
{
  Serial.begin(9600);
  Wire.begin();

  pinMode(XSHUT_pinLeft, OUTPUT);
  pinMode(XSHUT_pinRight, OUTPUT);
  pinMode(XSHUT_pinCenter, OUTPUT);

  sensorLeft.setAddress(SensorLeft_newAddress);
  pinMode(XSHUT_pinLeft, INPUT);
  delay(10);
  sensorRight.setAddress(SensorRight_newAddress);
  pinMode(XSHUT_pinRight, INPUT);
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


  // Motors
  motors.flipM2(true);
}

void loop()
{
  qtrrc.read(sensorValues);
  // print the sensor values as numbers from 0 to 2500, where 0 means maximum reflectance
  for (unsigned char i = 0; i < NUM_SENSORS; i++)
  {
    Serial.print(sensorValues[i]);
    Serial.print('\t');
  }

  Serial.print(sensorLeft.readRangeContinuousMillimeters());
  Serial.print(",");              //seperator
  Serial.print(sensorCenter.readRangeContinuousMillimeters());
  Serial.print(",");              //seperator
  Serial.println(sensorRight.readRangeContinuousMillimeters());

  //motors.setM1Speed(speed);
  //motors.setM2Speed(speed);
  //void setSpeeds(int m1Speed, int m2Speed)
}
