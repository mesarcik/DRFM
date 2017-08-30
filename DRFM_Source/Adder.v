module Adder (
	input 				M100CLK,
	input 				reset,

	input[31:0] 		i,
	input[31:0] 		q,  

	output				output_ready,
	output [31:0]		sum


);
	reg	[32:0] 			temp_sum;
	reg 				local_reset;
	

	assign sum = temp_sum[32:1];

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) temp_sum <=0;
		else begin 
			temp_sum <= $signed(i) + $signed(q);
			output_ready <=1;
		end
		if (output_ready) output_ready<=0;
	
	end



endmodule // Adder
