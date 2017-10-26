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
	 localparam toggle_2 = 25_000_000/660/256;
	 localparam toggle_3 = 25_000_000/220/256;
    reg [15:0] counter;
	 reg [25:0] sec_counter;
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
	 inout wire	  			  [33:0]		GPIO_1_D;
	 input 		     [1:0]		GPIO_1_IN;

    //=======================================================
    //  REG/WIRE declarations
    //=======================================================
    reg         CLOCK_25;
    wire        reset; // active high reset signal 
	 wire			 enable_sound; // if set, begin audio
	 wire	[8:0]  audio_out;
	 
    wire [9:0]  PIXEL_COORD_X; // current x-coord from VGA driver
    wire [9:0]  PIXEL_COORD_Y; // current y-coord from VGA driver
    wire [7:0]  PIXEL_COLOR;   // input 8-bit pixel color for current coords
	 wire [1:0]  GRID_DATA; // the state of a grid
	 
	 reg [1:0]  my_grid [3:0][4:0];
	 
	 reg [1:0] audio_state;
	 reg [1:0] next_audio_state;
	 wire [4:0] packet;
	 
	 parameter [7:0] black = 8'b000_000_00,
						  green = 8'b000_111_00,
						  red   = 8'b111_000_00,
						  blue  = 8'b000_000_11;
						  
	 parameter [1:0] unvisited = 2'b0o0,
	                 visited = 2'b01,
						  currentpos = 2'b10,
						  future = 2'b11;
						  
	 
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
	 
	 assign packet[0] = GPIO_0_D[29] 
	 assign packet[1] = GPIO_0_D[30]
	 assign packet[2] = GPIO_0_D[31]
	 assign packet[3] = GPIO_0_D[32]
	 assign packet[4] = GPIO_0_D[33]
	 
	 assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 always @(packet) begin
		my_grid[0][0] <=  (reset == 1) ? unvisited : ((packet == 5'b0) ? currentpos : ((my_grid[0][0]== currentpos) ? visited : my_grid[0][0]));
		my_grid[1][1] <= (reset == 1) ? unvisited : ((packet == 5'b00101) ? currentpos : ((my_grid[1][1]== currentpos) ? visited : my_grid[1][1]));
		my_grid[1][0] <= (reset == 1) ? unvisited : ((packet == 5'b00001) ? currentpos : ((my_grid[1][0]== currentpos) ? visited : my_grid[1][0]));
		my_grid[0][1] <= (reset == 1) ? unvisited : ((packet == 5'b00100) ? currentpos : ((my_grid[0][1]== currentpos) ? visited : my_grid[0][1]));
		my_grid[2][2] <= (reset == 1) ? unvisited : ((packet == 5'b01010) ? currentpos : ((my_grid[2][2]== currentpos) ? visited : my_grid[2][2]));
		my_grid[0][2] <= (reset == 1) ? unvisited : ((packet == 5'b01000) ? currentpos : ((my_grid[0][2]== currentpos) ? visited : my_grid[0][2]));
		my_grid[2][0] <= (reset == 1) ? unvisited : ((packet == 5'b00010) ? currentpos : ((my_grid[2][0]== currentpos) ? visited : my_grid[2][0]));
		my_grid[2][1] <= (reset == 1) ? unvisited : ((packet == 5'b00110) ? currentpos : ((my_grid[2][1]== currentpos) ? visited : my_grid[2][1]));
		my_grid[1][2] <= (reset == 1) ? unvisited : ((packet == 5'b01001) ? currentpos : ((my_grid[1][2]== currentpos) ? visited : my_grid[1][2]));
		my_grid[3][0] <= (reset == 1) ? unvisited : ((packet == 5'b00011) ? currentpos : ((my_grid[3][0]== currentpos) ? visited : my_grid[3][0]));
		my_grid[0][3] <= (reset == 1) ? unvisited : ((packet == 5'b01100) ? currentpos : ((my_grid[0][3]== currentpos) ? visited : my_grid[0][3]));
		my_grid[3][1] <= (reset == 1) ? unvisited : ((packet == 5'b00111) ? currentpos : ((my_grid[3][1]== currentpos) ? visited : my_grid[3][1]));
		my_grid[1][3] <= (reset == 1) ? unvisited : ((packet == 5'b01101) ? currentpos : ((my_grid[1][3]== currentpos) ? visited : my_grid[1][3]));
		my_grid[3][2] <= (reset == 1) ? unvisited : ((packet == 5'b01011) ? currentpos : ((my_grid[3][2]== currentpos) ? visited : my_grid[3][2]));
		my_grid[2][3] <= (reset == 1) ? unvisited : ((packet == 5'b01110) ? currentpos : ((my_grid[2][3]== currentpos) ? visited : my_grid[2][3]));
		my_grid[3][3] <= (reset == 1) ? unvisited : ((packet == 5'b01111) ? currentpos : ((my_grid[3][3]== currentpos) ? visited : my_grid[3][3]));
		my_grid[3][4] <= (reset == 1) ? unvisited : ((packet == 5'b10011) ? currentpos : ((my_grid[3][4]== currentpos) ? visited : my_grid[3][4]));
		my_grid[2][4] <= (reset == 1) ? unvisited : ((packet == 5'b10010) ? currentpos : ((my_grid[2][4]== currentpos) ? visited : my_grid[2][4]));
		my_grid[1][4] <= (reset == 1) ? unvisited : ((packet == 5'b10001) ? currentpos : ((my_grid[1][4]== currentpos) ? visited : my_grid[1][4]));
		my_grid[0][4] <= (reset == 1) ? unvisited : ((packet == 5'b10000) ? currentpos : ((my_grid[0][4]== currentpos) ? visited : my_grid[0][4]));
	end
	 
	 
	 assign GRID_DATA = ((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][0] : (((PIXEL_COORD_X <= 10'b0000110010) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][0] : ((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][1] : (((PIXEL_COORD_X <= 10'b0001100100) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][1] : ((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][2] : (((PIXEL_COORD_X <= 10'b0010010110) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][2] : ((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][3] : (((PIXEL_COORD_X <= 10'b0011001000) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][3] : ((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0000110010)) ? my_grid[0][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0001100100)) ? my_grid[1][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0010010110)) ? my_grid[2][4] : (((PIXEL_COORD_X <= 10'b0011111010) & (PIXEL_COORD_Y <= 10'b0011001000)) ? my_grid[3][4] : 2'b0)))))))))))))));
	 assign PIXEL_COLOR = (GRID_DATA == 0 ? red : (GRID_DATA == 1 ? blue : (GRID_DATA == 2 ? green : black)));
	 
	 
	 
	 
    //=======================================================
    //  AUDIO FSM
    //=======================================================

	  
	 SINE_WAVE sine(
			.ADDR_VALUE(addr),
			.CLOCK(CLOCK_25),
			.SINE_OUT(audio_out)
	 );
  
	
	 assign enable_sound = GPIO_0_D[30];
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
	
	 assign {GPIO_1_D[0],GPIO_1_D[1],GPIO_1_D[3],GPIO_1_D[5],GPIO_1_D[7],GPIO_1_D[2],GPIO_1_D[4],GPIO_1_D[6]} = (audio_state == 0) ? 8'b0 : audio_out;
	
	
	 // Generate 25MHz clock for VGA, FPGA has 50 MHz clock
    always @ (posedge CLOCK_50) begin
        CLOCK_25 <= ~CLOCK_25; 
    end // always @ (posedge CLOCK_50)	 
	 
	
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
	 
	 always @ (posedge CLOCK_25) begin
		audio_state <= next_audio_state;
	end
	 

endmodule
