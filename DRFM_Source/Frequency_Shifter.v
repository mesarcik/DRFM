//Misha Mesarcik
//15/09/17
//DRFM Project

/* 	Frequency Shifter: The frequency shifter module used in this DRFM system followed [I(n) + jQ(n)][cos(2pifn) + jsin(2pifn)]. 
	As per the derivation, the implementation required four multipliers, an addition and a subtraction,
	in order to result in the frequency shifted	I/Q data. For this reason, the frequency shifter subsystem
	can be described in two parts. These being the Numerically Controlled Oscillator (NCO) and the
	arithmetic units.

	Adapted From John-Philip Taylor's Mixer
*/

module Frequency_Shifter (
	input 				M100CLK,
	input 				reset,


	input [15:0]		i,// 2's
	input [15:0]		q, // 2's
	input 				input_ready, // flag

	input [16:0]		cos, // 2's comp
	input [16:0]		sin, // 2's comp

	output [31:0]		q_shifted_val, //2's comp
	output [31:0]		i_shited_val  // 2's comp

);

	reg [32:0] 			i_temp; // temp registers
	reg [32:0]			q_temp; // temp registers

	always @ (posedge M100CLK) begin
			i_temp <= $signed(i) * $signed(cos); // do the signed multiplciations
			q_temp <= $signed(q) * $signed(sin); // do the signed multiplciations
			if(i_temp[32]) begin
				if (i_temp[31]) i_shited_val <= i_temp[31:0];
				else 			i_shited_val <= 32'h_80000000; // maxium negative 
			end
			else begin
				if (i_temp[31]) i_shited_val<=32'h_7FFFFFFF; // maximum positive.
				else 			i_shited_val<=i_temp[31:0]; 
			end
			if(q_temp[32]) begin
				if (q_temp[31]) q_shifted_val <= q_temp[31:0];
				else 			q_shifted_val <= 32'h_80000000; // maxium negative 
			end
			else begin
				if (q_temp[31]) q_shifted_val<=32'h_7FFFFFFF;// maximum positive.
				else 			q_shifted_val<=q_temp[31:0];
			end
		// end
	end



endmodule // Frequency_Shifter