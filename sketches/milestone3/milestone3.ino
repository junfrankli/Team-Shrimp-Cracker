#include <Servo.h>

// leds
#define led0pin 3
#define led1pin 2
#define led2pin 12
#define led3pin 13

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
#define forwardFull 1000
#define forwardAlmost 700
#define forwardMed 600
#define forwardSlow 530
#define uwot 500

// line sensor threshold
#define threshold 500

int sensor0, sensor1, sensor2, sensor3, sensorBack, state = 0;
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
  sensor0 = ((analogRead(A0) < threshold) ? 0 : 1);
  sensor1 = ((analogRead(A1) < threshold) ? 0 : 1);
  sensor2 = ((analogRead(A2) < threshold) ? 0 : 1);
  sensor3 = ((analogRead(A3) < threshold) ? 0 : 1);
  sensorBack = ((analogRead(A4) < threshold) ? 0 : 1);

  state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;


  // write LEDs
  digitalWrite(led0pin, sensor0);
  digitalWrite(led1pin, sensor1);
  digitalWrite(led2pin, sensor2);
  digitalWrite(led3pin, sensor3);
  //  turnLeft();
  //  delay(1000);
  //  turnRight();
  //  delay(1000);
  if (sensorBack) {
    turnRight();
  } else {

    driveForward();
  }

  //Serial.println(state);
  delay(1);
}

// takes value between 0 and 1000, 500 is middle
void writeR(int s) {
  right.writeMicroseconds(2000 - s);
}
void writeL(int s) {
  left.writeMicroseconds(1000 + s);
}


void turnRight() {
  writeL(1000);
  writeR(0);
  delay(500);
}

void turnLeft() {
  writeL(0);
  writeR(1000);
  delay(500);
}

void driveForward() {
  switch (state) {
    case 0000:
    // ur fukt
    case 1:
      // hardest right
      writeL(forwardFull);
      writeL(forwardSlow);
    case 1000:
      // hardest left
      writeL(forwardSlow);
      writeR(forwardFull);
      break;
    case 11:
      // hard right
      writeL(forwardFull);
      writeR(forwardMed);
      break;
    case 1100:
      // hard left
      writeL(forwardMed);
      writeR(forwardFull);
      break;
    case 10:
      // slight right
      writeL(forwardFull);
      writeR(forwardAlmost);
      break;
    case 100:
      // slight left
      writeL(forwardAlmost);
      writeR(forwardFull);
      break;
    case 110:
      // go straight
      writeL(forwardFull);
      writeR(forwardFull);
      break;
      //    case 1111:
      //      turnRight();
      //      break;
  }
}
