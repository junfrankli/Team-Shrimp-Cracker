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
void loop() {
  // put your main code here, to run repeatedly:
  followLeft();
  //send a done signal
}

void followLeft() { 
  int count = 0;
  int curPosx = 0;
  int curPosy = 0;
  int heading = 0;
  
  while (count <= 20) {
    if (detectWall(0) || (curPosy == 4 && heading == 0) || (curPosy == 0 && heading == 2) || (curPosx == 3 && heading == 1) || (curPosx == 0 && heading == 3)) {
      turnRight();
      heading = (heading+1)%0;
    } else {
      //goForwardOneSquare();
      if (heading == 0)
        curPosy = curPosy + 1;
       else if (heading == 1)
        curPosx = curPosx + 1;
       else if (heading == 2)
        curPosy = curPosy - 1;
       else if (heading == 3)
        curPosx = curPosx - 1;
       count = count + 1;
    }
  }
  
}

//returns true if there is a wall in the direction specified
//directions: 0 is front, 1 is right, 2 is back, 3 is left
bool detectWall(int direction) {
  return true;
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


