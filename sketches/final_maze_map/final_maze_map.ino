#include <Wire.h>
#include <VL53L0X.h>
#include <DRV8835MotorShield.h>
#include <QTRSensors.h>
#include <SPI.h>
#include "nRF24L01.h"
#include "RF24.h"
#include <FFT.h> 

//turns
#define turn90 325
#define turn180 750
//Treasure detection 
#define LOG_OUT 1 // use the log output function
#define FFT_N 256 // set to 256 point fft

//speeds
#define MAXSPEED 300

// Distance Sensors
#define XSHUT_pinA 6
#define XSHUT_pinB 5
#define sensorA_newAddress 42
#define sensorB_newAddress 43
VL53L0X sensorA, sensorB, sensorC;

// Line Sensors
#define NUM_SENSORS   6     // number of line sensors used
#define TIMEOUT       2500  // waits for 2500 microseconds for sensor outputs to go low
#define EMITTER_PIN   QTR_NO_EMITTER_PIN     // emitter is controlled by digital pin 2, jk not
#define THRESHOLD     1000   // line sensor threshold
QTRSensorsRC qtrrc((unsigned char[]) {
  32, 30, 28, 26, 24, 22
},
NUM_SENSORS, TIMEOUT, EMITTER_PIN);
unsigned int sensorValues[NUM_SENSORS];

//global variables
int pos;
int leftSpeed, rightSpeed, lastPos, integral, power_difference;

char state, numonline, go;
  
// Radio pins
RF24 radio(4,3);

// Motor driver
DRV8835MotorShield motors;
// uses pins 10, 9, 8, 7

//
// Topology
//
// Radio pipe addresses for the 2 nodes to communicate.
const uint64_t pipes[2] = { 0x0000000022LL, 0x0000000023LL };

//
// Role management
//
// Set up role.  This sketch uses the same software for all the nodes
// in this system.  Doing so greatly simplifies testing.
//

// The various roles supported by this sketch
typedef enum { role_ping_out = 1, role_pong_back } role_e;

// The debug-friendly names of those roles
const char* role_friendly_name[] = { "invalid", "Ping out", "Pong back"};

// The role of the current running sketch
role_e role = role_ping_out;

typedef struct square {
  int xPos;
  int yPos;
  struct square *next;
} SQUARE;

void setup() {
  // put your setup code here, to run once:
  Wire.begin();

  Serial.begin(115200);

  //Treasure setup
  /*TIMSK0 = 0; // turn off timer0 for lower jitter
  ADCSRA = 0xe5; // set the adc to free running mode
  ADMUX = 0x40; // use adc0
  DIDR0 = 0x01; // turn off the digital input for adc0*/
  
  pinMode(XSHUT_pinA, OUTPUT);
  digitalWrite(XSHUT_pinA, LOW);
  pinMode(XSHUT_pinB, OUTPUT);
  digitalWrite(XSHUT_pinB, LOW);
  Serial.println("output mode");
  //
  sensorA.setAddress(sensorA_newAddress);
  pinMode(XSHUT_pinA, INPUT);
  delay(10);
  sensorB.setAddress(sensorB_newAddress);
  pinMode(XSHUT_pinB, INPUT);
  delay(10);

  
  Serial.println("Initializing Serial");
  // wait 2 seconds
  delay(2000);


  sensorA.init();
  sensorB.init();
  sensorC.init();
  Serial.println("Init rangesensor");


  sensorA.setTimeout(500);
  sensorB.setTimeout(500);
  sensorC.setTimeout(500);

  //sensorA.startContinuous();
  //sensorB.startContinuous();
  //sensorC.startContinuous();
  Serial.println("Initializing Ranging Sensors");

  // Motors
  motors.flipM1(true);
  motors.flipM2(true);
  // Radio setup
  radio.begin();

  // optionally, increase the delay between retries & # of retries
  radio.setRetries(15,15);
  radio.setAutoAck(true);
  // set the channel
  radio.setChannel(0x50);
  // set the power
  // RF24_PA_MIN=-18dBm, RF24_PA_LOW=-12dBm, RF24_PA_MED=-6dBM, and RF24_PA_HIGH=0dBm.
  radio.setPALevel(RF24_PA_HIGH);
  //RF24_250KBPS for 250kbs, RF24_1MBPS for 1Mbps, or RF24_2MBPS for 2Mbps
  radio.setDataRate(RF24_250KBPS);

  //set up for ping out
  radio.openWritingPipe(pipes[0]);
  radio.openReadingPipe(1,pipes[1]);
}

