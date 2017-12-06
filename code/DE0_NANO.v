//=======================================================
// ECE3400 Fall 2017
// Lab 3: Template top-level module
//
// Top-level skeleton from Terasic
// Modified by Claire Chen for ECE3400 Fall 2017
//=======================================================

`define ONE_SEC 25000000

module DE0_NANO(

	//////////// CLOCK //////////
	CLOCK_50,

	//////////// LED //////////
	LED,

	//////////// KEY //////////
	KEY,

	//////////// SW //////////
	SW,

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	GPIO_0_D,
	GPIO_0_IN,

	//////////// GPIO_0, GPIO_1 connect to GPIO Default //////////
	GPIO_1_D,
	GPIO_1_IN,

	SINE_OUT,
);

	 //=======================================================
	 //  PARAMETER declarations
	 //=======================================================

	 localparam ONE_SEC = 25000000; // one second in 25MHz clock cycles

	 reg [7:0] addr;
	 localparam toggle_1 = 25_000_000/440/256;
    reg [15:0] counter;
    input [7:0] SINE_OUT;
	 //=======================================================
	 //  PORT declarations
	 //=======================================================

	 //////////// CLOCK //////////
	 input 		          		CLOCK_50;

	 //////////// LED //////////
	 output		     [7:0]		LED;

	 /////////// KEY //////////
	 input 		     [1:0]		KEY;

	 //////////// SW //////////
	 input 		     [3:0]		SW;

	 //////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	 inout 		    [33:0]		GPIO_0_D;
	 input 		     [1:0]		GPIO_0_IN;

	 //////////// GPIO_0, GPIO_1 connect to GPIO Default //////////
	 inout 		    [33:0]		GPIO_1_D;
	 input 		     [1:0]		GPIO_1_IN;

    //=======================================================
    //  REG/WIRE declarations
    //=======================================================
   reg         CLOCK_25;
    wire        reset; // active high reset signal 

    wire [9:0]  PIXEL_COORD_X; // current x-coord from VGA driver
    wire [9:0]  PIXEL_COORD_Y; // current y-coord from VGA driver
    wire [7:0]  PIXEL_COLOR;   // input 8-bit pixel color for current coords
	 wire [1:0]  GRID_DATA; // the state of a grid
	 
	 
	 reg [24:0] led_counter; // timer to keep track of when to toggle LED
	 reg 			led_state;   // 1 is on, 0 is off
	 reg [1:0]  my_grid [3:0][4:0];
	 
	 
	 parameter [7:0] black = 8'b000_000_00,
						  green = 8'b000_111_00,
						  red   = 8'b111_000_00,
						  blue  = 8'b000_000_11;
	 
    // Module outputs coordinates of next pixel to be written onto screen
    VGA_DRIVER driver(
		  .RESET(reset),
        .CLOCK(CLOCK_25),
        .PIXEL_COLOR_IN(PIXEL_COLOR),
        .PIXEL_X(PIXEL_COORD_X),
        .PIXEL_Y(PIXEL_COORD_Y),
        .PIXEL_COLOR_OUT({GPIO_0_D[9],GPIO_0_D[11],GPIO_0_D[13],GPIO_0_D[15],GPIO_0_D[17],GPIO_0_D[19],GPIO_0_D[21],GPIO_0_D[23]}),
        .H_SYNC_NEG(GPIO_0_D[7]),
        .V_SYNC_NEG(GPIO_0_D[5])
    );
	 
	 
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
	 
	 
	 assign GRID_DATA = ((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][0] : ((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][1] : ((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][2] : ((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][3] : ((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][4] : 2'b0)))))))))))))));
	 assign PIXEL_COLOR = (GRID_DATA == 0 ? black : (GRID_DATA == 1 ? blue : (GRID_DATA == 2 ? green : red)));
	 
	 
	 assign LED[0] = led_state;
	 
    //=======================================================
    //  Structural coding
    //=======================================================

	 assign GPIO_1_D[19] = 0;
	 
	 SINE_WAVE sine(
			.ADDR_VALUE(addr),
			.CLOCK(CLOCK_25),
			.SINE_OUT({GPIO_1_D[0],GPIO_1_D[1],GPIO_1_D[3],GPIO_1_D[5],GPIO_1_D[7],GPIO_1_D[2],GPIO_1_D[4],GPIO_1_D[6]})
	 );
  
    always @(posedge CLOCK_25) begin
      if (counter == toggle_1) begin
        counter <= 0;
	     if (addr >= 255) addr <= 0;
		  else addr <= addr + 1;
	   end else
        counter <= counter + 1;
    end

	 // Generate 25MHz clock for VGA, FPGA has 50 MHz clock
    always @ (posedge CLOCK_50) begin
        CLOCK_25 <= ~CLOCK_25; 
    end // always @ (posedge CLOCK_50)	 
	 
	// Simple state machine to toggle LED0 every one second
	 always @ (posedge CLOCK_25) begin
		  if (reset) begin
				led_state   <= 1'b0;
				led_counter <= 25'b0;
		  end
		  
		  if (led_counter == ONE_SEC) begin
				led_state   <= ~led_state;
				led_counter <= 25'b0;
		  end
		  else begin	
				led_state   <= led_state;
				led_counter <= led_counter + 25'b1;
		  end // always @ (posedge CLOCK_25)
	 end
	 

endmodule