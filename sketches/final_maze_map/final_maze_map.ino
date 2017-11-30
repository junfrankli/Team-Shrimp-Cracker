typedef struct square {
  int xPos;
  int yPos;
  struct square *next;
} SQUARE;

void setup() {
  // put your setup code here, to run once:
  
}

void loop() {
  // put your main code here, to run repeatedly:
  while (!detectTone());
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
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) 
          frontier = push(frontier, goalX, goalY);
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
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) 
          frontier = push(frontier, goalX, goalY);
        
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
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY))
          frontier = push(frontier, goalX, goalY);
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
        if (!findsquare(visited, goalX, goalY) && !findsquare(frontier, goalX, goalY)) 
          frontier = push(frontier, goalX, goalY);
      } 
      if (fft() > 0) 
        digitalWrite(13, HIGH);
      else 
        digitalWrite(13, LOW); 
      free(frontier_loc);
    }
  }
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

//RADIO CODE
void sendPacket(state) {}

//NEEDS TO BE UDPATED
bool detectTone() {
  //return true if tone is detected and robot should start, false otherwise
}

bool detectWall(int dir) {
  if (dir == 2)
    return false;
  //returns true if there is a wall in the specified direction 
  //directions: 0 for forward, 1 for left, 3 for right
  //only called at intersection 
}

void goForwardOneSquare() {}

void turnRight() {}

void turnLeft() {}


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
    return treasureDetect();
}

//treasure detection
//return 0 if no treasure, 1 if 7kHz, 2 if 12kHz, 3 if 17kHz
int treasureDetect() {
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
}
