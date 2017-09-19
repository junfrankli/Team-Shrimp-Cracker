#include <Servo.h>

Servo left;
Servo right;

int thr = 500, state;

void setup() {
  left.attach(9);
  right.attach(10);

}

void loop() {
  state = 0;
  state += ((analogRead(A0) > 500) ? 0 : 1000);
  state += ((analogRead(A1) > 500) ? 0 : 100);
  state += ((analogRead(A2) > 500) ? 0 : 10);
  state += ((analogRead(A3) > 500) ? 0 : 1);

  switch(state) {
    case 0000:
      // ur fukt
    case 0001:
      // hardest right
      left.write(90);
      right.write(0);
      break;
    case 1000:
      // hardest left
      left.write(180);
      right.write(90);
      break;
    case 0011:
      // hard right
      left.write(100);
      right.write(0);
      break;
    case 1100:
      // hard left
      left.write(90);
      right.write(80);
      break;
    case 0010:
      // slight right
      left.write(95);
      right.write(0);
      break;
    case 0100:
      // slight left
      left.write(90);
      right.write(85);
      break;
    case 0110:
      // go straight
      left.write(180);
      right.write(0);
      break;
    break;
  }
  

}
