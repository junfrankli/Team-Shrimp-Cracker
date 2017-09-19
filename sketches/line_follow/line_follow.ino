#include <Servo.h>

Servo servoLeft;
Servo servoRight;

int thr = 500;

String state;


void setup() {
  servoLeft.attach(9);
  servoRight.attach(10);

}

void loop() {
  state = "";
  state += (analogRead(A0) > 500) ? 0 : 1);
  state += (analogRead(A1) > 500) ? 0 : 1);
  state += (analogRead(A2) > 500) ? 0 : 1);
  state += (analogRead(A3) > 500) ? 0 : 1);

  

}
