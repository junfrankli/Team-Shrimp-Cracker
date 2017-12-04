module square_wave(
  CLOCK;
  SOUND_OUT;
)

  input CLOCK;
  output SOUND_OUT;
  
  localparam toggle = 25_000_000/440/2;
  reg [14:0] counter;
  reg SOUNT_OUT;
  assign GPIO[0] = SOUND_OUT;
  
  always @(posedge CLOCK) begin
    if (counter == toggle) begin
      counter <= 0;
	  SOUND_OUT <= ~SOUND_OUT;
	end else
      counter <= counter + 1;
  end
endmodule  