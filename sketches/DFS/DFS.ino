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
  if (detectPath(0, curX, curY))
    frontier = push(frontier, 0, 1);
  if (detectPath(1, curX, curY))
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
      if (detectPath(0, curX, curY)) {
        if (!findsquare(visited, curX, curY+1))
          frontier = push(frontier, curX, curY+1);
      } 
      if (detectPath(1, curX, curY)) {
        if (!findsquare(visited, curX+1, curY))
          frontier = push(frontier, curX+1, curY);
      }
      if (detectPath(2, curX, curY)){
        if (!findsquare(visited, curX, curY-1))
          frontier = push(frontier, curX, curY-1);
      }
      if (detectPath(3, curX, curY)) {
        if (!findsquare(visited, curX-1, curY))
          frontier = push(frontier, curX-1, curY);
      }
      free(frontier_loc);
    }
  }

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
    if (heading > dir) 
      turnLeft();
    else
      turnRight();
  }

  **goForwardOneSquare();
  return dir;
}

// returns true if there is a square in the specified direction
// 0 is pos y, 1 is pos x, 2 is neg y, 3 is neg x
bool detectPath(int dir, int x, int y) {
  if (detectWall(dir))
    return false;
  if (dir == 0 && y == 4)
    return false;
  if (dir == 1 && x == 3)
    return false;
  if (dir == 2 && y == 0)
    return false;
  if (dir == 3 && x == 0)
    return false;
  return true;
}

bool findsquare(SQUARE *head, int x, int y) {
  while (head != NULL) {
   if (head->xPos == x){ 
    if (head->yPos == y)
      return true;
   } else
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

