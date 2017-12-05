# Milestone 1

## Objective
The purpose of this milestone was to add line following to our robot, through adding sensors and fine-tuning our servos. Our robot was able to follow a straight line and a figure-eight pattern.



## Sensor Setup
We attached two sensors to the front of the robot, wide enough to lay outside of the line of tape - one sensor to the left and one to the right. If only one sensor detected a black line, we would know the robot had turned too far to one side and that we would have to correct the course. If both sensors detected a black line, we would know we were at an intersection.

![Sensors Setup](https://i.imgur.com/NQ6bNpSm.jpg)

## Following a line
In order to follow a line, we read from the sensors and checked to see if a sensor was above the threshold value. We then used a series of conditional statements to determine whether we should keep going forward or correct by turning to the left or right.

The following video shows our robot following a line:

[![Line Following Robot](https://i.imgur.com/zWBnX05.png)](https://drive.google.com/file/d/0B9RjcO6lwSovQThkWTNoVTdEejQ/view?usp=sharing)

## Figure Eight
In order to have our robot follow a figure eight, we modified our previous code in order to ignore an intersection. An intersection was detected when both of the sensors crossed their threshold. The following video shows our robot in action:

[![Figure-Eight](https://i.imgur.com/1K9o4ZJ.jpg)](https://drive.google.com/file/d/0B8bwFN4zRmfVYTFiQVRUZHBuaUU/view)



The following code was used for the line following:
```C++
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




```
As we can see by the code, the robot makes adjustments base on what sensor detects a black line past a certain threshold that was determined through serial read outs. 

The figure eight code was as follows:
```C++
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
```
We thought that a robot truly following a curve would show more an understanding of line following rather than hardcoding the robot to follow a grid style figure eight. 

### Looking Ahead
For our final robot design, we plan to change how our sensors are setup and implement a FSM that controls how our robot moves since we will have omni wheels that can move in any direction. The reason for this digression from normal line following robots is that omni wheel builds traverse grids quicker and the movement pattern is easier to implement. We also plan on implementing a PID style algorithm to make finer adjustments as well as include a sensor at the center of the robot to indicate the start of a turn. This will make line following exceptionally smooth. 

