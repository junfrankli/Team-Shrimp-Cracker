#include <Servo.h>

#define led0pin 3
#define led1pin 2
#define led2pin 12
#define led3pin 13

// line sensors
#define sensor0pin 7
#define sensor1pin 6
#define sensor2pin 5
#define sensor3pin 4
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

  //setup for sensor pins
  pinMode(sensor0pin, INPUT); 
  pinMode(sensor1pin, INPUT); 
  pinMode(sensor2pin, INPUT); 
  pinMode(sensor3pin, INPUT);

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
  if (!detectWall(3))
    frontier = push(frontier, 1, 0); 
  if (!detectWall(0)) 
    frontier = push(frontier, 0, 1);
  
  //DFS 
  while (frontier != NULL) {
    SQUARE* frontier_loc = pop(&frontier);
    int dir = moveAdjacent(curX, curY, heading, frontier_loc->xPos, frontier_loc->yPos);
    if (dir == -1) {
      //need to backtrack
      //pop from current path
      SQUARE *next = pop(&path);
      
      //move along current path
      int dir = moveAdjacent(curX, curY, heading, next->xPos, next->yPos);
          
      //update state
      if (dir == 0) 
        curY = curY + 1;
      else if (dir == 1)
        curX = curX - 1;
      else if (dir == 2)
        curY = curY - 1;
      else if (dir == 3)
        curX = curX + 1;

      if (dir != -1)
        heading = dir;
        
      //push frontier_loc back
      frontier = frontier_loc;
      
      //free memory
      free(next);
    } else {
      //update current position and heading

      //add current position to current path
      path = push(path, curX, curY);
      
      heading = dir;
      if (heading == 0)
        curY = curY + 1;
      else if (heading == 1)
        curX = curX - 1;
      else if (heading == 2)
        curY = curY - 1;
      else if (heading == 3)
        curX = curX + 1;
      
      //add current position to visited
      visited = push(visited, curX, curY);
      
      //detect possible places to go -- if not in visited add to frontier
      int goalX;
      int goalY;
      if (!detectWall(3)) {
        switch(heading) {
          case 0:
            goalX = curX+1;
            goalY = curY;
            break;
          case 1:
            goalX = curX;
            goalY = curY+1;
            break;
          case 2:
            goalX = curX-1;
            goalY = curY;
            break;
          case 3:
            goalX = curX;
            goalY = curY-1;
            break;
        }
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) {  
          frontier = push(frontier, goalX, goalY);
          Serial.println("adding to frontier");
          Serial.println("direction 3");
          Serial.println(goalX);
          Serial.println(goalY);
        }
      }
      if (!detectWall(2)){
        switch(heading) {
          case 0:
            goalX = curX;
            goalY = curY-1;
            break;
          case 1:
            goalX = curX+1;
            goalY = curY;
            break;
          case 2:
            goalX = curX;
            goalY = curY+1;
            break;
          case 3:
            goalX = curX-1;
            goalY = curY;
            break;
        }
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) {
          frontier = push(frontier, goalX, goalY);
          Serial.println("adding to frontier");
          Serial.println("direction 2");
          Serial.println(goalX);
          Serial.println(goalY);
        }
      }
      if (!detectWall(1)) {
        switch(heading) {
          case 0:
            goalX = curX-1;
            goalY = curY;
            break;
          case 1:
            goalX = curX;
            goalY = curY-1;
            break;
          case 2:
            goalX = curX+1;
            goalY = curY;
            break;
          case 3:
            goalX = curX;
            goalY = curY+1;
            break;
        }
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)){
          frontier = push(frontier, goalX, goalY);
          Serial.println("adding to frontier");
          Serial.println("direction 1");
          Serial.println(goalX);
          Serial.println(goalY);
        }
        
      }
      if (!detectWall(0)) {
        switch(heading) {
          case 0:
            goalX = curX;
            goalY = curY+1;
            break;
          case 1:
            goalX = curX-1;
            goalY = curY;
            break;
          case 2:
            goalX = curX;
            goalY = curY-1;
            break;
          case 3:
            goalX = curX+1;
            goalY = curY;
            break;
        }
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) {
          frontier = push(frontier, goalX, goalY);
          Serial.println("adding to frontier");
          Serial.println("direction 0");
          Serial.println(goalX);
          Serial.println(goalY);
        }
      } 
      free(frontier_loc);
    }
    delay(100);
  }
  left.write(92);
  right.write(92);
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
      dir = 3;
    else if (distX == -1)
      dir = 1;
  }
  if (dir == -1)
    return dir;

  if (heading != dir) {
    switch (heading) {
      case 0:
        switch (dir) {
          case 1:
            turnLeft();
            break;
          case 2: 
            turnLeft();
            turnLeft();
            break;
          case 3:
            turnRight();
            break;
        }
        break;
      case 1:
        switch (dir) {
          case 0:
            turnRight();
            break;
          case 2: 
            turnLeft();
            break;
          case 3:
            turnRight();
            turnRight();
            break;
        }
        break;
      case 2: 
        switch (dir) {
          case 1:
            turnRight();
            break;
          case 0: 
            turnLeft();
            turnLeft();
            break;
          case 3:
            turnLeft();
            break;
        }
        break;
      case 3:
        switch (dir) {
          case 1:
            turnLeft();
            turnLeft();
            break;
          case 0: 
            turnLeft();
            break;
          case 2:
            turnRight();
            break;
        }
        break;
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

// returns true if there is a wall in the specified direction
// 0 is pos y, 1 is pos x, 2 is neg y, 3 is neg x
bool detectWall(int dir) {
  float sensorValue;
  if (dir == 2) 
    return false;
  int sum = 0;
  if (dir == 1) {
    for (int i = 0; i < 10; i++) 
      sensorValue = sensorValue + analogRead(A2); //read from left sensor
    if (sensorValue > (220*10)) return true;
    else return false;
  } else {
    if (dir == 0) {
      for (int i = 0; i < 10; i++)
        sensorValue = sensorValue + analogRead(A5); //read from front sensor
      if (sensorValue > (220*10)) return true;
      else return false;
    }
    else {
      for (int i = 0; i < 10; i++)
        sensorValue = sensorValue + analogRead(A3); //read from right sensor
      if (sensorValue > (250*10)) return true;
      else return false;
    }
    
   }
}

void goForwardOneSquare() {
  int sensor0 = digitalRead(sensor0pin);
  int sensor1 = digitalRead(sensor1pin);
  int sensor2 = digitalRead(sensor2pin);
  int sensor3 = digitalRead(sensor3pin);
  int state = 1111;
  while (state == 1111) {
    sensor0 = digitalRead(sensor0pin);
    sensor1 = digitalRead(sensor1pin);
    sensor2 = digitalRead(sensor2pin);
    sensor3 = digitalRead(sensor3pin);
    state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;
    lineFollow(state);
  }
  while (state != 1111) {
    sensor0 = digitalRead(sensor0pin);
    sensor1 = digitalRead(sensor1pin);
    sensor2 = digitalRead(sensor2pin);
    sensor3 = digitalRead(sensor3pin);
    state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;
    lineFollow(state);
  } 
  //left.write(92);
  //right.write(92);
}

void lineFollow(int state) {
  switch (state) {
    case 0110:
      writeL(forwardFull);
      writeR(forwardFull);
      break;
    case 0011:
      // slight right
      writeL(forwardFull);
      writeR(forwardAlmost);
      break;
    case 0111:
      // hard right
      writeL(forwardFull);
      writeR(forwardMed);
      break;
    case 1100:
      // slight left
      writeL(forwardAlmost);
      writeR(forwardFull);
      break;
    case 1110:
      // hard left
      writeL(forwardMed);
      writeR(forwardFull);
      break;
    case 1000:
      // hardest left
      writeL(forwardSlow);
      writeR(forwardFull);
      break;
    case 0001:
      //hardest right
      writeL(forwardFull);
      writeL(forwardSlow);
      break;
    default:
      writeL(forwardFull);
      writeR(forwardFull);
      break;
  }
}

void turnRight() {
  writeL(forwardFull);
  right.write(150);
  delay(1000);
  left.write(92);
  right.write(92);
}

void turnLeft() {
  writeR(forwardFull);
  left.write(30);
  delay(1150);
  left.write(92);
  right.write(92);
}

void writeR(int s) {
  right.writeMicroseconds(2000 - s);
}
void writeL(int s) {
  left.writeMicroseconds(1000 + s);
} 

