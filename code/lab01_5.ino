#include <Servo.h>

Servo servoLeft;
Servo servoRight;

void setup() { 
  servoLeft.attach(11);
  servoRight.attach(10);
} 

void loop() {            // Loop through motion tests
 moveForward();
 delay(1000);
 turnRight();
}

// Motion routines for forward, reverse, turns, and stop
void moveForward() {
  servoLeft.write(180);
  servoRight.write(0);
}

void moveBackwards() {
  servoLeft.write(0);
  servoRight.write(180);
}

void turnLeft() {
  servoLeft.write(180);
  servoRight.write(180);
  delay(274);
}
void turnRight() {
  servoLeft.write(0);
  servoRight.write(0);
  delay(274);
}

void brake() {
  servoLeft.write(90);
  servoRight.write(90);
}
