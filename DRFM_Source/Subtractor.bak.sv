module Subtractor (
	input 				M100CLK,
	input 				reset,

	input[31:0] 		i, // in offset binary
	input[31:0] 		q, // in offset binary

	output				output_ready,
	output [31:0]		sum // in offset binary


);
	reg	[31:0] 			temp_sum;
	reg 				local_reset;
	

	assign sum = {~temp_sum[31],temp_sum[30:0]}; // this needs to be taken back to offset binary

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) temp_sum <=0;
		else begin 
			temp_sum <= $signed(4'b_1010) + $signed(~(4'b_1111) +4'b_0001); //output of this usbtraction is 2s comp.
			output_ready <=1;
		end
		if (output_ready) output_ready<=0;
	
	end



endmodule // Subtractor