void loop() {
  // put your main code here, to run repeatedly:
  while (!detectTone()) {
    // wait to start
  }
  Serial.println("Started");
  SQUARE *visited = NULL;
  SQUARE *frontier = NULL;
  SQUARE *path = NULL;
  int curX = 0;
  int curY = 0;
  int heading = 0;
  
  visited = push(visited, 0, 0);
  path = push(path, 0, 0);
  int wall1 = detectWall(1);
  int wall0 = detectWall(0);
  //Serial.print("Wall 1: ");
  //Serial.println(wall1);
  //Serial.print("Wall 0: ");
  //Serial.println(wall0);
  if (!wall1)
    frontier = push(frontier, 1, 0); 
  if (!wall0) 
    frontier = push(frontier, 0, 1);

  //check for treasures
  int treasure = 0; //detect_treasure ();
  int t1 = 0;
  int t2 = 0;
  int t3 = 0;
  if (treasure == 1)
    t1 = 1;
  else if (treasure == 2)
    t2 = 1;
  else if (treasure == 3)
    t3 = 1;
  //send maze packet
  sendMazePacket(0, 0, 1, wall1, 1, wall0, t1, t2, t3, 0);
  //DFS 
  while (frontier != NULL) {
    SQUARE* frontier_loc = pop(&frontier);
    if (!findsquare(visited, frontier_loc->xPos, frontier_loc->yPos)) {
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
          curX = curX + 1;
        else if (dir == 2)
          curY = curY - 1;
        else if (dir == 3)
          curX = curX - 1;
  
        sendMazePacket(curX, curY, 0, 0, 0, 0, 0, 0, 0, 0);
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
          curX = curX + 1;
        else if (heading == 2)
          curY = curY - 1;
        else if (heading == 3)
          curX = curX - 1;
  
        Serial.print("Adding to visited: ");
        Serial.print(curX);
        Serial.print(" ");
        Serial.println(curY);
        //add current position to visited
        visited = push(visited, curX, curY);
        
        //detect possible places to go -- if not in visited add to frontier
        int goalX;
        int goalY;
        int wall3 = detectWall(3);
        int wall2 = detectWall(2);
        int wall1 = detectWall(1);
        int wall0 = detectWall(0);
        Serial.print("Wall 3: ");
        Serial.println(wall3);
        Serial.print("Wall 2: ");
        Serial.println(wall2);
        Serial.print("Wall 1: ");
        Serial.println(wall1);
        Serial.print("Wall 0: ");
        Serial.println(wall0);
        if (!wall3) {
          switch(heading) {
            case 0:
              goalX = curX-1;
              goalY = curY;
              break;
            case 1:
              goalX = curX;
              goalY = curY+1;
              break;
            case 2:
              goalX = curX+1;
              goalY = curY;
              break;
            case 3:
              goalX = curX;
              goalY = curY-1;
              break;
          }
          if (!findsquare(visited, goalX, goalY)) {
            Serial.print("adding to frontier: ");
            Serial.print(goalX);
            Serial.print(" ");
            Serial.println(goalY);
            frontier = push(frontier, goalX, goalY);
          }
        }
        if (!wall2){
          switch(heading) {
            case 0:
              goalX = curX;
              goalY = curY-1;
              break;
            case 1:
              goalX = curX-1;
              goalY = curY;
              break;
            case 2:
              goalX = curX;
              goalY = curY+1;
              break;
            case 3:
              goalX = curX+1;
              goalY = curY;
              break;
          }
          if (!findsquare(visited, goalX, goalY)) {
            Serial.print("adding to frontier: ");
            Serial.print(goalX);
            Serial.print(" ");
            Serial.println(goalY);
            frontier = push(frontier, goalX, goalY);
          }
          
        }
        if (!wall1) {
          switch(heading) {
            case 0:
              goalX = curX+1;
              goalY = curY;
              break;
            case 1:
              goalX = curX;
              goalY = curY-1;
              break;
            case 2:
              goalX = curX-1;
              goalY = curY;
              break;
            case 3:
              goalX = curX;
              goalY = curY+1;
              break;
          }
          if (!findsquare(visited, goalX, goalY)) {
            Serial.print("adding to frontier: ");
            Serial.print(goalX);
            Serial.print(" ");
            Serial.println(goalY);
            frontier = push(frontier, goalX, goalY);
          }
        }
        if (!wall0) {
          switch(heading) {
            case 0:
              goalX = curX;
              goalY = curY+1;
              break;
            case 1:
              goalX = curX+1;
              goalY = curY;
              break;
            case 2:
              goalX = curX;
              goalY = curY-1;
              break;
            case 3:
              goalX = curX-1;
              goalY = curY;
              break;
          }
          if (!findsquare(visited, goalX, goalY)) {
            frontier = push(frontier, goalX, goalY);
            Serial.print("adding to frontier: ");
            Serial.print(goalX);
            Serial.print(" ");
            Serial.println(goalY);
          }
        } 
        //check for treasures
        int treasure = 0; //detect_treasure ();
        int t1 = 0;
        int t2 = 0;
        int t3 = 0;
        if (treasure == 1)
          t1 = 1;
        else if (treasure == 2)
          t2 = 1;
        else if (treasure == 3)
          t3 = 1;
        //send maze packet
        int rw = 0;
        int lw = 0;
        int dw = 0;
        int uw = 0;
  
        switch(heading) {
          case 0:
            rw = wall3;
            lw = wall1;
            dw = wall2;
            uw = wall0;
            break;
          case 1:
            rw = wall2;
            lw = wall0;
            dw = wall1;
            uw = wall3;
            break;
          case 2:
            rw = wall1;
            lw = wall3;
            dw = wall0;
            uw = wall2;
            break;
          case 3:
            rw = wall0;
            lw = wall2;
            dw = wall3;
            uw = wall1;
            break;
        }
        sendMazePacket(curX, curY, rw, lw, dw, uw, t1, t2, t3, 0);
        free(frontier_loc);
      }
    } else 
       //free memory
       free(frontier_loc);
  }
  sendMazePacket(0, 0, 0, 0, 0, 0, 0, 0, 0, 1);
  Serial.println("DONE");
  delay(1000);
}

