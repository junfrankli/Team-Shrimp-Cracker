
#include <VL53L0X.h>
/* This example shows how to use continuous mode to take
  range measurements with the VL53L0X. It is based on
  vl53l0x_ContinuousRanging_Example.c from the VL53L0X API.

  The range readings are in units of mm. */

#include <Wire.h>
#include <DRV8835MotorShield.h>
#include <QTRSensors.h>
#include <SPI.h>
//#include "nRF24L01.h"
//#include "RF24.h"

// Distance Sensors
#define XSHUT_pinA 6
#define XSHUT_pinB 5
#define sensorA_newAddress 42
#define sensorB_newAddress 43
VL53L0X sensorA, sensorB, sensorC;

// Line Sensors
#define NUM_SENSORS   6     // number of line sensors used
#define TIMEOUT       2500  // waits for 2500 microseconds for sensor outputs to go low
#define EMITTER_PIN   QTR_NO_EMITTER_PIN     // emitter is controlled by digital pin 2, jk not
#define THRESHOLD     1000   // line sensor threshold
QTRSensorsRC qtrrc((unsigned char[]) {
  32, 30, 28, 26, 24, 22
},
NUM_SENSORS, TIMEOUT, EMITTER_PIN);
unsigned int sensorValues[NUM_SENSORS];


// nRF
#define nrf_CE 4
#define nrf_CSN 3


// Motor driver
DRV8835MotorShield motors;
// uses pins 10, 9, 8, 7


// Microphone and IR sensors
#define MIC_PIN
#define IRL_PIN
#define IRR_PIN
#define IRC_PIN

// global variables
int distLeft, distRight, distCenter, pos;
int leftSpeed, rightSpeed, lastPos, integral, power_difference;

char state, numonline, go;


void setup()
{
  Wire.begin();

  pinMode(XSHUT_pinA, OUTPUT);
  digitalWrite(XSHUT_pinA, LOW);
  pinMode(XSHUT_pinB, OUTPUT);
  digitalWrite(XSHUT_pinB, LOW);
  Serial.println("output mode");
  //
  sensorA.setAddress(sensorA_newAddress);
  pinMode(XSHUT_pinA, INPUT);
  delay(10);
  sensorB.setAddress(sensorB_newAddress);
  pinMode(XSHUT_pinB, INPUT);
  delay(10);

  Serial.begin(115200);
  Serial.println("Initializing Serial");
  // wait 2 seconds
  delay(2000);

  Serial.println ("here");
  Serial.println("test");
  sensorA.init();
  Serial.println("test2");
  Serial.println (sensorA.init());
  Serial.println (sensorB.init());
  Serial.println (sensorC.init());
  Serial.println("Init rangesensor");


  sensorA.setTimeout(500);
  sensorB.setTimeout(500);
  sensorC.setTimeout(500);

  sensorA.startContinuous();
  sensorB.startContinuous();
  sensorC.startContinuous();
  Serial.println("Initializing Ranging Sensors");

  // Motors
  motors.flipM1(true);
  motors.flipM2(true);
  // use motors with motors.setSpeeds(rightSpeed, leftSpeed);
}


void loop()
{
  // read line sensors
  qtrrc.read(sensorValues);
  unsigned char i, on_line = 0;
  unsigned long avg; // this is for the weighted total, which is long
  // before division
  unsigned int sum; // this is for the denominator which is <= 64000

  numonline = 0;
  for (i = 0; i < NUM_SENSORS; i++) {
    int value = sensorValues[i];
    // keep track of whether we see the line at all
    if (value > 1000) {
      on_line = 1;
      numonline++;
    }

    // only average in values that are above a noise threshold
    if (value > 50) {
      avg += (long)(value) * (i * 2500);
      sum += value;
    }
  }
  //  if (!on_line)
  //  {
  //    // If it last read to the left of center, return 0.
  //    if (_lastValue < (NUM_SENSORS - 1) * 1000 / 2)
  //      return 0;
  //
  //    // If it last read to the right of center, return the max.
  //    else
  //      return (NUM_SENSORS - 1) * 1000;
  //  }

  // calculate position
  pos = .4 * avg / sum - 2500;

  //  // calc PIDs
  //  int derivative = pos - lastPos;
  //  integral = constrain(integral + pos, -50, 50);
  //  lastPos = pos;
  //
  //  int power_difference = pos / 20 ; // + integral / 10000 + derivative * 1.5;
  //
  //  const int max = 200;
  //  if (power_difference > max)
  //    power_difference = max;
  //  if (power_difference < -max)
  //    power_difference = -max;
  //
  //  if (power_difference < 0) {
  //    //motors.setSpeeds(max + power_difference, max);
  //  }  else {
  //    //motors.setSpeeds(max, max - power_difference);
  //  }

  // read distance sensors
  distLeft = sensorB.readRangeContinuousMillimeters();
  distRight = sensorA.readRangeContinuousMillimeters();
  distCenter = sensorC.readRangeContinuousMillimeters();

  debug();

  if (go < 2) {

    // calc PIDs
    int derivative = pos - lastPos;
    integral = constrain(integral + pos, -50, 50);
    lastPos = pos;

    power_difference = pos / 10 + integral / 10000 + derivative * 1.5;

    const int max = 200;
    if (power_difference > max)
      power_difference = max;
    if (power_difference < -max)
      power_difference = -max;
    if (numonline == 6) {
      go++;
    }
    else if (power_difference < 0) {
      motors.setSpeeds(max + power_difference, max);
    }  else {
      motors.setSpeeds(max, max - power_difference);
    }
  } else{
      motors.setSpeeds(0, 0);
  }

  //  // state machine logic
  //  switch (state) {
  //    case 0:
  //      // waiting for mic tone to start mapping
  //      if (0) {
  //        state++;
  //      }
  //      break;
  //    case 1:
  //      // mapping
  //
  //      break;
  //
  //  }
}


// DRIVE FORWARD ONE SQUARE
void forwardOne() {

  // calc PIDs
  int derivative = pos - lastPos;
  integral = constrain(integral + pos, -50, 50);
  lastPos = pos;

  power_difference = pos / 10 + integral / 10000 + derivative * 1.5;

  const int max = 100;
  if (power_difference > max)
    power_difference = max;
  if (power_difference < -max)
    power_difference = -max;
  if (numonline == 6) {
    motors.setSpeeds(0, 0);
    go++;
  }
  else if (power_difference < 0) {
    motors.setSpeeds(max + power_difference, max);
  }  else {
    motors.setSpeeds(max, max - power_difference);
  }
}

// DEUGGING PRINT STATEMENTS
void debug() {
  Serial.print("L: ");
  Serial.print(distLeft);
  Serial.print("\t C: ");
  Serial.print(distCenter);
  Serial.print("\t R: ");
  Serial.print(distRight);
  Serial.print("\t   LINE: ");
  for (char i = 5; i >= 0; i--) {
    Serial.print(sensorValues[i]);
    Serial.print("  ");
  }
  Serial.print("\t   POS: ");
  Serial.print(pos);
  Serial.print("\t   OUT: ");
  Serial.print(power_difference);
  Serial.println();
}
