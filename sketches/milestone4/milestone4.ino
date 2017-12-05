#include <DRV8835MotorShield.h>
#include <QTRSensors.h>
#include <VL53L0X.h>
#include <Wire.h>


// MISC
#define LED_PIN 13

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


// Distance Sensors
#define XSHUT_pinRight 11
#define XSHUT_pinLeft 12
#define XSHUT_pinCenter 13
// default VL53L0x address 41
#define SensorLeft_newAddress 42
#define SensorRight_newAddress 43

// Motor driver
DRV8835MotorShield motors;
unsigned short speed = 400;
// uses pins 10, 9, 8, 7, 6



VL53L0X sensorLeft, sensorRight, sensorCenter;

void setup() {
  pinMode(XSHUT_pinLeft, OUTPUT);
  pinMode(XSHUT_pinRight, OUTPUT);
  pinMode(XSHUT_pinCenter, OUTPUT);

  Serial.begin(9600);
  Wire.begin();

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

  pinMode(LED_PIN, OUTPUT);

  // uncomment one or both of the following lines if your motors' directions need to be flipped
  //motors.flipM1(true);
  motors.flipM2(true);

}

void loop() {
  qtrrc.read(sensorValues);

  // print the sensor values as numbers from 0 to 2500, where 0 means maximum reflectance
  for (unsigned char i = 0; i < NUM_SENSORS; i++)
  {
    Serial.print(sensorValues[i]);
    Serial.print('\t');
  }

  motors.setM1Speed(speed);
  motors.setM2Speed(speed);
  //void setSpeeds(int m1Speed, int m2Speed)

  Serial.print(sensorLeft.readRangeContinuousMillimeters());
  if (sensorLeft.timeoutOccurred()) {
    Serial.print(" TIMEOUT");
  }

  Serial.println();

  delay(250);
}
