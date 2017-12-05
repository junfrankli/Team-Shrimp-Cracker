#include <Servo.h>
Servo yep;
void setup() {
}

void loop() {
    yep.attach(11);
    yep.write(0);   // yep.write(X), the integer X here can be 0 to 180. 
                    // If X is 90, the servo will stop. If X is 0 or 180, 
                    // it will rotate at full speed but in different directions for 0 and 180.
}
