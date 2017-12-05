# Milestone 3
## Objective
The purpose of this milestone is to implement a working maze mapping algorithm in both the robot and in simulation. 

## Maze Simulation
First, the simulation team had to decide on different search algorithms to map the maze. Many were considered but only one was eventually implemented. We considered algorithms such as DFS, BFS, A* algorithm, and a simple wall following algorithm. Each had various pros and cons that needed to be considered. 

### DFS
DFS, also known as depth-first-search, is an extremely well known algorithm based on a fairly simple premise. Without loss of generality, an arbitrary maze mapping can be represented by a tree structure. The algorithm tries to reach the deepest depths of the tree before backtracking and going down another branch. The advantage of this method is that we rarely need to turn, if implemented such that the first child that we try to visit is straight ahead. Another advantage of using DFS is that there is already a lot of existing documentation in code. Many languages already have implementations of the algorithm in their main library. Finally, the last consideration is its time and space complexity; Because of the nature of the maze being 4 by 5 squares, the depth of the maze never reaches unresonable bounds. In fact, space complexity of this algorithm is very low, being O(20) at most. 

### BFS
BFS - breadth-first-search - also shares many of the same advantages as DFS. In fact, the only real difference between the two algorithms is the method in which they traverse the maze. The way BFS works is that it first travels to each of the nodes' child before going down in depth. Other than that, BFS shares the same space and time complexity. The main difficulty is  in the context of the robot: the children of a tile are all the adjacent reachable tiles. Unfortunaly, this would mean that the robot would need to backtrack after almost all movement onto the frontier. The robot is limited in its turning speed which makes this algorithm worse in our specific context. 

### Left Wall-Following
As a simple wall-following algorithm is extremely simple, it is efficient and uses the least memory space. It works on the assumption that the maze has no corridors of more than two squares wide. The robot essentially hugs the wall and moves with the wall always on the left. In fairly simple maze layouts, this algorithm maps out mazes perfectly in the fastest way possible. Unfortunately, the algorithm fails in many other layouts. 

### Weapon Of Choice
We ultimately decided to implement DFS. DFS over BFS seemed like easy choice given our applications and DFS is easily more versatile than left wall-following. 

The actual implementation of the algorithm was fairly simple. Many different languages can easily implement the algorithm. The graphics, however, can be tricky. We chose Java because, well, it really the only language that I'm familiar with implementing graphics. I personally hate graphics, and I have to admit that the graphics part was extremely soul sucking but I digress. 
In order to keep track of the different node sets, we need two different data structures - one for the visited set of nodes and one for the frontier set of nodes. The easiest and most common way to keep track of the visited set is a simple stack. Conveniently, the stack data structure is already implemented, called a Deque. 
The second data structure needs to be a set to keep track of frontier nodes. A data structure well suited for this task is just a HashSet. The beauty of a HashSet is that you can check and take an element from the set in constant time. This, of course, assumes that the degenerate case of set conflict does not occur, which is rare. 
The idea is that every time we visit a new node, we push that node onto the stack. We then visit its neighbors in the frontier set. If it has no neighbors in the frontier set, then we pop the node and try again with the next element in the stack. The node at the top of the visited stack denotes where the robot is currently. The high level implementation is show below.

```Java
while (!frontierSet.isEmpty()){
			updateJFrame();
			Maze[currPos[0]][currPos[1]] = 2;
			visit();
			ArrayList<int[]> reachableCells = frontier();
			addFrontier(reachableCells);
			updateVisited(reachableCells);
			Thread.sleep(200);
			if (!frontierSet.isEmpty()){
				updateJFrame();
			}
		}
```

This is the general algorithm. We ask the algorithm to pause so that the simulation does not go as fast. Finally, once this algorithm stops, we set the main function to pause before closing the window to indicate that the algorithm is done mapping the maze. This of course shows that the DFS algorithm does indeed terminate and does not loop indefinitely. 
```Java
displayMaze();
Thread.sleep(500);
frame.setVisible(false);
```
This implementation of the simulation also lets the user input different maze configuration. The way we keep track of different maze configurations is just through a simple array. Each maze is essentially an 2-D array 7 by 9. The reason for this is to keep track of walls in between actual grid spaces. Each value of the array is an int of either one, two, or zero: 
- A one indicates that there is a wall. 
- Zero indicates an unvisited grid space.
-  Two indicates a visited space.