//moves robot one square based on current position and heading
//returns heading if robot is able to move to specified square, -1 otherwise
int moveAdjacent(int curX, int curY, int heading, int goalX, int goalY) {
  Serial.print("Moving: ");
  Serial.print(goalX);
  Serial.print(" ");
  Serial.println(goalY);
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

  if (heading != dir) {
    switch (heading) {
      case 0:
        switch (dir) {
          case 1:
            turnLeft(turn90);
            break;
          case 2: 
            turnLeft(turn180);
            break;
          case 3:
            turnRight(turn90);
            break;
        }
        break;
      case 1:
        switch (dir) {
          case 0:
            turnRight(turn90);
            break;
          case 2: 
            turnLeft(turn90);
            break;
          case 3:
            turnRight(turn180);
            break;
        }
        break;
      case 2: 
        switch (dir) {
          case 1:
            turnRight(turn90);
            break;
          case 0: 
            turnLeft(turn180);
            break;
          case 3:
            turnLeft(turn90);
            break;
        }
        break;
      case 3:
        switch (dir) {
          case 1:
            turnLeft(turn180);
            break;
          case 0: 
            turnLeft(turn90);
            break;
          case 2:
            turnRight(turn90);
            break;
        }
        break;
    }
  }
  
  goForwardOneSquare();
  return dir;
}

