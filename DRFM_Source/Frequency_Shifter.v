module Frequency_Shifter (
	input 				M100CLK,
	input 				reset,

	input [31:0]		doppler_shift,

	input [15:0]		i,// in offset binary
	input [15:0]		q, // in offset binary
	input 				input_ready,

	input [16:0]		cos, // in offset binary
	input [16:0]		sin, // in offset binary

	output [31:0]		q_shifted_val, // in offset binary
	output [31:0]		i_shited_val  // in offset binary

);
	// NCO STUFF.
		// // 2's comp from NCO
		// reg [15:0] 			sin;
		// reg [15:0]			cos;

		// NCO my_NCO (doppler_shift, M100CLK, reset,sin,cos);

	reg [32:0] 			i_temp;
	reg [32:0]			q_temp;

	always @ (posedge M100CLK) begin
		// Convert from offset binary to 2's compliment.
			i_temp <= $signed(i) * $signed(cos);
			q_temp <= $signed(q) * $signed(sin);
			if(i_temp[32]) begin
				if (i_temp[31]) i_shited_val <= i_temp[31:0];
				else 			i_shited_val <= 32'h_80000000;
			end
			else begin
				if (i_temp[31]) i_shited_val<=32'h_7FFFFFFF;
				else 			i_shited_val<=i_temp[31:0];
			end
			if(q_temp[32]) begin
				if (q_temp[31]) q_shifted_val <= q_temp[31:0];
				else 			q_shifted_val <= 32'h_80000000;
			end
			else begin
				if (q_temp[31]) q_shifted_val<=32'h_7FFFFFFF;
				else 			q_shifted_val<=q_temp[31:0];
			end
		// end
	end



endmodule // Frequency_Shifter