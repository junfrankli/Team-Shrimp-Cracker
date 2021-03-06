// Quartus II Verilog Template
// Single Port ROM

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
sine[1] <= 8'b10000011;
sine[2] <= 8'b10000110;
sine[3] <= 8'b10001001;
sine[4] <= 8'b10001100;
sine[5] <= 8'b10001111;
sine[6] <= 8'b10010010;
sine[7] <= 8'b10010101;
sine[8] <= 8'b10011001;
sine[9] <= 8'b10011100;
sine[10] <= 8'b10011111;
sine[11] <= 8'b10100010;
sine[12] <= 8'b10100101;
sine[13] <= 8'b10101000;
sine[14] <= 8'b10101011;
sine[15] <= 8'b10101110;
sine[16] <= 8'b10110001;
sine[17] <= 8'b10110100;
sine[18] <= 8'b10110110;
sine[19] <= 8'b10111001;
sine[20] <= 8'b10111100;
sine[21] <= 8'b10111111;
sine[22] <= 8'b11000010;
sine[23] <= 8'b11000100;
sine[24] <= 8'b11000111;
sine[25] <= 8'b11001001;
sine[26] <= 8'b11001100;
sine[27] <= 8'b11001111;
sine[28] <= 8'b11010001;
sine[29] <= 8'b11010011;
sine[30] <= 8'b11010110;
sine[31] <= 8'b11011000;
sine[32] <= 8'b11011010;
sine[33] <= 8'b11011100;
sine[34] <= 8'b11011111;
sine[35] <= 8'b11100001;
sine[36] <= 8'b11100011;
sine[37] <= 8'b11100101;
sine[38] <= 8'b11100111;
sine[39] <= 8'b11101000;
sine[40] <= 8'b11101010;
sine[41] <= 8'b11101100;
sine[42] <= 8'b11101110;
sine[43] <= 8'b11101111;
sine[44] <= 8'b11110001;
sine[45] <= 8'b11110010;
sine[46] <= 8'b11110011;
sine[47] <= 8'b11110101;
sine[48] <= 8'b11110110;
sine[49] <= 8'b11110111;
sine[50] <= 8'b11111000;
sine[51] <= 8'b11111001;
sine[52] <= 8'b11111010;
sine[53] <= 8'b11111011;
sine[54] <= 8'b11111100;
sine[55] <= 8'b11111101;
sine[56] <= 8'b11111101;
sine[57] <= 8'b11111110;
sine[58] <= 8'b11111110;
sine[59] <= 8'b11111111;
sine[60] <= 8'b11111111;
sine[61] <= 8'b11111111;
sine[62] <= 8'b11111111;
sine[63] <= 8'b11111111;
sine[64] <= 8'b11111111;
sine[65] <= 8'b11111111;
sine[66] <= 8'b11111111;
sine[67] <= 8'b11111111;
sine[68] <= 8'b11111111;
sine[69] <= 8'b11111110;
sine[70] <= 8'b11111110;
sine[71] <= 8'b11111101;
sine[72] <= 8'b11111101;
sine[73] <= 8'b11111100;
sine[74] <= 8'b11111011;
sine[75] <= 8'b11111011;
sine[76] <= 8'b11111010;
sine[77] <= 8'b11111001;
sine[78] <= 8'b11111000;
sine[79] <= 8'b11110111;
sine[80] <= 8'b11110101;
sine[81] <= 8'b11110100;
sine[82] <= 8'b11110011;
sine[83] <= 8'b11110001;
sine[84] <= 8'b11110000;
sine[85] <= 8'b11101110;
sine[86] <= 8'b11101101;
sine[87] <= 8'b11101011;
sine[88] <= 8'b11101001;
sine[89] <= 8'b11101000;
sine[90] <= 8'b11100110;
sine[91] <= 8'b11100100;
sine[92] <= 8'b11100010;
sine[93] <= 8'b11100000;
sine[94] <= 8'b11011110;
sine[95] <= 8'b11011011;
sine[96] <= 8'b11011001;
sine[97] <= 8'b11010111;
sine[98] <= 8'b11010101;
sine[99] <= 8'b11010010;
sine[100] <= 8'b11010000;
sine[101] <= 8'b11001101;
sine[102] <= 8'b11001011;
sine[103] <= 8'b11001000;
sine[104] <= 8'b11000110;
sine[105] <= 8'b11000011;
sine[106] <= 8'b11000000;
sine[107] <= 8'b10111101;
sine[108] <= 8'b10111011;
sine[109] <= 8'b10111000;
sine[110] <= 8'b10110101;
sine[111] <= 8'b10110010;
sine[112] <= 8'b10101111;
sine[113] <= 8'b10101100;
sine[114] <= 8'b10101001;
sine[115] <= 8'b10100110;
sine[116] <= 8'b10100011;
sine[117] <= 8'b10100000;
sine[118] <= 8'b10011101;
sine[119] <= 8'b10011010;
sine[120] <= 8'b10010111;
sine[121] <= 8'b10010100;
sine[122] <= 8'b10010001;
sine[123] <= 8'b10001110;
sine[124] <= 8'b10001011;
sine[125] <= 8'b10000111;
sine[126] <= 8'b10000100;
sine[127] <= 8'b10000001;
sine[128] <= 8'b01111110;
sine[129] <= 8'b01111011;
sine[130] <= 8'b01111000;
sine[131] <= 8'b01110100;
sine[132] <= 8'b01110001;
sine[133] <= 8'b01101110;
sine[134] <= 8'b01101011;
sine[135] <= 8'b01101000;
sine[136] <= 8'b01100101;
sine[137] <= 8'b01100010;
sine[138] <= 8'b01011111;
sine[139] <= 8'b01011100;
sine[140] <= 8'b01011001;
sine[141] <= 8'b01010110;
sine[142] <= 8'b01010011;
sine[143] <= 8'b01010000;
sine[144] <= 8'b01001101;
sine[145] <= 8'b01001010;
sine[146] <= 8'b01000111;
sine[147] <= 8'b01000100;
sine[148] <= 8'b01000010;
sine[149] <= 8'b00111111;
sine[150] <= 8'b00111100;
sine[151] <= 8'b00111001;
sine[152] <= 8'b00110111;
sine[153] <= 8'b00110100;
sine[154] <= 8'b00110010;
sine[155] <= 8'b00101111;
sine[156] <= 8'b00101101;
sine[157] <= 8'b00101010;
sine[158] <= 8'b00101000;
sine[159] <= 8'b00100110;
sine[160] <= 8'b00100100;
sine[161] <= 8'b00100001;
sine[162] <= 8'b00011111;
sine[163] <= 8'b00011101;
sine[164] <= 8'b00011011;
sine[165] <= 8'b00011001;
sine[166] <= 8'b00010111;
sine[167] <= 8'b00010110;
sine[168] <= 8'b00010100;
sine[169] <= 8'b00010010;
sine[170] <= 8'b00010001;
sine[171] <= 8'b00001111;
sine[172] <= 8'b00001110;
sine[173] <= 8'b00001100;
sine[174] <= 8'b00001011;
sine[175] <= 8'b00001010;
sine[176] <= 8'b00001000;
sine[177] <= 8'b00000111;
sine[178] <= 8'b00000110;
sine[179] <= 8'b00000101;
sine[180] <= 8'b00000100;
sine[181] <= 8'b00000100;
sine[182] <= 8'b00000011;
sine[183] <= 8'b00000010;
sine[184] <= 8'b00000010;
sine[185] <= 8'b00000001;
sine[186] <= 8'b00000001;
sine[187] <= 8'b00000000;
sine[188] <= 8'b00000000;
sine[189] <= 8'b00000000;
sine[190] <= 8'b00000000;
sine[191] <= 8'b00000000;
sine[192] <= 8'b00000000;
sine[193] <= 8'b00000000;
sine[194] <= 8'b00000000;
sine[195] <= 8'b00000000;
sine[196] <= 8'b00000000;
sine[197] <= 8'b00000001;
sine[198] <= 8'b00000001;
sine[199] <= 8'b00000010;
sine[200] <= 8'b00000010;
sine[201] <= 8'b00000011;
sine[202] <= 8'b00000100;
sine[203] <= 8'b00000101;
sine[204] <= 8'b00000110;
sine[205] <= 8'b00000111;
sine[206] <= 8'b00001000;
sine[207] <= 8'b00001001;
sine[208] <= 8'b00001010;
sine[209] <= 8'b00001100;
sine[210] <= 8'b00001101;
sine[211] <= 8'b00001110;
sine[212] <= 8'b00010000;
sine[213] <= 8'b00010001;
sine[214] <= 8'b00010011;
sine[215] <= 8'b00010101;
sine[216] <= 8'b00010111;
sine[217] <= 8'b00011000;
sine[218] <= 8'b00011010;
sine[219] <= 8'b00011100;
sine[220] <= 8'b00011110;
sine[221] <= 8'b00100000;
sine[222] <= 8'b00100011;
sine[223] <= 8'b00100101;
sine[224] <= 8'b00100111;
sine[225] <= 8'b00101001;
sine[226] <= 8'b00101100;
sine[227] <= 8'b00101110;
sine[228] <= 8'b00110000;
sine[229] <= 8'b00110011;
sine[230] <= 8'b00110110;
sine[231] <= 8'b00111000;
sine[232] <= 8'b00111011;
sine[233] <= 8'b00111101;
sine[234] <= 8'b01000000;
sine[235] <= 8'b01000011;
sine[236] <= 8'b01000110;
sine[237] <= 8'b01001001;
sine[238] <= 8'b01001011;
sine[239] <= 8'b01001110;
sine[240] <= 8'b01010001;
sine[241] <= 8'b01010100;
sine[242] <= 8'b01010111;
sine[243] <= 8'b01011010;
sine[244] <= 8'b01011101;
sine[245] <= 8'b01100000;
sine[246] <= 8'b01100011;
sine[247] <= 8'b01100110;
sine[248] <= 8'b01101010;
sine[249] <= 8'b01101101;
sine[250] <= 8'b01110000;
sine[251] <= 8'b01110011;
sine[252] <= 8'b01110110;
sine[253] <= 8'b01111001;
sine[254] <= 8'b01111100;
sine[255] <= 8'b10000000;
	end


  always @ (posedge CLOCK)
  begin
    SINE_OUT <= sine[ADDR_VALUE];
  end

endmodule
