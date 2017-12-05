#include <Servo.h>

Servo servoLeft;
Servo servoRight;

int threshhold = 500;

void setup() { 
  servoLeft.attach(9);
  servoRight.attach(10); 
} 

void loop() {            // Loop through motion tests
  int frontLeftSensor = analogRead(A3);
  int frontRightSensor = analogRead(A0);

  if (frontLeftSensor > threshhold) {
    turnLeft();
  }
  else if (frontRightSensor > threshhold){
    turnRight();
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
