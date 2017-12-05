#include <Servo.h>

Servo servoLeft;
Servo servoRight;

int threshhold = 500;
int ticker = 0;
void setup() { 
  servoLeft.attach(9);
  servoRight.attach(10);
  delay(1000);
} 

void loop() {            // Loop through motion tests
  int frontLeftSensor = analogRead(A3);
  int frontRightSensor = analogRead(A0);
  if ((frontLeftSensor > threshhold) && (frontRightSensor > threshhold) && (ticker != 0)) {
    turnRight();
    delay(600);
    ticker = ticker + 1;
  }
  else if ((frontRightSensor > threshhold) && (frontRightSensor > threshhold) && (ticker = 0)){
    moveForward();
    delay(100);
  }
  else if ((frontRightSensor > threshhold) && (frontLeftSensor < threshhold)) {
    turnRight();
  }
  else if ((frontRightSensor < threshhold) && (frontLeftSensor > threshhold)) {
    turnLeft();
  }
  else {
    moveForward();
  }
}

// Motion routines for forward, reverse, turns, and stop
void moveForward() {
  servoLeft.write(180);
  servoRight.write(0);
}

void slightRight() {
  servoLeft.write(0);
  servoRight.write(0);
}

void slightLeft() {
  servoLeft.write(100);
  servoRight.write(70);
}

void moveBackwards() {
  servoLeft.write(0);
  servoRight.write(180);
}

void turnLeft() {
  servoLeft.write(0);
  servoRight.write(0);
}

void turnRight() {
  servoLeft.write(180);
  servoRight.write(180);
}
