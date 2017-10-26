# Lab4: Radio Communication and Map Drawing

## Radio Team

### Prelab
We began by checking out the reference page of the RF24 Arduino library: 
http://maniacbug.github.io/RF24/classRF24.html

Our job is to send a packet of information that contains the information necessary to update the state. This includes information like walls and treasure locations. The two main ways to transmit this information is through a parallel interface or serial interface. Because for this lab, we only have to display the current position and track previously visited positions, we decided to keep our parallel interface implementation from lab 3. This is because it is easier to implement on an FPGA. Also the information that we are sending from the Arduino to the FPGA does not need that many bits at the moment. We will continue to monitor the interface that we use and may switch to SPI if we feel the need. 

### Equipment
* 2 Nordic nRF24L01+ transceivers
* 2 Arduino Unos (one must be shared with the other sub-team)
* 2 USB A/B cables
* 2 radio breakout boards with headers

### Hardware
We assembled each of the Arduinos with an RF module, adapter board, and a wire for power to the 3.3V output as shown below:

![RF 2 Arduino](https://i.imgur.com/6sKpbAE.jpg)

### Initial Testing
We first changed the channel numbers:
```
const uint64_t pipes[2] = { 0x0000000022LL, 0x0000000023LL };
// 2(3D + N) + X D=2, N=11
```
RF24 sketch was uploaded into both of the Arduinos. One serves as a sender and the other serves as a receiver. The results for the sender is:
![test sender](https://i.imgur.com/nwPMQSG.jpg)
The results for the receiver is:
![test receiver](https://i.imgur.com/I5KD3sp.jpg)

The power level is set to be at minimun which is -18dBm, we lost several packages at around 30 feets and the connection is completely lost at around 40 feets. The serial monitor looks like:
![package lost](https://i.imgur.com/7zkPRq9.jpg)


### Sending the maze
Initially, we are going to send the entire maze every time some part of it is modified. The maze is stored as a two dimensional, 5 x 5 array of chars.

Here is how it is defined:

'''
unsigned char maze[5][5] =
{
3, 3, 3, 3, 3,
3, 1, 1, 1, 3,
3, 2, 0, 1, 2,
3, 1, 3, 1, 3,
3, 0, 3, 1, 0,
};
'''

We then created the following sketch to send the array.
```
  if (role == role_ping_out)
  {
    // First, stop listening so we can talk.
    radio.stopListening();


    unsigned char maze[5][5] =
    {
    3, 3, 3, 3, 3,
    3, 1, 1, 1, 3,
    3, 2, 0, 1, 2,
    3, 1, 3, 1, 3,
    3, 0, 3, 1, 0,
    };

    printf("Now sending the maze...\n");
    bool ok = radio.write( maze, sizeof(maze) );

    if (ok)
      printf("ok...\n");
    else
      printf("failed.\n\r");

    // Now, continue listening
    radio.startListening();
    
    // Wait here until we get a response, or timeout (250ms)
    unsigned long started_waiting_at = millis();
    bool timeout = false;
    while ( ! radio.available() && ! timeout )
      if (millis() - started_waiting_at > 200 )
        timeout = true;

    // Describe the results
    if ( timeout )
    {
      printf("Failed, response timed out.\n\r");
    }
    else
    {
      // Grab the response, compare, and send to debugging spew
      unsigned char got_maze[5][5];
      radio.read( got_maze, sizeof(got_maze) );

      // Spew it
        for (int i=0 ; i<5 ; i++){
          for (int j=0 ; j<5 ; j++){
            printf ("%d ", got_maze[i][j]);
          }
          printf ("\n");
        }
    }

    // Try again 1s later
    delay(1000);
  }
```

The code below is for the receiver:
```
  if ( role == role_pong_back )
  {
    // if there is data ready
    if ( radio.available() )
    {
      // Dump the payloads until we've gotten everything
      unsigned char got_maze[5][5];
      bool done = false;
      while (!done)
      {
        // Fetch the payload, and see if this was the last one.
        done = radio.read( got_maze, sizeof(got_maze) );

        // Spew it
        for (int i=0 ; i<5 ; i++){
          for (int j=0 ; j<5 ; j++){
            printf ("%d ", got_maze[i][j]);
          }
          printf ("\n");
        }

        // Delay just a little bit to let the other unit
        // make the transition to receiver
        delay(20);

      }
```
The Auto-ACK feature is automatically turned on so we don't need to bother enabling it.
The result for the sender can be seen below:
![maze sender](https://i.imgur.com/LJ1bd3x.jpg)

The result for the receiver can be seen below:
![maze receiver](https://i.imgur.com/X5Io9F2.jpg)

### Only sending new info
Next we modified our sketch to only send the data for parts of the maze that have changed from their last value. For each packet sent, we include a data character and an x and y index of its position in the maze matrix.

Part of the code for the sender is:
```
    int x_coord = 3;
    int y_coord = 2;
    unsigned char data = 2;

    printf("Now sending the data for (%d, %d)...\n", x_coord, y_coord);
    bool ok = radio.write( &data, sizeof(data) );
```

Part of the code for the receiver is:
```
    int x_coord = 3;
    int y_coord = 2;
    unsigned char data = 2;

    printf("Now sending the data for (%d, %d)...\n", x_coord, y_coord);
    bool ok = radio.write( &data, sizeof(data) );
```

The result for the sender can be seen below:
![maze sender](https://i.imgur.com/1wRUjmh.jpg)

The result for the receiver can be seen below:
![maze receiver](https://i.imgur.com/famHGKV.jpg)

### Sending Shrimpbot's position
In order to have the robot's position updated in real time on the display, we will relay its coordinates over radio to the second Arduino, which ports that information over to the FPGA to be displayed. 

We designed for a 4 x 5 two dimensional matrix defined as below:

```
unsigned char position[4][5] =
{
1, 0, 0, 0, 0,
0, 0, 0, 0, 0,
0, 0, 0, 0, 0,
0, 0, 0, 0, 0;
```

The data is sent as a package containing x-coordinate, y-coordinate, and state. Since the maze is 4 * 5, we need 3 bits both for x- and y-coordinate and 2 bits for the state. We first pack the x-coordinate, y-coordinate, and state to data character in the sender side and unpack in the receiver side. In the sender side, we left shift x-coordinate 5 bits and y-coordinate 2 bits. In the receiver side, we right shift x-coordinate 5 bits. For y-coordinate, we first mask off bits with 00011100 which is 28 in decimal and then right shift 2 bits. For state, we only need to mask off bits with 00000011 which is 3 in decimal. Taking (3, 2) as an example, the code for the sender is:
```
    unsigned char x_coord = 3; //011
    unsigned char y_coord = 2; //010
    unsigned char state = 3;   //11
    unsigned char data;
    data = x_coord << 5 | y_coord << 2 | state; // 01101011 which is 107 in decimal

    printf("Now sending the update for (%d, %d)...\n", x_coord, y_coord);
    bool ok = radio.write( &data, sizeof(data) );

    if (ok)
      printf("ok...\n");
    else
      printf("failed.\n\r");
```
The code for the receiver is:
```
      unsigned char got_data;
      bool done = false;
      while (!done)
      {
        // Fetch the payload, and see if this was the last one.
        done = radio.read( &got_data, sizeof(got_data) );

        unsigned char x_c;
        unsigned char y_c;
        unsigned char new_state;
        x_c = got_data >> 5;
        y_c = (got_data & 28) >> 2; // mask with 00011100
        new_state = got_data & 3;   // mask with 00000011

        // Spew it
        printf ("The update for (%d, %d) is %d. \n", x_c, y_c, new_state);

        // Delay just a little bit to let the other unit
        // make the transition to receiver
        delay(20);
```
The result for the sender can be seen below:
![maze sender](https://i.imgur.com/vGv5Cwz.jpg)

The result for the receiver can be seen below:
![maze receiver](https://i.imgur.com/CshWxCI.jpg)


## FPGA Team

### Prelab
First we decided our data transmission scheme for this lab and beyond. We wanted to design a system that can transmit large packets with ease, as this will be necesary for the final competition.

We decided to use this method to send packets...

### Equipment
* 1 FPGA Dev Board
* 1 VGA screen
* 1 VGA cable
* 1 VGA connector
* 1 VGA switch
* Various resistors


### Increasing grid size
We had already implemented the 4 by 5 grid in the previous lab, so there was no work to be done this week. 

### Receiving packets from the arduino
We used a parallel method to read data, where we read data from 5 GPIO pins at once. While this was good for this lab since we did not need many bits, we might choose to use SPI in the future if we need to send more bits. Using the previously agreed upon packet format, we wrote a module to read data sent from the arduino. The packet was 5 bits and contained the grid block that was the current position.  


### Displaying shrimpbot's position
Using the data from the previous section, we parse the inputted position and display it on a 4 x 5 grid. We defined a parameter and we updated the appropriate register based on the packet we received.  


### Marking our path
Next we added functionality to display the previously explored locations in the maze as well as the current position. To do this, we updated the register with value current position to have the value visited. 

The following code shows how we updated the grid registers based on the packet that we received and the current value of the register.

```
always @(packet) begin
		my_grid[0][0] <= (reset == 1) ? unvisited : ((packet == 5'b0) ? currentpos : ((my_grid[0][0]== currentpos) ? visited : my_grid[0][0]));
		my_grid[1][1] <= (reset == 1) ? unvisited : ((packet == 5'b00101) ? currentpos : ((my_grid[1][1]== currentpos) ? visited : my_grid[1][1]));
		my_grid[1][0] <= (reset == 1) ? unvisited : ((packet == 5'b00001) ? currentpos : ((my_grid[1][0]== currentpos) ? visited : my_grid[1][0]));
		my_grid[0][1] <= (reset == 1) ? unvisited : ((packet == 5'b00100) ? currentpos : ((my_grid[0][1]== currentpos) ? visited : my_grid[0][1]));
		my_grid[2][2] <= (reset == 1) ? unvisited : ((packet == 5'b01010) ? currentpos : ((my_grid[2][2]== currentpos) ? visited : my_grid[2][2]));
		my_grid[0][2] <= (reset == 1) ? unvisited : ((packet == 5'b01000) ? currentpos : ((my_grid[0][2]== currentpos) ? visited : my_grid[0][2]));
		...	
end
```

This [video](https://drive.google.com/file/d/0B9RjcO6lwSovc1AtNVptNFJWNUk/view?usp=sharing) demonstrates how the FPGA is able to change the current position (marked by the green square) based on the parsing of a packet. The blue squares are the visited ones, while the black is unvisited, and the red represents treasure.
