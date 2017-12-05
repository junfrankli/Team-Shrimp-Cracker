#include <Servo.h>

// leds
#define led0pin 3
#define led1pin 2
#define led2pin 1
#define led3pin 0

// line sensors
#define sensor0pin A0
#define sensor1pin A1
#define sensor2pin A2
#define sensor3pin A3
#define sensorBackPin A4

// servos
#define servoLeft 9
#define servoRight 10
Servo left;
Servo right;

// servo PWM values
#define forward0 550
#define forward1 600
#define forward2 700
#define forward3 800
#define backward 450

// line sensor threshold
#define threshold 500

int sensor0, sensor1, sensor2, sensor3, sensorBack;
//unsigned long startTime, endTime;

void setup() {
  // set up servo pins
  left.attach(servoLeft);
  right.attach(servoRight);

  // set LED pins as output
  pinMode(led0pin, OUTPUT);
  pinMode(led1pin, OUTPUT);
  pinMode(led2pin, OUTPUT);
  pinMode(led3pin, OUTPUT);

  Serial.begin(115200);
}

// main loop
void loop() {
  //record loop start time
  //unsigned long currentMillis = millis();

  // scan sensor states
  sensor0 = ((analogRead(A0) > threshold) ? 0 : 1);
  sensor1 = ((analogRead(A1) > threshold) ? 0 : 1);
  sensor2 = ((analogRead(A2) > threshold) ? 0 : 1);
  sensor3 = ((analogRead(A3) > threshold) ? 0 : 1);
  sensorBack = ((analogRead(A4) > threshold) ? 0 : 1);


  // write LEDs
  digitalWrite(led0pin, sensor0);
  digitalWrite(led1pin, sensor1);
  digitalWrite(led2pin, sensor2);
  digitalWrite(led3pin, sensor3);

  writeR(500);
  writeL(500);

  Serial.println(sensor0 + ' ' + sensor1 + ' ' + sensor2 + ' ' + sensor3);

  delay(1);
}

// takes value between 0 and 1000, 500 is middle
void writeR(int s) {
  right.writeMicroseconds(1000 + s);
}
void writeL(int s) {
  left.writeMicroseconds(2000 - s);
}


void turnRight() {

}

void turnLeft() {


}

void driveForward() {
  int state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;
  switch (state) {
    case 0000:
    // ur fukt
    case 0001:
      // hardest right
      writeL(forward3);
      writeL(forward1);
    case 1000:
      // hardest left
      writeL(forward1);
      writeL(forward3);
      break;
    case 0011:
      // hard right
      writeL(forward3);
      writeL(forward2);
      break;
    case 1100:
      // hard left
      writeL(forward2);
      writeL(forward3);
      break;
    case 0010:
      // slight right
      writeL(forward2);
      writeL(forward1);
      break;
    case 0100:
      // slight left
      writeL(forward1);
      writeL(forward2);
      break;
    case 0110:
      // go straight
      writeL(forward3);
      writeL(forward3);
      break;
      break;
  }
}
