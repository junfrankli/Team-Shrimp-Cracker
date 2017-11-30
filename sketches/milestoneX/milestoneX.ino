/* This example shows how to use continuous mode to take
  range measurements with the VL53L0X. It is based on
  vl53l0x_ContinuousRanging_Example.c from the VL53L0X API.

  The range readings are in units of mm. */

#include <Wire.h>
#include <VL53L0X.h>
#include <DRV8835MotorShield.h>
#include <QTRSensors.h>
#include <SPI.h>
//#include "nRF24L01.h"
//#include "RF24.h"

// Distance Sensors
#define XSHUT_pinA 6
#define XSHUT_pinB 0
#define sensorA_newAddress 42
#define sensorB_newAddress 43
VL53L0X sensorA, sensorB, sensorC;

// Line Sensors
#define NUM_SENSORS   4     // number of line sensors used
#define TIMEOUT       2500  // waits for 2500 microseconds for sensor outputs to go low
#define EMITTER_PIN   QTR_NO_EMITTER_PIN     // emitter is controlled by digital pin 2, jk not
#define THRESHOLD 500   // line sensor threshold
QTRSensorsRC qtrrc((unsigned char[]) {
  5, 4, 3, 2
},
NUM_SENSORS, TIMEOUT, EMITTER_PIN);
unsigned int sensorValues[NUM_SENSORS];


// Motor driver
DRV8835MotorShield motors;
unsigned short speed = 200;
// uses pins 10, 9, 8, 7
// motor PWM values
//#define forwardFull 1000
//#define forwardAlmost 750
//#define forwardMed 500
//#define forwardSlow 250
//#define uwot 0

#define forwardFull 200
#define forwardAlmost 180
#define forwardMed 150
#define forwardSlow 80
#define uwot 0

// global variables
int distLeft, distRight, distCenter, state;


void setup()
{
  Wire.begin();

  pinMode(XSHUT_pinA, OUTPUT);
  pinMode(XSHUT_pinB, OUTPUT);

  sensorA.setAddress(sensorA_newAddress);
  pinMode(XSHUT_pinA, INPUT);
  delay(10);
  sensorB.setAddress(sensorB_newAddress);
  pinMode(XSHUT_pinB, INPUT);
  delay(10);

  Serial.begin(115200);
  // wait 2 seconds
  delay(2000);

  sensorA.init();
  sensorB.init();
  sensorC.init();

  sensorA.setTimeout(500);
  sensorB.setTimeout(500);
  sensorC.setTimeout(500);

  sensorA.startContinuous();
  sensorB.startContinuous();
  sensorC.startContinuous();

  // Motors
  motors.flipM1(true);
  // use motors with motors.setSpeeds(rightSpeed, leftSpeed);
}

void loop()
{
  // read line sensors
  qtrrc.read(sensorValues);
  state = (sensorValues[0] > THRESHOLD) + 10 * (sensorValues[1] > THRESHOLD) + 100 * (sensorValues[2] > THRESHOLD) + 1000 * (sensorValues[3] > THRESHOLD);

  // read distance sensors
  distLeft = sensorB.readRangeContinuousMillimeters();
  distRight = sensorA.readRangeContinuousMillimeters();
  distCenter = sensorC.readRangeContinuousMillimeters();

  //  Serial.print("Left: ");
  //  Serial.print(distLeft);
  //  Serial.print("\t Center: ");
  //  Serial.print(distCenter);
  //  Serial.print("\t Right: ");
  //  Serial.print(distRight);
  //  Serial.print("\t   lineState: ");
  //  Serial.print(state);
  //  Serial.println();
  for (char i = 3; i >= 0; i--) {
    Serial.print(sensorValues[i]);
    Serial.print("\t");
  }
  Serial.println();

  //driveForward();
}

void turnRight() {
  motors.setSpeeds(speed, -speed);
  delay(500);
}

void turnLeft() {
  motors.setSpeeds(-speed, speed);
  delay(500);
}

void driveForward() {
  switch (state) {
    case 0000:
    // ur fukt
    case 1:
      // hardest right
      motors.setSpeeds(forwardSlow, forwardFull);
    case 1000:
      // hardest left
      motors.setSpeeds(forwardFull, forwardSlow);
      break;
    case 11:
      // hard right
      motors.setSpeeds(forwardMed, forwardFull);
      break;
    case 1100:
      // hard left
      motors.setSpeeds(forwardFull, forwardMed);
      break;
    case 10:
      // slight right
      motors.setSpeeds(forwardAlmost, forwardFull);
      break;
    case 100:
      // slight left
      motors.setSpeeds(forwardFull, forwardAlmost);
      break;
    case 110:
      // go straight
      motors.setSpeeds(forwardFull, forwardFull);
      break;
      //    case 1111:
      //      turnRight();
      //      break;
  }
}
