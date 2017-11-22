# Milestone 4: Integrating Everything

## Goals
1.  System that successfully displays the walls in a maze as the robot finds them
2. System that successfully displays treasures in a maze as the robot finds them
3. Robot that successfully signals ‘done’ on the screen when the maze has been mapped
4. Robot that successfully plays ‘done’ on the speaker when the maze has been mapped

This [video](https://drive.google.com/file/d/13MYQIdu7I58t4C0PYVKPzFHC8Ulnxn15/view?usp=sharing) shows our robot mapping out the maze.


## Mapping The Walls
Mapping the walls was fairly easy. We decided to stick with parallel configuration regarding the GUI. In order to remedy the potential timing issues, we have a write bit. The FPGA only writes after if the write bit is active high. This ensures that when the maze information is encoded in parallel digital signals, that the FPGA clock doesn't encode partial information onto the VGA monitor. Specifially for walls, there are four bits of information that handle walls. The robot detects walls using short-range IR sensors. To detect walls, we just have a threshhold for which we measured before to determine the appropriate distance that we record a wall. Once the robot itself detects a wall, it updates the maze grid in the arduino code dependent on the heading of the robot. For example, if the front wall sensor sensed a wall, that doesn't necessarilly mean that there is a wall in the up direction from the current position. If the heading is to the right, then the wall is to the right of the current position. Once this data is encoded and sent over radio, we then decode the information on the receiver arduino into a readable packet and send it to the FPGA. 

For the FPGA GUI, we added walls by increasing the maze size. The logic is the same as the Java simulation. Instead of a 5 by 4 grid, we now encode a 11 by 9 grid. 
![](https://i.imgur.com/FvvO4oY.png)
This is because each actual tile has a potential wall between them. Including the walls on the outside of the maze, there are 6 positions for horizontal walls and 5 positions for the vertical walls. We hardcode in the outside walls. For the inner walls, the arduino sends the packet which lists the wall bits. The FPGA then just writes in the walls following simple logic regarding those bits. If there isn't a wall, our implemenation fills the wall with the visited color as a stylistic choice. The following is a snippet of the verilog logic. 
```vhdl
if (packet[4:0] != 5'b000_00 && packet[4:0] != 5'b000_01 && my_grid[1][2] != wall && my_grid[1][2] != visited)
			my_grid[1][2] <= unvisited;
		else if ((packet[4:0] == 5'b000_00 || packet[4:0] == 5'b000_01) && my_grid[1][2] != wall && my_grid[1][2] != visited) begin
			if ((packet[4:0] == 5'b000_00 && packet[5]==1'b1) || (packet[4:0]==5'b000_01 && packet[6]==1'b1))
				my_grid[1][2] <= wall;
			else
				my_grid[1][2] <= visited;
		end
```

The picture of the mapped maze in the GUI is shown in the next section.

## Treasure Detection

For the most part, our treasure detection was similar to the procedure we had used in Lab 2. We left the FFT code the same. However, since the positioning of the IR sensor was slightly different than we had anticipated in Lab 2 (ie. we did not have to detect treasures from as far away), the threshold we used in this milestone were different. We chose to slightly increase the threshold but decrease the time integration in order to speed up the treasure detection. While our treasure detection is able to detect the presence of a treasure most of the time, we occasionally have a false positive. However, since we plan to have a new robot for the final competition, we did not think it worth it to spend a lot of time getting the thresholds just right because the threshold will change based on the position of the sensor on the final robot. 

The following code shows the FFT and our time integration to determine if there is a treasure. The time integration consists of reading from the ADC pin A0 five times, computing the FFT, and determining the presence of a treasure based on the results. Our algorithm checks the return value of the fft function - if it's 0 for no treasure, 1 for 7kHz treasure, 2 for 12kHz, and 3 for 17. 

``` 
int fft() {
   int sum = 0;
   ADCSRA = 0xe5;
   for (int i = 0; i < 10; i++) {
    cli();  // UDRE interrupt slows this way down on arduino1
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
    int x = treasureDetect();
    Serial.println(x);
    sum = sum + x;
   }
   ADCSRA = adc_state;
   Serial.println("sum");
   Serial.println(sum);
   if (sum < 5)
    return 0;
   else if (sum < 15)
    return 1;
   else if (sum < 25)
    return 2;
   else return 3; 
}

//treasure detection
int treasureDetect() {
  int treasure_7;
  int treasure_12;
  int treasure_17;
  int max_7_bin = 0;
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
```

We currently check for treasures when we are stopped at an intersection. The intersections are at small enough intervals such that our IR sensor will not miss a treasure. Furthermore, because the FFT is computationally expensive, we do not want to check for treasures while trying to follow the line to move from one intersection to another. 

The treasure detection is then displayed on the GUI by the FPGA, with the color depending on the frequency of the treasure.

Here is a picture of the GUI once the robot has mapped out the maze, with a white square representing a 7 kHz treasure:

![map](https://i.imgur.com/W9JX4er.jpg)



## Done Signal

### How the robot realizes it's done
The algorithm we use to map the maze is DFS. At every intersection, our robot checks the stack of frontier nodes (nodes it has detected as possible to visit but not yet visited). If the stack is empty, the robot realizes it has visited all the reachable nodes in the maze. The robot then sends the done signal. 

The MSB of the 13bits "packet" is for the done signal. We assigned that bit to GPIO_0_D[32] of the FPGA. When the robot finished mapping the maze, the arduino in the robot would send an encoded message to the arduino with FPGA which would decode the message to have the 13th bit to be 1 indicating it's done. 

### Screen
When receiving a done signal, the screen would become as the following picture shows.
![done](https://i.imgur.com/W9JX4er.jpg)

### Speaker
When the robot is done mapping the maze, it would play a tone as the video shows.
https://drive.google.com/file/d/11ATn1BG49dfNDevyFK9cVMs7KJPBo8y0/view?usp=sharing