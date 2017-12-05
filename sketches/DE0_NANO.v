//=======================================================
// ECE3400 Fall 2017
// Lab 3: Template top-level module
//
// Top-level skeleton from Terasic
// Modified by Claire Chen for ECE3400 Fall 2017
//=======================================================

`define ONE_SEC 25000000
`define QUA_SEC 6250000

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
	 localparam QUA_SEC = 6250000;
	 
	 reg [7:0] addr;
	 localparam toggle_b1 = 25_000_000/494/256;
	 localparam toggle_b2 = 25_000_000/494/256;
	 localparam toggle_c1 = 25_000_000/523/256;
	 localparam toggle_d1 = 25_000_000/587/256;
	 localparam toggle_d2 = 25_000_000/587/256;
	 localparam toggle_c2 = 25_000_000/523/256;
	 localparam toggle_b3 = 25_000_000/494/256;
	 localparam toggle_a1 = 25_000_000/440/256;
	 localparam toggle_g1 = 25_000_000/392/256;
	 localparam toggle_g2 = 25_000_000/392/256;
	 localparam toggle_a2 = 25_000_000/440/256;
	 localparam toggle_b4 = 25_000_000/494/256;
	 localparam toggle_a3 = 25_000_000/494/256;
	 localparam toggle_g3 = 25_000_000/440/256;
	 localparam toggle_g4 = 25_000_000/440/256;
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
	 inout wire	  	  [33:0]		GPIO_1_D;
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
	 wire [2:0]  GRID_DATA; // the state of a grid
	 
	 reg [2:0]   my_grid [11:0][9:0];
	 
	 reg [3:0]   audio_state;
	 reg [3:0]   next_audio_state;
	 wire [12:0] packet;
	 reg         done;
	 
	 
	 parameter [7:0] black = 8'b000_000_00,//unvisited
						  green = 8'b000_111_00,//currentpos
						  red   = 8'b111_000_00,//future
						  blue  = 8'b000_000_11,//visited
						  brown = 8'b111_111_00,//wall
						  white = 8'b111_111_11,//treasure1
						  cyan  = 8'b000_111_11,//treasure2
						  magenta = 8'b111_000_11;//treasure3
						  
	 parameter [2:0] unvisited = 3'b000,
	                 visited = 3'b001,
						  currentpos = 3'b010,
						  future = 3'b011,
						  wall = 3'b100,
						  treasure1 = 3'b101, //5
						  treasure2 = 3'b110, //6
						  treasure3 = 3'b111; //7
						  
	 
	 
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
	 
	 // From LSB to MSB, 5 bits for current pos, 3 bits for wall, 3 bit for treasure, 1 bit for done
	 
	 //					valid     treasure3  treasure2  treasure1    up wall   down wall   left wall   right wall    y_pos     x_pos
	 // packet bits     12    |    11    |    10    |     9     |     8    |     7     |     6     |     5     |   4-2   |   1-0   |
	 
	 assign packet[0] = GPIO_0_D[25];//x_pos LSB
	 assign packet[1] = GPIO_0_D[27];
	 assign packet[2] = GPIO_0_D[29];//y_pos LSB
	 assign packet[3] = GPIO_0_D[31];
	 assign packet[4] = GPIO_0_D[33];
	 assign packet[5] = GPIO_0_D[24];//right wall
	 assign packet[6] = GPIO_0_D[26];//left wall
	 assign packet[7] = GPIO_0_D[28];//down wall
	 assign packet[8] = GPIO_0_D[30];//up wall
	 assign packet[9] = GPIO_0_D[0];//treasure1
	 assign packet[10] = GPIO_0_D[1];//treasure2
	 assign packet[11] = GPIO_0_D[2];//treasure3
	 assign packet[12] = GPIO_0_D[32];//valid
	 //assign done = (packet[11:0] == 12'b111111111111);
	 //assign soundon = !done;
	 
	 assign reset = ~KEY[0]; // reset when KEY0 is pressed
	 always @(posedge CLOCK_25) begin 
		//done <= (packet[12:0] == 13'b011_11111_11111);
		if (packet[12] == 1 && packet[11:9] != 3'b111 ) begin//valid == 1 done == 0
			my_grid[11][9] <= unvisited;
			my_grid[0][0] <= wall;
			my_grid[0][1] <= wall;
			my_grid[0][2] <= wall;
			my_grid[0][3] <= wall;
			my_grid[0][4] <= wall;
			my_grid[0][5] <= wall;
			my_grid[0][6] <= wall;
			my_grid[0][7] <= wall;
			my_grid[0][8] <= wall;
			
			my_grid[1][0] <= wall;
			my_grid[2][0] <= wall;
			my_grid[3][0] <= wall;
			my_grid[4][0] <= wall;
			my_grid[5][0] <= wall;
			my_grid[6][0] <= wall;
			my_grid[7][0] <= wall;
			my_grid[8][0] <= wall;
			my_grid[9][0] <= wall;
			
			my_grid[10][0] <= wall;
			my_grid[10][1] <= wall;
			my_grid[10][2] <= wall;
			my_grid[10][3] <= wall;
			my_grid[10][4] <= wall;
			my_grid[10][5] <= wall;
			my_grid[10][6] <= wall;
			my_grid[10][7] <= wall;
			my_grid[10][8] <= wall;
			
			my_grid[1][8] <= wall;
			my_grid[2][8] <= wall;
			my_grid[3][8] <= wall;
			my_grid[4][8] <= wall;
			my_grid[5][8] <= wall;
			my_grid[6][8] <= wall;
			my_grid[7][8] <= wall;
			my_grid[8][8] <= wall;
			my_grid[9][8] <= wall;
			
			/*my_grid[1][1] <= currentpos;
			my_grid[3][1] <= currentpos;
			my_grid[5][1] <= currentpos;
			my_grid[7][1] <= currentpos;
			my_grid[9][1] <= currentpos;
			
			my_grid[1][3] <= visited;
			my_grid[3][3] <= visited;
			my_grid[5][3] <= visited;
			my_grid[7][3] <= visited;
			my_grid[9][3] <= visited;
			
			my_grid[1][5] <= treasure1;
			my_grid[3][5] <= treasure2;
			my_grid[5][5] <= treasure3;
			my_grid[7][5] <= future;
			my_grid[9][5] <= future;
			
			my_grid[1][7] <= visited;
			my_grid[3][7] <= visited;
			my_grid[5][7] <= visited;
			my_grid[7][7] <= visited;
			my_grid[9][7] <= visited;*/
			
			// path grid
			//(0,0)
			if (packet[4:0] != 5'b000_00 && my_grid[1][1] != currentpos && my_grid[1][1] != visited && my_grid[1][1] != treasure1 && my_grid[1][1] != treasure2 && my_grid[1][1] != treasure3)
				my_grid[1][1] <= unvisited;
			else if (packet[4:0] == 5'b000_00) begin
				if (packet[11:9] == 3'b000)
					my_grid[1][1] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[1][1] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[1][1] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[1][1] <= treasure3;
			end
			else if (packet[4:0] != 5'b000_00) begin
				if (my_grid[1][1] == treasure1)
					my_grid[1][1] <= treasure1;
				else if (my_grid[1][1] == treasure2)
					my_grid[1][1] <= treasure2;
				else if (my_grid[1][1] == treasure3)
					my_grid[1][1] <= treasure3;
				else my_grid[1][1] <= visited;
			end
			
			//(1,0)
			if (packet[4:0] != 5'b001_00 && my_grid[3][1] != currentpos && my_grid[3][1] != visited && my_grid[3][1] != treasure1 && my_grid[3][1] != treasure2 && my_grid[3][1] != treasure3)
				my_grid[3][1] <= unvisited;
			else if (packet[4:0] == 5'b001_00) begin
				if (packet[11:9] == 3'b000)
					my_grid[3][1] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[3][1] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[3][1] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[3][1] <= treasure3;
			end
			else if (packet[4:0] != 5'b001_00) begin
				if (my_grid[3][1] == treasure1)
					my_grid[3][1] <= treasure1;
				else if (my_grid[3][1] == treasure2)
					my_grid[3][1] <= treasure2;
				else if (my_grid[3][1] == treasure3)
					my_grid[3][1] <= treasure3;
				else my_grid[3][1] <= visited;
			end
			
			if (packet[4:0] == 5'b001_00) 
			  my_grid[3][2] <= visited;
			
			//(2,0)
			if (packet[4:0] != 5'b010_00 && my_grid[5][1] != currentpos && my_grid[5][1] != visited && my_grid[5][1] != treasure1 && my_grid[5][1] != treasure2 && my_grid[5][1] != treasure3)
				my_grid[5][1] <= unvisited;
			else if (packet[4:0] == 5'b010_00) begin
				if (packet[11:9] == 3'b000)
					my_grid[5][1] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[5][1] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[5][1] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[5][1] <= treasure3;
			end
			else if (packet[4:0] != 5'b010_00) begin
				if (my_grid[5][1] == treasure1)
					my_grid[5][1] <= treasure1;
				else if (my_grid[5][1] == treasure2)
					my_grid[5][1] <= treasure2;
				else if (my_grid[5][1] == treasure3)
					my_grid[5][1] <= treasure3;
				else my_grid[5][1] <= visited;
			end
			
			//(3,0)
			if (packet[4:0] != 5'b011_00 && my_grid[7][1] != currentpos && my_grid[7][1] != visited && my_grid[7][1] != treasure1 && my_grid[7][1] != treasure2 && my_grid[7][1] != treasure3)
				my_grid[7][1] <= unvisited;
			else if (packet[4:0] == 5'b011_00) begin
				if (packet[11:9] == 3'b000)
					my_grid[7][1] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[7][1] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[7][1] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[7][1] <= treasure3;
				else if (my_grid[7][1] == treasure1)
					my_grid[7][1] <= treasure1;
				else if (my_grid[7][1] == treasure2)
					my_grid[7][1] <= treasure2;
				else if (my_grid[7][1] == treasure3)
					my_grid[7][1] <= treasure3;
				else my_grid[7][1] <= visited;
			end
			else if (packet[4:0] != 5'b011_00) begin
				if (my_grid[7][1] == treasure1)
					my_grid[7][1] <= treasure1;
				else if (my_grid[7][1] == treasure2)
					my_grid[7][1] <= treasure2;
				else if (my_grid[7][1] == treasure3)
					my_grid[7][1] <= treasure3;
				else my_grid[7][1] <= visited;
			end
			
			//(4,0)
			if (packet[4:0] != 5'b100_00 && my_grid[9][1] != currentpos && my_grid[9][1] != visited && my_grid[9][1] != treasure1 && my_grid[9][1] != treasure2 && my_grid[9][1] != treasure3)
				my_grid[9][1] <= unvisited;
			else if (packet[4:0] == 5'b100_00) begin
				if (packet[11:9] == 3'b000)
					my_grid[9][1] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[9][1] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[9][1] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[9][1] <= treasure3;
			end
			else if (packet[4:0] != 5'b100_00) begin
				if (my_grid[9][1] == treasure1)
					my_grid[9][1] <= treasure1;
				else if (my_grid[9][1] == treasure2)
					my_grid[9][1] <= treasure2;
				else if (my_grid[9][1] == treasure3)
					my_grid[9][1] <= treasure3;
				else my_grid[9][1] <= visited;
			end
			
			//(0,1)
			if (packet[4:0] != 5'b000_01 && my_grid[1][3] != currentpos && my_grid[1][3] != visited && my_grid[1][3] != treasure1 && my_grid[1][3] != treasure2 && my_grid[1][3] != treasure3)
				my_grid[1][3] <= unvisited;
			else if (packet[4:0] == 5'b000_01) begin
				if (packet[11:9] == 3'b000)
					my_grid[1][3] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[1][3] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[1][3] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[1][3] <= treasure3;
			end
			else if (packet[4:0] != 5'b000_01) begin
				if (my_grid[1][3] == treasure1)
					my_grid[1][3] <= treasure1;
				else if (my_grid[1][3] == treasure2)
					my_grid[1][3] <= treasure2;
				else if (my_grid[1][3] == treasure3)
					my_grid[1][3] <= treasure3;
				else my_grid[1][3] <= visited;
			end
			
			//(1,1)
			if (packet[4:0] != 5'b001_01 && my_grid[3][3] != currentpos && my_grid[3][3] != visited && my_grid[3][3] != treasure1 && my_grid[3][3] != treasure2 && my_grid[3][3] != treasure3)
				my_grid[3][3] <= unvisited;
			else if (packet[4:0] == 5'b001_01) begin
				if (packet[11:9] == 3'b000)
					my_grid[3][3] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[3][3] <= currentpos;
				else if (packet[11:9] == 3'b010)
					my_grid[3][3] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[3][3] <= treasure3;
			end
			else if (packet[4:0] != 5'b001_01) begin
				if (my_grid[3][3] == treasure1)
					my_grid[3][3] <= treasure1;
				else if (my_grid[3][3] == treasure2)
					my_grid[3][3] <= treasure2;
				else if (my_grid[3][3] == treasure3)
					my_grid[3][3] <= treasure3;
				else my_grid[3][3] <= visited;
			end
			
			//(2,1)
			if (packet[4:0] != 5'b010_01 && my_grid[5][3] != currentpos && my_grid[5][3] != visited && my_grid[5][3] != treasure1 && my_grid[5][3] != treasure2 && my_grid[5][3] != treasure3)
				my_grid[5][3] <= unvisited;
			else if (packet[4:0] == 5'b010_01) begin
				if (packet[11:9] == 3'b000)
					my_grid[5][3] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[5][3] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[5][3] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[5][3] <= treasure3;
			end
			else if (packet[4:0] != 5'b010_01) begin
				if (my_grid[5][3] == treasure1)
					my_grid[5][3] <= treasure1;
				else if (my_grid[5][3] == treasure2)
					my_grid[5][3] <= treasure2;
				else if (my_grid[5][3] == treasure3)
					my_grid[5][3] <= treasure3;
				else my_grid[5][3] <= visited;
			end
			
			//(3,1)
			if (packet[4:0] != 5'b011_01 && my_grid[7][3] != currentpos && my_grid[7][3] != visited && my_grid[7][3] != treasure1 && my_grid[7][3] != treasure2 && my_grid[7][3] != treasure3)
				my_grid[7][3] <= unvisited;
			else if (packet[4:0] == 5'b011_01) begin
				if (packet[11:9] == 3'b000)
					my_grid[7][3] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[7][3] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[7][3] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[7][3] <= treasure3;
			end
			else if (packet[4:0] != 5'b011_01) begin
				if (my_grid[7][3] == treasure1)
					my_grid[7][3] <= treasure1;
				else if (my_grid[7][3] == treasure2)
					my_grid[7][3] <= treasure2;
				else if (my_grid[7][3] == treasure3)
					my_grid[7][3] <= treasure3;
				else my_grid[7][3] <= visited;
			end
			
			//(4,1)
			if (packet[4:0] != 5'b100_01 && my_grid[9][3] != currentpos && my_grid[9][3] != visited && my_grid[9][3] != treasure1 && my_grid[9][3] != treasure2 && my_grid[9][3] != treasure3)
				my_grid[9][3] <= unvisited;
			else if (packet[4:0] == 5'b100_01) begin
				if (packet[11:9] == 3'b000)
					my_grid[9][3] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[9][3] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[9][3] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[9][3] <= treasure3;
			end
			else if (packet[4:0] != 5'b100_01) begin
				if (my_grid[9][3] == treasure1)
					my_grid[9][3] <= treasure1;
				else if (my_grid[9][3] == treasure2)
					my_grid[9][3] <= treasure2;
				else if (my_grid[9][3] == treasure3)
					my_grid[9][3] <= treasure3;
				else my_grid[9][3] <= visited;
			end
			
			//(0,2)
			if (packet[4:0] != 5'b000_10 && my_grid[1][5] != currentpos && my_grid[1][5] != visited && my_grid[1][5] != treasure1 && my_grid[1][5] != treasure2 && my_grid[1][5] != treasure3)
				my_grid[1][5] <= unvisited;
			else if (packet[4:0] == 5'b000_10) begin
				if (packet[11:9] == 3'b000)
					my_grid[1][5] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[1][5] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[1][5] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[1][5] <= treasure3;
			end
			else if (packet[4:0] != 5'b000_10) begin
				if (my_grid[1][5] == treasure1)
					my_grid[1][5] <= treasure1;
				else if (my_grid[1][5] == treasure2)
					my_grid[1][5] <= treasure2;
				else if (my_grid[1][5] == treasure3)
					my_grid[1][5] <= treasure3;
				else my_grid[1][5] <= visited;
			end
			
			//(1,2)
			if (packet[4:0] != 5'b001_10 && my_grid[3][5] != currentpos && my_grid[3][5] != visited && my_grid[3][5] != treasure1 && my_grid[3][5] != treasure2 && my_grid[3][5] != treasure3)
				my_grid[3][5] <= unvisited;
			else if (packet[4:0] == 5'b001_10) begin
				if (packet[11:9] == 3'b000)
					my_grid[3][5] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[3][5] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[3][5] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[3][5] <= treasure3;
			end
			else if (packet[4:0] != 5'b001_10) begin
				if (my_grid[3][5] == treasure1)
					my_grid[3][5] <= treasure1;
				else if (my_grid[3][5] == treasure2)
					my_grid[3][5] <= treasure2;
				else if (my_grid[3][5] == treasure3)
					my_grid[3][5] <= treasure3;
				else my_grid[3][5] <= visited;
			end
			
			//(2,2)
			if (packet[4:0] != 5'b010_10 && my_grid[5][5] != currentpos && my_grid[5][5] != visited && my_grid[5][5] != treasure1 && my_grid[5][5] != treasure2 && my_grid[5][5] != treasure3)
				my_grid[5][5] <= unvisited;
			else if (packet[4:0] == 5'b010_10) begin
				if (packet[11:9] == 3'b000)
					my_grid[5][5] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[5][5] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[5][5] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[5][5] <= treasure3;
			end
			else if (packet[4:0] != 5'b010_10) begin
				if (my_grid[5][5] == treasure1)
					my_grid[5][5] <= treasure1;
				else if (my_grid[5][5] == treasure2)
					my_grid[5][5] <= treasure2;
				else if (my_grid[5][5] == treasure3)
					my_grid[5][5] <= treasure3;
				else my_grid[5][5] <= visited;
			end

			//(3,2)
			if (packet[4:0] != 5'b011_10 && my_grid[7][5] != currentpos && my_grid[7][5] != visited && my_grid[7][5] != treasure1 && my_grid[7][5] != treasure2 && my_grid[7][5] != treasure3)
				my_grid[7][5] <= unvisited;
			else if (packet[4:0] == 5'b011_10) begin
				if (packet[11:9] == 3'b000)
					my_grid[7][5] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[7][5] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[7][5] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[7][5] <= treasure3;
			end
			else if (packet[4:0] != 5'b011_10) begin
				if (my_grid[7][5] == treasure1)
					my_grid[7][5] <= treasure1;
				else if (my_grid[7][5] == treasure2)
					my_grid[7][5] <= treasure2;
				else if (my_grid[7][5] == treasure3)
					my_grid[7][5] <= treasure3;
				else my_grid[7][5] <= visited;
			end
			
			//(4,2)
			if (packet[4:0] != 5'b100_10 && my_grid[9][5] != currentpos && my_grid[9][5] != visited && my_grid[9][5] != treasure1 && my_grid[9][5] != treasure2 && my_grid[9][5] != treasure3)
				my_grid[9][5] <= unvisited;
			else if (packet[4:0] == 5'b100_10) begin
				if (packet[11:9] == 3'b000)
					my_grid[9][5] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[9][5] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[9][5] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[9][5] <= treasure3;
			end
			else if (packet[4:0] != 5'b100_10) begin
				if (my_grid[9][5] == treasure1)
					my_grid[9][5] <= treasure1;
				else if (my_grid[9][5] == treasure2)
					my_grid[9][5] <= treasure2;
				else if (my_grid[9][5] == treasure3)
					my_grid[9][5] <= treasure3;
				else my_grid[9][5] <= visited;
			end
			
			//(0,3)
			if (packet[4:0] != 5'b000_11 && my_grid[1][7] != currentpos && my_grid[1][7] != visited && my_grid[1][7] != treasure1 && my_grid[1][7] != treasure2 && my_grid[1][7] != treasure3)
				my_grid[1][7] <= unvisited;
			else if (packet[4:0] == 5'b000_11) begin
				if (packet[11:9] == 3'b000)
					my_grid[1][7] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[1][7] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[1][7] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[1][7] <= treasure3;
			end
			else if (packet[4:0] != 5'b000_11) begin
				if (my_grid[1][7] == treasure1)
					my_grid[1][7] <= treasure1;
				else if (my_grid[1][7] == treasure2)
					my_grid[1][7] <= treasure2;
				else if (my_grid[1][7] == treasure3)
					my_grid[1][7] <= treasure3;
				else my_grid[1][7] <= visited;
			end
			
			//(1,3)
			if (packet[4:0] != 5'b001_11 && my_grid[3][7] != currentpos && my_grid[3][7] != visited && my_grid[3][7] != treasure1 && my_grid[3][7] != treasure2 && my_grid[3][7] != treasure3)
				my_grid[3][7] <= unvisited;
			else if (packet[4:0] == 5'b001_11) begin
				if (packet[11:9] == 3'b000)
					my_grid[3][7] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[3][7] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[3][7] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[3][7] <= treasure3;
			end
			else if (packet[4:0] != 5'b001_11) begin
				if (my_grid[3][7] == treasure1)
					my_grid[3][7] <= treasure1;
				else if (my_grid[3][7] == treasure2)
					my_grid[3][7] <= treasure2;
				else if (my_grid[3][7] == treasure3)
					my_grid[3][7] <= treasure3;
				else my_grid[3][7] <= visited;
			end
			
			//(2,3)
			if (packet[4:0] != 5'b010_11 && my_grid[5][7] != currentpos && my_grid[5][7] != visited && my_grid[5][7] != treasure1 && my_grid[5][7] != treasure2 && my_grid[5][7] != treasure3)
				my_grid[5][7] <= unvisited;
			else if (packet[4:0] == 5'b010_11) begin
				if (packet[11:9] == 3'b000)
					my_grid[5][7] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[5][7] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[5][7] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[5][7] <= treasure3;
			end
			else if (packet[4:0] != 5'b010_11) begin
				if (my_grid[5][7] == treasure1)
					my_grid[5][7] <= treasure1;
				else if (my_grid[5][7] == treasure2)
					my_grid[5][7] <= treasure2;
				else if (my_grid[5][7] == treasure3)
					my_grid[5][7] <= treasure3;
				else my_grid[5][7] <= visited;
			end
			
			//(3,3)
			if (packet[4:0] != 5'b011_11 && my_grid[7][7] != currentpos && my_grid[7][7] != visited && my_grid[7][7] != treasure1 && my_grid[7][7] != treasure2 && my_grid[7][7] != treasure3)
				my_grid[7][7] <= unvisited;
			else if (packet[4:0] == 5'b011_11) begin
				if (packet[11:9] == 3'b000)
					my_grid[7][7] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[7][7] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[7][7] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[7][7] <= treasure3;
			end
			else if (packet[4:0] != 5'b011_11) begin
				if (my_grid[7][7] == treasure1)
					my_grid[7][7] <= treasure1;
				else if (my_grid[7][7] == treasure2)
					my_grid[7][7] <= treasure2;
				else if (my_grid[7][7] == treasure3)
					my_grid[7][7] <= treasure3;
				else my_grid[7][7] <= visited;
			end
			
			//(4,3)
			if (packet[4:0] != 5'b100_11 && my_grid[9][7] != currentpos && my_grid[9][7] != visited && my_grid[9][7] != treasure1 && my_grid[9][7] != treasure2 && my_grid[9][7] != treasure3)
				my_grid[9][7] <= unvisited;
			else if (packet[4:0] == 5'b100_11) begin
				if (packet[11:9] == 3'b000)
					my_grid[9][7] <= currentpos;
				else if (packet[11:9] == 3'b001)
					my_grid[9][7] <= treasure1;
				else if (packet[11:9] == 3'b010)
					my_grid[9][7] <= treasure2;
				else if (packet[11:9] == 3'b100)
					my_grid[9][7] <= treasure3;
			end
			else if (packet[4:0] != 5'b100_11) begin
				if (my_grid[9][7] == treasure1)
					my_grid[9][7] <= treasure1;
				else if (my_grid[9][7] == treasure2)
					my_grid[9][7] <= treasure2;
				else if (my_grid[9][7] == treasure3)
					my_grid[9][7] <= treasure3;
				else my_grid[9][7] <= visited;
			end

			
			
			
			
			// wall grid
			//wall (2,1) based on (0,0), (1,0) (using different coordiate system between (2,1) and (0,0))
			if (!(packet[4:0] == 5'b000_00 || packet[4:0] == 5'b001_00) && my_grid [2][1] != wall && my_grid [2][1] != visited)
				my_grid [2][1] <= unvisited;
			else if ((packet[4:0] == 5'b000_00 || packet[4:0] == 5'b001_00) && my_grid [2][1] != wall && my_grid [2][1] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b000_00) || (packet[7] == 1'b1 && packet[4:0] == 5'b001_00))
					my_grid [2][1] <= wall;
				else
					my_grid [2][1] <= visited;
			end			
			
			//wall (4,1) based on (1,0), (2,0)
			if (!(packet[4:0] == 5'b001_00 || packet[4:0] == 5'b010_00) && my_grid [4][1] != wall && my_grid [4][1] != visited)
				my_grid [4][1] <= unvisited;
			else if ((packet[4:0] == 5'b001_00 || packet[4:0] == 5'b010_00) && my_grid [4][1] != wall && my_grid [4][1] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b001_00) || (packet[7] == 1'b1 && packet[4:0] == 5'b010_00))
					my_grid [4][1] <= wall;
				else
					my_grid [4][1] <= visited;
			end
			
			//wall (6,1) based on (2,0), (3,0)
			if (!(packet[4:0] == 5'b010_00 || packet[4:0] == 5'b011_00) && my_grid [6][1] != wall && my_grid [6][1] != visited)
				my_grid [6][1] <= unvisited;
			else if ((packet[4:0] == 5'b010_00 || packet[4:0] == 5'b011_00) && my_grid [6][1] != wall && my_grid [6][1] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b010_00) || (packet[7] == 1'b1 && packet[4:0] == 5'b011_00))
					my_grid [6][1] <= wall;
				else
					my_grid [6][1] <= visited;
			end
			
			//wall (8,1) based on (3,0), (4,0)
			if (!(packet[4:0] == 5'b011_00 || packet[4:0] == 5'b100_00) && my_grid [8][1] != wall && my_grid [8][1] != visited)
				my_grid [8][1] <= unvisited;
			else if ((packet[4:0] == 5'b011_00 || packet[4:0] == 5'b100_00) && my_grid [8][1] != wall && my_grid [8][1] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b011_00) || (packet[7] == 1'b1 && packet[4:0] == 5'b100_00))
					my_grid [8][1] <= wall;
				else
					my_grid [8][1] <= visited;
			end

			//wall (2,3) based on (0,1), (1,1)
			if (!(packet[4:0] == 5'b000_01 || packet[4:0] == 5'b001_01) && my_grid [2][3] != wall && my_grid [2][3] != visited)
				my_grid [2][3] <= unvisited;
			else if ((packet[4:0] == 5'b000_01 || packet[4:0] == 5'b001_01) && my_grid [2][3] != wall && my_grid [2][3] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b000_01) || (packet[7] == 1'b1 && packet[4:0] == 5'b001_01))
					my_grid [2][3] <= wall;
				else
					my_grid [2][3] <= visited;
			end
			
			//wall (4,3) based on (1,1), (2,1)
			if (!(packet[4:0] == 5'b001_01 || packet[4:0] == 5'b010_01) && my_grid [4][3] != wall && my_grid [4][3] != visited)
				my_grid [4][3] <= unvisited;
			else if ((packet[4:0] == 5'b001_01 || packet[4:0] == 5'b010_01) && my_grid [4][3] != wall && my_grid [4][3] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b001_01) || (packet[7] == 1'b1 && packet[4:0] == 5'b010_01))
					my_grid [4][3] <= wall;
				else
					my_grid [4][3] <= visited;
			end
			
			//wall (6,3) based on (2,1), (3,1)
			if (!(packet[4:0] == 5'b010_01 || packet[4:0] == 5'b011_01) && my_grid [6][3] != wall && my_grid [6][3] != visited)
				my_grid [6][3] <= unvisited;
			else if ((packet[4:0] == 5'b010_01 || packet[4:0] == 5'b011_01) && my_grid [6][3] != wall && my_grid [6][3] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b010_01) || (packet[7] == 1'b1 && packet[4:0] == 5'b011_01))
					my_grid [6][3] <= wall;
				else
					my_grid [6][3] <= visited;
			end
			
			//wall (8,3) based on (3,1), (4,1)
			if (!(packet[4:0] == 5'b011_01 || packet[4:0] == 5'b100_01) && my_grid [8][3] != wall && my_grid [8][3] != visited)
				my_grid [8][3] <= unvisited;
			else if ((packet[4:0] == 5'b011_01 || packet[4:0] == 5'b100_01) && my_grid [8][3] != wall && my_grid [8][3] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b011_01) || (packet[7] == 1'b1 && packet[4:0] == 5'b100_01))
					my_grid [8][3] <= wall;
				else
					my_grid [8][3] <= visited;
			end
			
			//wall (2,5) based on (0,2), (1,2)
			if (!(packet[4:0] == 5'b000_10 || packet[4:0] == 5'b001_10) && my_grid [2][5] != wall && my_grid [2][5] != visited)
				my_grid [2][5] <= unvisited;
			else if ((packet[4:0] == 5'b000_10 || packet[4:0] == 5'b001_10) && my_grid [2][5] != wall && my_grid [2][5] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b000_10) || (packet[7] == 1'b1 && packet[4:0] == 5'b001_10))
					my_grid [2][5] <= wall;
				else
					my_grid [2][5] <= visited;
			end
			
			//wall (4,5) based on (1,2), (2,2)
			if (!(packet[4:0] == 5'b001_10 || packet[4:0] == 5'b010_10) && my_grid [4][5] != wall && my_grid [4][5] != visited)
				my_grid [4][5] <= unvisited;
			else if ((packet[4:0] == 5'b001_10 || packet[4:0] == 5'b010_10) && my_grid [4][5] != wall && my_grid [4][5] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b001_10) || (packet[7] == 1'b1 && packet[4:0] == 5'b010_10))
					my_grid [4][5] <= wall;
				else
					my_grid [4][5] <= visited;
			end
			
			//wall (6,5) based on (2,2), (3,2)
			if (!(packet[4:0] == 5'b010_10 || packet[4:0] == 5'b011_10) && my_grid [6][5] != wall && my_grid [6][5] != visited)
				my_grid [6][5] <= unvisited;
			else if ((packet[4:0] == 5'b010_10 || packet[4:0] == 5'b011_10) && my_grid [6][5] != wall && my_grid [6][5] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b010_10) || (packet[7] == 1'b1 && packet[4:0] == 5'b011_10))
					my_grid [6][5] <= wall;
				else
					my_grid [6][5] <= visited;
			end
			
			//wall (8,5) based on (3,2), (4,2)
			if (!(packet[4:0] == 5'b011_10 || packet[4:0] == 5'b100_10) && my_grid [8][5] != wall && my_grid [8][5] != visited)
				my_grid [8][5] <= unvisited;
			else if ((packet[4:0] == 5'b011_10 || packet[4:0] == 5'b100_10) && my_grid [8][5] != wall && my_grid [8][5] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b011_10) || (packet[7] == 1'b1 && packet[4:0] == 5'b100_10))
					my_grid [8][5] <= wall;
				else
					my_grid [8][5] <= visited;
			end
			
			//wall (2,7) based on (0,3), (1,3)
			if (!(packet[4:0] == 5'b000_11 || packet[4:0] == 5'b001_11) && my_grid [2][7] != wall && my_grid [2][7] != visited)
				my_grid [2][7] <= unvisited;
			else if ((packet[4:0] == 5'b000_11 || packet[4:0] == 5'b001_11) && my_grid [2][7] != wall && my_grid [2][7] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b000_11) || (packet[7] == 1'b1 && packet[4:0] == 5'b001_11))
					my_grid [2][7] <= wall;
				else
					my_grid [2][7] <= visited;
			end
			
			//wall (4,7) based on (1,3), (2,3)
			if (!(packet[4:0] == 5'b001_11 || packet[4:0] == 5'b010_11) && my_grid [4][7] != wall && my_grid [4][7] != visited)
				my_grid [4][7] <= unvisited;
			else if ((packet[4:0] == 5'b001_11 || packet[4:0] == 5'b010_11) && my_grid [4][7] != wall && my_grid [4][7] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b001_11) || (packet[7] == 1'b1 && packet[4:0] == 5'b010_11))
					my_grid [4][7] <= wall;
				else
					my_grid [4][7] <= visited;
			end
			
			//wall (6,7) based on (2,3), (3,3)
			if (!(packet[4:0] == 5'b010_11 || packet[4:0] == 5'b011_11) && my_grid [6][7] != wall && my_grid [6][7] != visited)
				my_grid [6][7] <= unvisited;
			else if ((packet[4:0] == 5'b010_11 || packet[4:0] == 5'b011_11) && my_grid [6][7] != wall && my_grid [6][7] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b010_11) || (packet[7] == 1'b1 && packet[4:0] == 5'b011_11))
					my_grid [6][7] <= wall;
				else
					my_grid [6][7] <= visited;
			end
			
			//wall (8,7) based on (3,3), (4,3)
			if (!(packet[4:0] == 5'b011_11 || packet[4:0] == 5'b100_11) && my_grid [8][7] != wall && my_grid [8][7] != visited)
				my_grid [8][7] <= unvisited;
			else if ((packet[4:0] == 5'b011_11 || packet[4:0] == 5'b100_11) && my_grid [8][7] != wall && my_grid [8][7] != visited) begin
				if ((packet[8] == 1'b1 && packet[4:0] == 5'b011_11) || (packet[7] == 1'b1 && packet[4:0] == 5'b100_11))
					my_grid [8][7] <= wall;
				else
					my_grid [8][7] <= visited;
			end
			
			//wall (1,2) based on (0,0), (0,1)
			if (!(packet[4:0] == 5'b000_00 || packet[4:0] == 5'b000_01) && my_grid[1][2] != wall && my_grid[1][2] != visited)
				my_grid[1][2] <= unvisited;
			else if ((packet[4:0] == 5'b000_00 || packet[4:0] == 5'b000_01) && my_grid[1][2] != wall && my_grid[1][2] != visited) begin
				if ((packet[4:0] == 5'b000_00 && packet[5]==1'b1) || (packet[4:0]==5'b000_01 && packet[6]==1'b1))
					my_grid[1][2] <= wall;
				else
					my_grid[1][2] <= visited;
			end
			
			//wall (3,2) based on (1,0), (1,1)
			if (!(packet[4:0] == 5'b001_00 || packet[4:0] == 5'b001_01) && my_grid[3][2] != wall && my_grid[3][2] != visited)
				my_grid[3][2] <= unvisited;
			else if ((packet[4:0] == 5'b001_00 || packet[4:0] == 5'b001_01) && my_grid[3][2] != wall && my_grid[3][2] != visited) begin
				if ((packet[4:0] == 5'b001_00 && packet[5]==1'b1) || (packet[4:0]==5'b001_01 && packet[6]==1'b1))
					my_grid[3][2] <= wall;
				else
					my_grid[3][2] <= visited;
			end
			
			//wall (5,2) based on (2,0), (2,1)
			if (!(packet[4:0] == 5'b010_00 || packet[4:0] == 5'b010_01) && my_grid[5][2] != wall && my_grid[5][2] != visited)
				my_grid[5][2] <= unvisited;
			else if ((packet[4:0] == 5'b010_00 || packet[4:0] == 5'b010_01) && my_grid[5][2] != wall && my_grid[5][2] != visited) begin
				if ((packet[4:0] == 5'b010_00 && packet[5]==1'b1) || (packet[4:0] == 5'b010_01 && packet[6]==1'b1))
					my_grid[5][2] <= wall;
				else
					my_grid [5][2] <= visited;
			end
			
			//wall (7,2) based on (3,0), (3,1)
			if (!(packet[4:0] == 5'b011_00 || packet[4:0] == 5'b011_01) && my_grid [7][2] != wall && my_grid [7][2] != visited)
				my_grid [7][2] <= unvisited;
			else if ((packet[4:0] == 5'b011_00 || packet[4:0] == 5'b011_01) && my_grid [7][2] != wall && my_grid [7][2] != visited) begin
				if ((packet[4:0] == 5'b011_00 && packet[5]==1'b1) || (packet[4:0] == 5'b011_01 && packet[6]==1'b1))
					my_grid [7][2] <= wall;
				else
					my_grid [7][2] <= visited;
			end
			
			//wall (9,2) based on (4,0), (4,1)
			if (!(packet[4:0] == 5'b100_00 || packet[4:0] == 5'b100_01) && my_grid [9][2] != wall && my_grid [9][2] != visited)
				my_grid [9][2] <= unvisited;
			else if ((packet[4:0] == 5'b100_00 || packet[4:0] == 5'b100_01) && my_grid [9][2] != wall && my_grid [9][2] != visited) begin
				if ((packet[4:0] == 5'b100_00 && packet[5]==1'b1) || (packet[4:0] == 5'b100_01 && packet[6]==1'b1))
					my_grid [9][2] <= wall;
				else
					my_grid [9][2] <= visited;
			end
			
			//wall (1,4) based on (0,1), (0,2)
			if (!(packet[4:0] == 5'b000_01 || packet[4:0] == 5'b000_10) && my_grid [1][4] != wall && my_grid [1][4] != visited)
				my_grid [1][4] <= unvisited;
			else if ((packet[4:0] == 5'b000_01 || packet[4:0] == 5'b000_10) && my_grid [1][4] != wall && my_grid [1][4] != visited) begin
				if ((packet[4:0] == 5'b000_01 && packet[5]==1'b1) || (packet[4:0] == 5'b000_10 && packet[6]==1'b1))
					my_grid [1][4] <= wall;
				else
					my_grid [1][4] <= visited;
			end
			
			//wall (3,4) based on (1,1), (1,2)
			if (!(packet[4:0] == 5'b001_01 || packet[4:0] == 5'b001_10) && my_grid [3][4] != wall && my_grid [3][4] != visited)
				my_grid [3][4] <= unvisited;
			else if ((packet[4:0] == 5'b001_01 || packet[4:0] == 5'b001_10) && my_grid [3][4] != wall && my_grid [3][4] != visited) begin
				if ((packet[4:0] == 5'b001_01 && packet[5]==1'b1) || (packet[4:0] == 5'b001_10 && packet[6]==1'b1))
					my_grid [3][4] <= wall;
				else
					my_grid [3][4] <= visited;
			end
			
			//wall (5,4) based on (2,1), (2,2)
			if (!(packet[4:0] == 5'b010_01 || packet[4:0] == 5'b010_10) && my_grid [5][4] != wall && my_grid [5][4] != visited)
				my_grid [5][4] <= unvisited;
			else if ((packet[4:0] == 5'b010_01 || packet[4:0] == 5'b010_10) && my_grid [5][4] != wall && my_grid [5][4] != visited) begin
				if ((packet[4:0] == 5'b010_01 && packet[5]==1'b1) || (packet[4:0] == 5'b010_10 && packet[6]==1'b1))
					my_grid [5][4] <= wall;
				else
					my_grid [5][4] <= visited;
			end
			
			//wall (7,4) based on (3,1), (3,2)
			if (!(packet[4:0] == 5'b011_01 || packet[4:0] == 5'b011_10) && my_grid [7][4] != wall && my_grid [7][4] != visited)
				my_grid [7][4] <= unvisited;
			else if ((packet[4:0] == 5'b011_01 || packet[4:0] == 5'b011_10) && my_grid [7][4] != wall && my_grid [7][4] != visited) begin
				if ((packet[4:0] == 5'b011_01 && packet[5]==1'b1) || (packet[4:0] == 5'b011_10 && packet[6]==1'b1))
					my_grid [7][4] <= wall;
				else
					my_grid [7][4] <= visited;
			end
			
			//wall (9,4) based on (4,1), (4,2)
			if (!(packet[4:0] == 5'b100_01 || packet[4:0] == 5'b100_10) && my_grid [9][4] != wall && my_grid [9][4] != visited)
				my_grid [9][4] <= unvisited;
			else if ((packet[4:0] == 5'b100_01 || packet[4:0] == 5'b100_10) && my_grid [9][4] != wall && my_grid [9][4] != visited) begin
				if ((packet[4:0] == 5'b100_01 && packet[5]==1'b1) || (packet[4:0] == 5'b100_10 && packet[6]==1'b1))
					my_grid [9][4] <= wall;
				else
					my_grid [9][4] <= visited;
			end
			
			//wall (1,6) based on (0,2), (0,3)
			if (!(packet[4:0] == 5'b000_10 || packet[4:0] == 5'b000_11) && my_grid [1][6] != wall && my_grid [1][6] != visited)
				my_grid [1][6] <= unvisited;
			else if ((packet[4:0] == 5'b000_10 || packet[4:0] == 5'b000_11) && my_grid [1][6] != wall && my_grid [1][6] != visited) begin
				if ((packet[4:0] == 5'b000_10 && packet[5]==1'b1) || (packet[4:0] == 5'b000_11 && packet[6]==1'b1))
					my_grid [1][6] <= wall;
				else
					my_grid [1][6] <= visited;
			end
			
			//wall (3,6) based on (1,2), (1,3)
			if (!(packet[4:0] == 5'b001_10 || packet[4:0] == 5'b001_11) && my_grid [3][6] != wall && my_grid [3][6] != visited)
				my_grid [3][6] <= unvisited;
			else if ((packet[4:0] == 5'b001_10 || packet[4:0] == 5'b001_11) && my_grid [3][6] != wall && my_grid [3][6] != visited) begin
				if ((packet[4:0] == 5'b001_10 && packet[5]==1'b1) || (packet[4:0] == 5'b001_11 && packet[6]==1'b1))
					my_grid [3][6] <= wall;
				else
					my_grid [3][6] <= visited;
			end
			
			//wall (5,6) based on (2,2), (2,3)
			if (!(packet[4:0] == 5'b010_10 || packet[4:0] == 5'b010_11) && my_grid [5][6] != wall && my_grid [5][6] != visited)
				my_grid [5][6] <= unvisited;
			else if ((packet[4:0] == 5'b010_10 || packet[4:0] == 5'b010_11) && my_grid [5][6] != wall && my_grid [5][6] != visited) begin
				if ((packet[4:0] == 5'b010_10 && packet[5]==1'b1) || (packet[4:0] == 5'b010_11 && packet[6]==1'b1))
					my_grid [5][6] <= wall;
				else
					my_grid [5][6] <= visited;
			end
			
			//wall (7,6) based on (3,2), (3,3)
			if (!(packet[4:0] == 5'b011_10 || packet[4:0] == 5'b011_11) && my_grid [7][6] != wall && my_grid [7][6] != visited)
				my_grid [7][6] <= unvisited;
			else if ((packet[4:0] == 5'b011_10 || packet[4:0] == 5'b011_11) && my_grid [7][6] != wall && my_grid [7][6] != visited) begin
				if ((packet[4:0] == 5'b011_10 && packet[5]==1'b1) || (packet[4:0] == 5'b011_11 && packet[6]==1'b1))
					my_grid [7][6] <= wall;
				else
					my_grid [7][6] <= visited;
			end
			
			//wall (9,6) based on (4,2), (4,3)
			if (!(packet[4:0] == 5'b100_10 || packet[4:0] == 5'b100_11) && my_grid [9][6] != wall && my_grid [9][6] != visited)
				my_grid [9][6] <= unvisited;
			else if ((packet[4:0] == 5'b100_10 || packet[4:0] == 5'b100_11) && my_grid [9][6] != wall && my_grid [9][6] != visited) begin
				if ((packet[4:0] == 5'b100_10 && packet[5]==1'b1) || (packet[4:0] == 5'b100_11 && packet[6]==1'b1))
					my_grid [9][6] <= wall;
				else
					my_grid [9][6] <= visited;
			end
		end
		
		else if ( packet[12] == 1 && packet[11:9] == 3'b111 ) begin
			my_grid[11][9] <= future;
			if (my_grid[1][1] == unvisited)
				my_grid[1][1] <= future;
			if (my_grid[3][1] == unvisited)
				my_grid[3][1] <= future;
			if (my_grid[5][1] == unvisited)
				my_grid[5][1] <= future;
			if (my_grid[7][1] == unvisited)
				my_grid[7][1] <= future;
			if (my_grid[9][1] == unvisited)
				my_grid[9][1] <= future;
				
			if (my_grid[1][3] == unvisited)
				my_grid[1][3] <= future;
			if (my_grid[3][3] == unvisited)
				my_grid[3][3] <= future;
			if (my_grid[5][3] == unvisited)
				my_grid[5][3] <= future;
			if (my_grid[7][3] == unvisited)
				my_grid[7][3] <= future;
			if (my_grid[9][3] == unvisited)
				my_grid[9][3] <= future;
			
			if (my_grid[1][5] == unvisited)
				my_grid[1][5] <= future;
			if (my_grid[3][5] == unvisited)
				my_grid[3][5] <= future;
			if (my_grid[5][5] == unvisited)
				my_grid[5][5] <= future;
			if (my_grid[7][5] == unvisited)
				my_grid[7][5] <= future;
			if (my_grid[9][5] == unvisited)
				my_grid[9][5] <= future;
				
			if (my_grid[1][7] == unvisited)
				my_grid[1][7] <= future;
			if (my_grid[3][7] == unvisited)
				my_grid[3][7] <= future;
			if (my_grid[5][7] == unvisited)
				my_grid[5][7] <= future;
			if (my_grid[7][7] == unvisited)
				my_grid[7][7] <= future;
			if (my_grid[9][7] == unvisited)
				my_grid[9][7] <= future;
		end
	end
	 
	 assign GRID_DATA =  ((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][0] : 
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][0] : 
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][0] : 
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][0] : 
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][0] :
							  (((PIXEL_COORD_X <= 10'b0000000101) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][0] :
							  
							   ((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][1] : 
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][1] : 
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][1] : 
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][1] : 
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][1] :
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][1] :
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][1] :
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][1] :
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][1] : 
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][1] :
							  (((PIXEL_COORD_X <= 10'b0000110000) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][1] :
							  
							   ((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][2] : 
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][2] : 
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][2] : 
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][2] : 
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][2] :
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][2] :
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][2] :
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][2] :
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][2] : 
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][2] :
							  (((PIXEL_COORD_X <= 10'b0000110100) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][2] :
							  
							   ((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][3] :
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][3] :
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][3] :
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][3] : 
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][3] :
							  (((PIXEL_COORD_X <= 10'b0001100010) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][3] :
							  
							   ((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][4] : 
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][4] : 
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][4] : 
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][4] : 
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][4] :
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][4] :
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][4] :
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][4] :
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][4] : 
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][4] :
							  (((PIXEL_COORD_X <= 10'b0001100110) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][4] :
							  
							   ((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][5] : 
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][5] : 
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][5] : 
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][5] : 
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][5] :
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][5] :
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][5] :
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][5] :
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][5] : 
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][5] :
							  (((PIXEL_COORD_X <= 10'b0010010100) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][5] :
							  
							   ((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][6] : 
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][6] : 
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][6] : 
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][6] : 
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][6] :
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][6] :
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][6] :
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][6] :
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][6] : 
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][6] :
							  (((PIXEL_COORD_X <= 10'b0010011000) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][6] :
							  
							   ((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][7] : 
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][7] : 
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][7] : 
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][7] : 
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][7] :
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][7] :
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][7] :
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][7] :
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][7] : 
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][7] :
							  (((PIXEL_COORD_X <= 10'b0011000110) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][7] :
							  
							   ((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0000000101)) ? my_grid[10][8] : 
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0000110000)) ? my_grid[9][8] : 
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0000110100)) ? my_grid[8][8] : 
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0001100010)) ? my_grid[7][8] : 
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0001100110)) ? my_grid[6][8] :
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0010010100)) ? my_grid[5][8] :
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0010011000)) ? my_grid[4][8] :
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0011000110)) ? my_grid[3][8] :
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0011001010)) ? my_grid[2][8] : 
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0011110101)) ? my_grid[1][8] :
							  (((PIXEL_COORD_X <= 10'b0011001010) & (PIXEL_COORD_Y <= 10'b0011111010)) ? my_grid[0][8] : 
							  (((PIXEL_COORD_X <= 10'b0011111000) & (PIXEL_COORD_Y <= 10'b0100101010)) ? my_grid[11][9] :
							  3'b0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))));
	 
	 assign PIXEL_COLOR = (GRID_DATA == 0 ? black : (GRID_DATA == 1 ? cyan : (GRID_DATA == 2 ? magenta : (GRID_DATA == 3 ? white :
								(GRID_DATA == 4 ? brown : (GRID_DATA == 5 ? red : (GRID_DATA == 6 ? green : blue)))))));
	 
	 /*parameter [7:0] black = 8'b000_000_00,//unvisited
						  green = 8'b000_111_00,//currentpos
						  red   = 8'b111_000_00,//future
						  blue  = 8'b000_000_11,//visited
						  brown = 8'b111_111_00,//wall
						  white = 8'b111_111_11,//treasure1
						  cyan  = 8'b000_111_11,//treasure2
						  magenta = 8'b111_000_11;//treasure3
						  
	 parameter [2:0] unvisited = 3'b000,
	                 visited = 3'b001, cyan
						  currentpos = 3'b010, magenta
						  future = 3'b011, white
						  wall = 3'b100,
						  treasure1 = 3'b101, //5 red 
						  treasure2 = 3'b110, //6 green
						  treasure3 = 3'b111; //7 blue */
	 
    //=======================================================
    //  AUDIO FSM
    //=======================================================

	  
	 SINE_WAVE sine(
			.ADDR_VALUE(addr),
			.CLOCK(CLOCK_25),
			.SINE_OUT(audio_out)
	 );
  
	
	 assign enable_sound = GPIO_1_D[30];
    always @(posedge CLOCK_25) begin
	 if (packet[11:9] == 3'b111) begin
		if (audio_state == 1) begin
			if (counter == toggle_b1) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 2) begin
			if (counter == toggle_b2) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 3) begin
			if (counter == toggle_c1) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 4) begin
			if (counter == toggle_d1) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 5) begin
			if (counter == toggle_d2) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 6) begin
			if (counter == toggle_c2) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 7) begin
			if (counter == toggle_b3) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 8) begin
			if (counter == toggle_a1) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 9) begin
			if (counter == toggle_g1) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 10) begin
			if (counter == toggle_g2) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 11) begin
			if (counter == toggle_a2) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 12) begin
			if (counter == toggle_b4) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 13) begin
			if (counter == toggle_a3) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 14) begin
			if (counter == toggle_g3) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
		if (audio_state == 15) begin
			if (counter == toggle_g4) begin
				counter <= 0;
				if (addr >= 255) addr <= 0;
				else addr <= addr + 1;
			end else
				counter <= counter + 1;
		end
	end
	end
	
	 assign {GPIO_1_D[0],GPIO_1_D[1],GPIO_1_D[3],GPIO_1_D[5],GPIO_1_D[7],GPIO_1_D[2],GPIO_1_D[4],GPIO_1_D[6]} = (audio_state == 0) ? 8'b0 : audio_out;
	
	
	 // Generate 25MHz clock for VGA, FPGA has 50 MHz clock
    always @ (posedge CLOCK_50) begin
        CLOCK_25 <= ~CLOCK_25; 
    end // always @ (posedge CLOCK_50)	 
	 
	
	 always @ (posedge CLOCK_25) begin
	 if (packet[11:9] == 3'b111) begin
		 if (audio_state == 0) begin
			if (enable_sound == 1)
				next_audio_state <= 4'b1;
			else
				next_audio_state <= 4'b0;
		 end 
		 else begin 
			if (enable_sound == 0)
				next_audio_state <= 4'b0;
			else begin
				if (sec_counter == QUA_SEC) begin
					sec_counter <= 0;
					if (audio_state == 15) 
						next_audio_state <= 1;
					else
						next_audio_state <= audio_state + 4'b1;
				end 
				else begin
					sec_counter <= sec_counter + 4'b1;
					next_audio_state <= audio_state;
				end
		  end
		end
	 end
	 end
	 
	 always @ (posedge CLOCK_25) begin
		audio_state <= next_audio_state;
	end
	 

endmodule
