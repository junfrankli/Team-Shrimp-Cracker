//FSM to generate tune

`define ONE_SEC 25000000

module (
  CLOCK, 
  RESET, 
  SET, 
  SOUND_OUT
);

  input CLOCK;
  input RESET;
  input SET;
  output [7:0] SOUND_OUT;

  localparam S_INIT  = 2'd0;
  localparam S_TUNE1 = 2'd1;
  localparam S_TUNE2 = 2'd2;
  localparam S_TUNE3 = 2'd3;
  localparam FREQ_1 = 10'd440;
  localparam FREQ_2 = 10'd500;
  localparam FREQ_3 = 10'd520;
  
  reg [9:0] sound_freq;
  reg [1:0] STATE;
  reg [1:0] NEXT_STATE;
  reg [27:0] counter; 
  wire [7:0] sine_out;
  
  SINE_WAVE sine (
		.TIME(counter),
		.FREQUENCY(sound_freq),
		.SINE(sine_out)
  );
  
  always @(posedge CLOCK) begin
		if (RESET) begin
			STATE <= S_INIT;
		end else begin
			STATE <= NEXT_STATE;
		end
	end
  
  //NEXT STATE LOGIC
  always @(posedge CLOCK) begin
		if (SET) begin
			NEXT_STATE <= S_TUNE1;
		end else if (tune_counter == `ONE_SEC) begin
			if (STATE == 1)
				NEXT_STATE <= S_TUNE2;
			else if (STATE == 2)
				NEXT_STATE <= S_TUNE3;
			else if (STATE ==3)
				NEXT_STATE <= S_TUNE1;
		end else begin
			NEXT_STATE <= STATE;
		end
	end
	
	//OUTPUT LOGIC
	always @(posedge CLOCK) begin
		if (STATE == S_INIT) begin
			SOUND_OUT <= 0;
		end else begin	
			SOUND_OUT <= sine_out;
			if (counter == `ONE_SEC) 
				counter = 0;
			else 
				counter = counter + 1;
			if (STATE == 1)
				sound_freq <= FREQ_1;
			else if (STATE == 2)
				sound_freq <= FREQ_2;
			else if (STATE == 3)
				sound_freq <= FREQ_3;
		end
	end
	
endmodule