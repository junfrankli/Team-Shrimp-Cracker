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
