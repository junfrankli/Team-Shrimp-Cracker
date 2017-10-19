# Lab3: FPGA Video Controller and Sound Generation

## Graphics Team

### Equipment
* 1 FPGA Dev Board
* 1 VGA screen
* 1 VGA cable
* 1 VGA connector
* 1 VGA switch
* Various resistors

### Prelab
Looking at the VGA DAC, the specific resistor values for the DAC can be determined by the colors on each resistor. For both the three red digital bits, one goes through a resistor of value 240 ohms, another through a resistor of value 510 ohms, and the third through a resistor of value 1000 ohms. The same goes for the three green digital bit. Lastly, the blue signal only consists of two bits of which one goes through a resistor of 150 ohms and the other through a 
resistor of 330 ohms. ![](https://i.imgur.com/2api4Aj.png)
![](https://i.imgur.com/Kqc7OfG.png)
So why exactly do we need a DAC? The most basic answer is that the actual VGA input to the monitor takes three analog signals from 0-1V to determine the intensity of the components of the RGB color. The FPGA outputs 8 digital bits to represent color that are 3.3V. So for one, we need to step down the voltage. Another is that we need to put the three bit information in an actual analog intensity that represents the digital bits. So with three digital bits, we can only represent eight different intensities of green or red. So the resistors are chosen in order to give a max voltage of 1V even if all digital outputs are at 3.3V. They are also chosen to give certain digital bits more weight. For the MSB, the output has the least resistor value for a reason. ![](https://i.imgur.com/hFyyKhf.png)
Running the simulation of the circuit, we see that indeed when all sources are at 3.3V, the monitor has a voltage drop of 867.04mV. The following table lists the voltage drop values in the monitor depending on the digital signal bits. 
![](https://i.imgur.com/KHpm94r.png)
Eventhough the steps down in voltage aren't exactly even, it is close enough. Because each subsequent bit should have a higher weight of exactly two then the bit before it, the resistors are approximately double eachother. The blue digital signal resistors were chosen with the same logic in mind but just for two bits. WIth both digital outputs active, the resistor values are high enough to drop the voltage values to below 1V. The MSB carries twice the weight so it has a resistor of almost half of the resistor in front of the LSB. 


### Understanding the Challenge
 ![](https://i.imgur.com/PGmzSZr.png)
After reading and running the code into the FPGA, it seemed pretty simple on how the modules were suppossed to work together to create an image. The only thing that we really needed to create was how we would divide the pixels into workable blocks to display maze information. Because we are tasked with mapping a 4 by 5 maze, it seemed simple to make our map up of a 4 by 5 grid. We decided to make our each grid size 50 by 50 pixels as it seemed like a good size. Next, we needed to determine what pixel was located in what grid. The following code is the logic used to determine grid location.
```vhdl
	 assign GRID_DATA = ((PIXEL_COORD_X <= 10'b0000110010) & 
     (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][0] : 
     (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y 
     <= 10'b0001100100)) ? my_grid[1][0] : 
     (((PIXEL_COORD_X <= 10'b0000110010) 
     & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][0] : 
     (((PIXEL_COORD_X <= 10'b0000110010) 
     & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][0] : 
     ((PIXEL_COORD_X <= 10'b0001100100) 
     & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][1] : 
     (((PIXEL_COORD_X <= 10'b0001100100) 
     & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][1] : 
     (((PIXEL_COORD_X <= 10'b0001100100) 
     & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][1] :
     (((PIXEL_COORD_X <= 10'b0001100100) 
     & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][1] : 
     ((PIXEL_COORD_X <= 10'b0010010110) 
     & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][2] : 
     (((PIXEL_COORD_X <= 10'b0010010110) 
     & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][2] : 
     (((PIXEL_COORD_X <= 10'b0010010110) 
     & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][2] : 
     (((PIXEL_COORD_X <= 10'b0010010110) 
     & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][2] : 
     ((PIXEL_COORD_X <= 10'b0011001000) 
     & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][3] : 
     (((PIXEL_COORD_X <= 10'b0011001000) 
     & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][3] : 
     (((PIXEL_COORD_X <= 10'b0011001000) 
     & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][3] : 
     (((PIXEL_COORD_X <= 10'b0011001000) 
     & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][3] : 
     ((PIXEL_COORD_X <= 10'b0011111010) 
     & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][4] : 
     (((PIXEL_COORD_X <= 10'b0011111010) 
     & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][4] : 
     (((PIXEL_COORD_X <= 10'b0011111010) 
     & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][4] : 
     (((PIXEL_COORD_X <= 10'b0011111010) 
     & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][4] : 
     2'b0)))))))))))))));

```
Each grid has a 2-bit register which records what color it should contain. With this, we can program each grid contain different colors as shown.  
![](https://i.imgur.com/4S4WF6M.png)
### Interfacing with the Arduino
Because the arduino sends a digital signal of 5V, a simple voltage divider was constructed to bring it down to a FPGA safe 3.3V. 

### Voltage Divider Circuit
To connect the arduino to the FPGA, we need to create a voltage divider since the digital pins on the arduino output up to 5V, while the GPIO pins on the FPGA have a range of 0-3.3V. The simplest voltage divider involves two resistors, and for our purpose, we chose resistor values of 3.3 kOhms and 1.7 kOhms. We also grounded the FPGA and the arduino together. The following circuit diagram shows our voltage divider and how it connects to the arduino pin and the FPGA GPIO pin.
![](https://i.imgur.com/LH74Sl6.png)

After that, we had a very basic arduino protocal that turned on and off a digital signal every second and connected this signal to the FPGA. The FPGA then used the signal to change the color of a particular grid like [shown](https://drive.google.com/open?id=0B3QhcF_uRkb-QTd5WmZpMmZXNUU). The following code used to implement the logic is as follows. 
```vhdl
assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 always @(posedge CLOCK_25) begin
		my_grid[0][0] <= (GPIO_0_D[30] == 1) ? 2'b1 : 2'b0;
		my_grid[1][1] <= 2'b1;
		my_grid[1][0] <= 2'b10;
		my_grid[0][1] <= 2'b11;
		my_grid[2][2] <= 2'b0;
		my_grid[0][2] <= 2'b1;
		my_grid[2][0] <= 2'b10;
		my_grid[2][1] <= 2'b11;
		my_grid[1][2] <= 2'b0;
		my_grid[3][0] <= 2'b1;
		my_grid[0][3] <= 2'b10;
		my_grid[3][1] <= 2'b11;
		my_grid[1][3] <= 2'b0;
		my_grid[3][2] <= 2'b1;
		my_grid[2][3] <= 2'b10;
		my_grid[3][3] <= 2'b11;
		my_grid[3][4] <= 2'b0;
		my_grid[2][4] <= 2'b1;
		my_grid[1][4] <= 2'b10;
		my_grid[0][4] <= 2'b11;
	end
```



## Acoustic Team

### Equipment
* Lab speaker
* Stereo phone jack socket
* 8-bit R2R DAC

### Generating a Square Wave
We first choose to generate a square wave with a frequency of 440Hz. This can be accomplished simply and without the DAC by toggling a GPIO pin digitally on and off. Since the clock of the state machine we used is 25 MHz. Therefore the period of the 440Hz on the state machine is 25MHz/440Hz = 56818 cycles. Since one whole period is equally devided into low and high signal, the square pulse should toggle every 56818/2 = 28409 cycles. The code snippet used for generating square wave is included in the main DE0_NANO.v file and is represented below:


```v
    localparam toggle = 25_000_000/440/2;
    reg [14:0] counter;
    reg SOUND_OUT;
    assign GPIO_1_D[10] = SOUND_OUT;
    
    always @(posedge CLOCK_25) begin
      if (counter == toggle) begin
        counter <= 0;
	    SOUND_OUT <= ~SOUND_OUT;
  	  end else
        counter <= counter + 1;
    end
```

The square wave we achieved is displayed by the oscilloscope as shown below:
![square_wave](https://i.imgur.com/ySxtBhZ.jpg)

### Creating a Sine table
The DAC that we are using to convert digital signals to analog voltage is an eight bit resistor network, it will allow us to have 256 steps of output voltage.

Before we can play our sine wave with the FPGA, we need to generate a table of digital output values that match up with the levels of the DAC. This look up table will sit in memory and reduce the computational load on the FPGA. This is known as Direct Digital Synthesis. Our FPGA now only needs to iterate through these points at the chosen frequency to play our wave.

We used MATLAB to generate these 256 data points, convert them to 8-bit binary format, and output the correct syntax lines to be copy-pasted into our verilog file. 

Here's the generation script:

```MATLAB
out = zeros(256);
for t = 1:256
    out(t) = 128 + 128*sind((t-1) * 360 / 255);
    bin = dec2bin(out(t),8);
    fprintf('sine[%i] <= 8''b%s;\n', t-1, bin);
end
```

### Generating the Sine Waveform using our DAC
Next, we choose to generate a more complicated wave, a sine wave, at the frequency of 440 Hz. For this, we used a 8-bit R2R DAC which is shown below to convert 8-bit digital signal from FPGA to analog voltages into the lab speaker.
![DAC Circuit Diagram](https://i.imgur.com/nvkDDJW.png)

Since it is an 8-bit converter, the highest value we could get is 255, which represents 3.3V output from R2R DAC. Therefore, we use 256 points to represent 1 period of a sine wave. In that case, we need to toggle the sine pulse every 25MHz/440Hz/256 = 222 cycles, i.e. one point will stay for 222 cycles until updating to the next point. When the point (counter) reaches maximum, it will go back to 0 and increment again. The code snippet and the oscillscope display for sine wave are represented below:

```
module SINE_WAVE
(
    input [7:0] ADDR_VALUE,
    input CLOCK,
    output reg [7:0] SINE_OUT
);

    reg [7:0] sine[255:0];
    
    initial
    begin
        sine[0] <= 8'b10000000;
        //... sine table//
        sine[255] <= 8'b10000000;
    end
    
    always @ (posedge CLOCK)
    begin
    SINE_OUT <= sine[ADDR_VALUE];
    end

endmodule
```

![sine_wave](https://i.imgur.com/KxlZYuS.jpg)

And it sounds like:
[sine_wave_sound](https://drive.google.com/file/d/0B8bwFN4zRmfVekRXM3dIenRQNGM/view?usp=sharing)

Finally, we made two more sine wave sounds with different frequencies: 660 Hz and 220 Hz, with state machine. The three different sounds will be played when Arduino generates a done signal to FPGA. At this point, the Arudino is generating on and off signals every 6 seconds so that the sound will play for 6 seconds and stop for 6 seconds. The code snippet is represented below:

```
    localparam toggle_1 = 25_000_000/440/256;
    localparam toggle_2 = 25_000_000/660/256;
    localparam toggle_3 = 25_000_000/220/256;
    reg [1:0] audio_state;
    reg [1:0] next_audio_state;
    
    assign enable_sound = GPIO_0_D[30];
    assign {GPIO_1_D[0],GPIO_1_D[1],GPIO_1_D[3],GPIO_1_D[5],GPIO_1_D[7],GPIO_1_D[2],
        GPIO_1_D[4],GPIO_1_D[6]} = (audio_state == 0) ? 8'b0 : audio_out;
    
    always @(posedge CLOCK_25) begin
        if (audio_state == 1) begin
            if (counter == toggle_1) begin
                counter <= 0;
                if (addr >= 255) addr <= 0;
                else addr <= addr + 1;
            end else
                counter <= counter + 1;
        end
        if (audio_state == 2) begin
            if (counter == toggle_2) begin
                counter <= 0;
                if (addr >= 255) addr <= 0;
                else addr <= addr + 1;
                end else
                counter <= counter + 1;
        end
        if (audio_state == 3) begin
            if (counter == toggle_3) begin
                counter <= 0;
                if (addr >= 255) addr <= 0;
                else addr <= addr + 1;
            end else
                counter <= counter + 1;
        end
    end

    always @ (posedge CLOCK_25) begin
        if (audio_state == 0) begin
            if (enable_sound == 1) begin
                next_audio_state <= 2'b1;
            end else begin
                next_audio_state <= 2'b0;
            end
        end 
        else begin 
            if (enable_sound == 0) begin
                next_audio_state <= 2'b0;
            end else begin
                if (sec_counter == ONE_SEC) begin
                    sec_counter <= 0;
                    if (audio_state == 3) 
                        next_audio_state <= 1;
                    else
                        next_audio_state <= audio_state + 2'b1;
                end 
                else begin
                    sec_counter <= sec_counter + 2'b1;
                    next_audio_state <= audio_state;
                end
            end
        end
    end
```

It sounds like:
[sine_wave_sound_on_off](https://drive.google.com/file/d/0B8bwFN4zRmfVbFNjOXd4bTNfQm8/view?usp=sharing)
