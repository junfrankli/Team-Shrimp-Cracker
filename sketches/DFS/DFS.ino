#include <Servo.h>

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

typedef struct square {
  int xPos;
  int yPos;
  struct square *next;
} SQUARE;

int moveAdjacent(int, int, int, int, int);
bool detectPath(int, int, int);
bool findsquare(SQUARE *, int, int);
SQUARE * push (SQUARE *, int, int);
SQUARE * pop (SQUARE **);

void setup() {
  // put your setup code here, to run once:
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

  // initialization of state variables
  SQUARE *visited = NULL;
  SQUARE *frontier = NULL;
  SQUARE *path = NULL;
  int curX = 0;
  int curY = 0;
  int heading = 0;
  
  visited = push(visited, 0, 0);
  path = push(path, 0, 0);
  if (!detectWall(0)) 
    frontier = push(frontier, 0, 1);
  if (!detectWall(1))
    frontier = push(frontier, 1, 0); 

  
  //DFS 
  while (frontier != NULL) {
    SQUARE* frontier_loc = pop(&frontier);
    int dir = moveAdjacent(curX, curY, heading, frontier_loc->xPos, frontier_loc->yPos);
    if (dir == -1) {
      //need to backtrack
      //pop from current path
      SQUARE *next = pop(&path);
      
      //move along current path
      heading = moveAdjacent(curX, curY, heading, next->xPos, next->yPos);
          
      //update state
      if (heading == 0)
        curY = curY + 1;
      else if (heading == 1)
        curX = curX + 1;
      else if (heading == 2)
        curY = curY - 1;
      else if (heading == 3)
        curX = curX - 1;
      
      //push frontier_loc back
      frontier = frontier_loc;
      
      //free memory
      free(next);
    } else {
      //update current position and heading
      heading = dir;
      if (heading == 0)
        curY = curY + 1;
      else if (heading == 1)
        curX = curX + 1;
      else if (heading == 2)
        curY = curY - 1;
      else if (heading == 3)
        curX = curX - 1;
      
      //add current position to current path
      path = push(path, curX, curY);
      
      //add current position to visited
      visited = push(visited, curX, curY);
      
      //detect possible places to go -- if not in visited add to frontier
      if (!detectWall(0)) {
        if (!findsquare(visited, curX, curY+1))
          frontier = push(frontier, curX, curY+1);
      } 
      if (!detectWall(1)) {
        if (!findsquare(visited, curX+1, curY))
          frontier = push(frontier, curX+1, curY);
      }
      if (!detectWall(2)){
        if (!findsquare(visited, curX, curY-1))
          frontier = push(frontier, curX, curY-1);
      }
      if (!detectWall(3)) {
        if (!findsquare(visited, curX-1, curY))
          frontier = push(frontier, curX-1, curY);
      }
      free(frontier_loc);
    }
    delay(100);
  }
  Serial.println("Done");
  delay(100000);
  //DONE signal
}

//moves robot one square based on current position and heading
//returns heading if robot is able to move to specified square, -1 otherwise
int moveAdjacent(int curX, int curY, int heading, int goalX, int goalY) {
  int distX = goalX - curX;
  int distY = goalY - curY;
  int dir = -1;
  if (distX == 0) {
    if (distY == 1) 
      dir = 0;
    else if (distY == -1)
      dir = 2;
  } else if (distY == 0) {
    if (distX == 1)
      dir = 1;
    else if (distX == -1)
      dir = 3;
  }
  if (dir == -1)
    return dir;

  while (heading != dir) {
    if (heading > dir) {
      Serial.println("Trying to turn left");
      Serial.println(heading);
      Serial.println(dir);
      //turnLeft();
      heading = heading - 1;
    } else {
      Serial.println("Trying to turn right");
      Serial.println(heading);
      Serial.println(dir);
      //turnRight();
      heading = heading + 1;
    }
  }

  goForwardOneSquare();
  return dir;
}

bool findsquare(SQUARE *head, int x, int y) {
  while (head != NULL) {
    if (head->xPos == x) {
      if (head->yPos == y)
        return true;
    }
    head = head->next;
  }
  return false;
  
}

SQUARE * push (SQUARE *head, int x, int y) {
  SQUARE *node = (SQUARE*) malloc(sizeof(SQUARE));
  node->xPos = x;
  node->yPos = y;
  node->next = head;
  return node;
}

SQUARE * pop (SQUARE **head) {
  SQUARE *node = *head;
  *head = (*head)->next;
  return node;
}


void goForwardOneSquare() {
  Serial.println("Trying to move forward one square.");
  while (sensorBack == 0) {
    driveForward();
    sensor0 = ((analogRead(A0) < threshold) ? 0 : 1);
    sensor1 = ((analogRead(A0) < threshold) ? 0 : 1);
    sensor2 = ((analogRead(A3) < threshold) ? 0 : 1);
    sensor3 = ((analogRead(A3) < threshold) ? 0 : 1);
    sensorBack = ((analogRead(A4) < threshold) ? 0 : 1);
  }
  sensorBack = 0;
  Serial.println("Moved forward one square.");
}

// returns true if there is a wall in the specified direction
// 0 is pos y, 1 is pos x, 2 is neg y, 3 is neg x
bool detectWall(int dir) {
  Serial.println(dir);
  float SensorValue;
  if (dir == 2) 
    return false;
  else if (dir == 0)
    SensorValue = analogRead(A5); // read from forward sensor
  else if (dir == 1)
    SensorValue = analogRead(A2); //read from right sensor
  else 
    SensorValue = analogRead(A1); //read from left sensor
  float dis = 2076/(SensorValue - 11);
  //Serial.println(dis);
  if (dis>3 && dis<15){
    Serial.println("wall");
    return true;
  } else {
    Serial.println("no wall");
    return false;
  }   
}



void driveForward() {
  Serial.println("Driving forward");
  Serial.println(analogRead(A0));
  Serial.println(analogRead(A3));
  sensor0 = ((analogRead(A0) < threshold) ? 0 : 1);
  sensor1 = ((analogRead(A0) < threshold) ? 0 : 1);
  sensor2 = ((analogRead(A3) < threshold) ? 0 : 1);
  sensor3 = ((analogRead(A3) < threshold) ? 0 : 1);
  sensorBack = ((analogRead(A4) < threshold) ? 0 : 1);

  state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;

  digitalWrite(led0pin, sensor0);
  digitalWrite(led1pin, sensor1);
  digitalWrite(led2pin, sensor2);
  digitalWrite(led3pin, sensor3);
  switch (state) {
    case 0000:
      writeL(forwardFull);
      writeR(forwardFull);
      break;
    case 1:
      // hardest right
      writeL(forwardFull);
      writeL(forwardSlow);
      break;
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

void writeR(int s) {
  right.writeMicroseconds(2000 - s);
}
void writeL(int s) {
  left.writeMicroseconds(1000 + s);
} 