// stack functions
bool findsquare(SQUARE *head, int x, int y) {
  Serial.print("Looking for square: ");
  Serial.print(x);
  Serial.print(" ");
  Serial.println(y);
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

//RADIO CODE
void sendMazePacket(int x, int y, int rw, int lw, int dw, int uw, int t1, int t2, int t3, int done) {
  int packet = 0;
  packet = packet | ((3-x) << 12);
  packet = packet | (y << 8);
  packet = packet | (rw << 7);
  packet = packet | (lw << 6);
  packet = packet | (dw << 5);
  packet = packet | (uw << 4);
  packet = packet | (t1 << 3);
  packet = packet | (t2 << 2);
  packet = packet | (t3 << 1);
  packet = packet | done;

  sendRadioPacket(packet);
}

void sendRadioPacket(int packet) {
  bool ok = radio.write( &packet, sizeof(int));
  for (int i = 0; i < 10; i++) {
    if (ok)
      break;
    ok = radio.write( &packet, sizeof(int));
  }
}


//NEEDS TO BE UDPATED
bool detectTone() {
  //return true if tone is detected and robot should start, false otherwise
  return 1;
}

bool detectWall(int dir) {
  if (dir == 2)
    return false;
  //returns true if there is a wall in the specified direction 
  //directions: 0 for forward, 1 for left, 3 for right
  int wallDist = 0;
  if (dir == 0) {
    for (int i = 0; i < 2; i++) {
      wallDist += sensorC.readRangeSingleMillimeters(); 
    }
  }
  else if (dir == 1) {
    for (int i = 0; i < 2; i++) {
      wallDist += sensorB.readRangeSingleMillimeters();
    }
  }
  else if (dir == 3) {
    for (int i = 0; i < 2; i++) {
      wallDist += sensorA.readRangeSingleMillimeters(); 
    }
  }
  Serial.print("Checking wall ");
  Serial.print(dir);
  Serial.print(" ");
  Serial.println(wallDist);
  return (wallDist < 1750/5);
}

void goForwardOneSquare() {
  Serial.println("going forward");
  int numonline, goforward = 1, lastRead;
  int started = 0;
  unsigned char i, on_line = 0;
  unsigned long avg;
  unsigned int sum;

  int max = MAXSPEED;

  while (goforward) {
    // read line sensors
    qtrrc.read(sensorValues);

    lastRead = pos;
    avg = 0;
    sum = 0;
    on_line = 0;
    numonline = 0;
    for (i = 0; i < NUM_SENSORS; i++) {
      int value = sensorValues[i];
      // keep track of whether we see the line at all
      if (value > 350) {
        on_line = 1;
        numonline++;
      }

      // only average in values that are above a noise threshold
      if (value > 50) {
        avg += (long)(value) * (i * 2500);
        sum += value;
      }
    }
    if (!on_line)
    {
      // If it last read to the left of center, return 0.
      if (lastRead < (NUM_SENSORS - 1) * 1000 / 2) {
        pos =  -2500;
        // If it last read to the right of center, return the max.
      } else {
        pos = (NUM_SENSORS - 1) * 1000 - 2500;
      }
    } else {

      // calculate position
      pos = .4 * avg / sum - 2500;
    }

    // calc PIDs
    int derivative = pos - lastPos;
    integral = integral + pos;
    lastPos = pos;

    power_difference = pos / 12 + integral / 11000 + derivative * .5;

    const int max = 200;
    if (power_difference > max)
      power_difference = max;
    if (power_difference < -max)
      power_difference = -max;

    if (started) {
      if (numonline >= 5 ) {
        goforward = 0;
      }
      if (power_difference < 0) {
        motors.setSpeeds(max + power_difference, max);
      }  else {
        motors.setSpeeds(max, max - power_difference);
      }
    } else {
      if (numonline < 5) 
        started = 1;
      else {
        motors.setSpeeds(max, max);
      }
    }
  }
  motors.setSpeeds(0, 0);
}


void turnLeft(int time) {
  int online, turnleft = 1, started, lastRead;

  unsigned char i, on_line = 0;
  unsigned long avg;
  unsigned int sum;

  int max = 200;

  motors.setSpeeds(max, -max);
  delay(time);
  motors.setSpeeds(0, 0);
}

void turnRight(int time) {
  int max = 200;

  motors.setSpeeds(-max, max);
  delay(time);
  motors.setSpeeds(0, 0);
}
/*
int detect_treasure() {
  int threshold = 50;
  for (int i = 0; i < 10; i++) {
    
  }
}
//read from adc0 and do fft
int fft() {
    cli();  // UDRE interrupt slows this way down on arduino1.0
    for (int i = 0 ; i < 512 ; i += 2) { // save 256 samples
      while(!(ADCSRA & 0x10)); // wait for adc to be ready
      ADCSRA = 0xf5; // restart adc
      byte m = ADCL; // fetch adc data
      byte j = ADCH;
      int k = (j << 8) | m; // form into an int
      k -= 0x0200; // form into a signed int
      k <<= 6; // form into a 16b signed int
      fft_input[i] = k; // put real data into even bins
      fft_input[i+1] = 0; // set odd bins to 0
    }
    fft_window(); // window the data for better frequency response
    fft_reorder(); // reorder the data before doing the fft
    fft_run(); // process the data in the fft
    fft_mag_log(); // take the output of the fft
    sei(); // turns interrupts back on
}

//treasure detection
//return 0 if no treasure, 1 if 7kHz, 2 if 12kHz, 3 if 17kHz
/*int treasureDetect() {
  int treasure_7;
  int treasure_12;
  int treasure_17;
  int max_7_bin = 0;
  int threshold = 40;
  for (int i = 0; i < 256; i++) {
    Serial.println (i);
    Serial.println ("DONE with fft");
  }
    for (int i = 46; i < 50; i++) {
      int x = (int) fft_log_out[i];
      if (x > max_7_bin)
        max_7_bin = x;
    }
    int max_12_bin = 0;
    for (int i = 80; i < 83; i++) {
      int x = (int) fft_log_out[i];
      if(x > max_12_bin) 
        max_12_bin = x;
    }
    int max_17_bin = 0;
    for (int i = 113; i < 116; i++) {
      int x = (int) fft_log_out[i];
      if (x > max_17_bin)
        max_17_bin = x;
    }
    if (max_17_bin > max_12_bin && max_17_bin > max_7_bin) {
      if (max_17_bin > threshold) 
       return 3;
    }
    else if (max_12_bin > max_7_bin) {
      if (max_12_bin > threshold)  
       return 2;
    }
    else 
      if (max_7_bin > threshold)
        return 1;
    return 0;
}*/