This way, of the possible wall locations, we can either set it to one or any other integer. If it is a one, we draw a wall, if not, then we ignore the space and keep it empty. The following video is the simulation in [action](https://drive.google.com/file/d/1CRVzQjXv2oCm4b7rVm_8gwiEeBbmW9DQ/view?usp=sharing). 

Notice that this algorithm isn't entirely perfect. When the robot mapped the bottom left, it backtracked to the right and up rather than straight up which would have had less turns and shorter distance. This is because we only check children locally. We have to backtrack to reach those children nodes instead of finding the shortest distance back to the node with the child. 

## Real-Time Maze
Similarly to the simulation team, the real-time team had to choose an algorithm. Due to time constraints, we went with left wall-following for the demonstration, but wrote DFS as well.

We used our line-following code from an earlier milestone, shown below:
```ino
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
int dis=0;
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

// main loop
void loop() {
  //record loop start time
  //unsigned long currentMillis = millis();

  // scan sensor states
  sensor0 = ((analogRead(A0) < threshold) ? 0 : 1);
  sensor1 = ((analogRead(A1) < threshold) ? 0 : 1);
  sensor2 = ((analogRead(A2) < threshold) ? 0 : 1);
  sensor3 = ((analogRead(A3) < threshold) ? 0 : 1);
  sensorBack = ((analogRead(A4) < threshold) ? 0 : 1);

  state = sensor3 + 10 * sensor2 + 100 * sensor1 + 1000 * sensor0;

  float SensorValue = analogRead(A5); // Read sensor value for analog pin A0
  float dis = 2076/(SensorValue - 11); // SensorValue to Distance conversion from https://www.dfrobot.com/wiki/index.php/SHARP_GP2Y0A41SK0F_IR_ranger_sensor_(4-30cm)_SKU:SEN0143
//  Serial.print(dis);
//  Serial.print(" cm\n");

  // write LEDs
  digitalWrite(led0pin, sensor0);
  digitalWrite(led1pin, sensor1);
  digitalWrite(led2pin, sensor2);
  digitalWrite(led3pin, sensor3);
  
  if (sensorBack)
  {
    if (dis>3 && dis<15)
    turnRight();
  }
  else
  {
    driveForward();
  }

  //Serial.println(state);
  delay(50);
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
      writeR(uwot);
      break;
    case 1000:
      // hardest left
      writeL(uwot);
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
    case 111:
      // slight right
      writeL(forwardFull);
      writeR(forwardAlmost);
      break;
    case 1110:
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
```
However, we met some problems when combining the code above with the code below:
```ino
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
  //to do
}
```
The first section has the sensors continously sensing the maze while the second section only counts 20 times for a 4*5 maze. Some variables should be set so that they connect the first section and the second section.

We plan to fix the integration of these two sections so that we are able to determine when we are finished mapping the maze. As our current implementation stands, while we may be able to map an entire maze (for particular configurations), we are unable to determine when our robot is finished. Once we get the left following algorithm fully functional, we should be able to do this. After we get the simple left following algorithm fully working, we will use the DFS algorithm we have already written and integrate this algorithm with our moving and sensor functions in order to have a more efficient maze mapping that will work on any maze configuration.

A short demo for the robot is presented below:
[![deeeeemo](https://i.imgur.com/z1V1OlN.png)](https://l.facebook.com/l.php?u=https%3A%2F%2Fyoutu.be%2FbeaNwDU7myo&h=ATMk15_mkxEEMS2NNmcqvEp4xnsGWUL7vO1sHba_yr-QNkjwsIK-B3J4OSpyPElof-jbdjnEwPJkDjTXjJqe6Kt9HBYpMMOIob_cE06iOtsI-HidNeBZa-G7BOW1fBmxOTINZ0XWhfk4zA)

### Future Potential Optimizations
To further improve our mapping algorithm, we could keep track of shortest path in an array much like Dijkstra's algorithm. Another possibility is implementing A* to get back to the node instead of backtracking with a node map that we construct. 
For example, for a given graph, we could weight the edges so that going straight is weighted less than turning, so the algorithm considers turning time. Many of these implementations greatly increase memory capacity which could be a limiting factor on an Arduino. But that won't stop Team Shrimp Cracker from trying!!!
