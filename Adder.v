//Misha Mesarcik
//15/09/17
//DRFM Project

/* 	
	The adder module just added I/Q data and checked for singed overflows.

	Adapted From John-Philip Taylor's Mixer
*/
module Adder (
	input 				M100CLK,
	input 				reset,

	input[31:0] 		i, // in 2's comp
	input[31:0] 		q, // in 2's comp

	output [32:0]		sum // in 2s comp./ this is the q value 


);
	//Global vars
		reg	[64:0] 			temp_sum;
		reg [63:0]        	full_scale_sum;
		reg 				local_reset;


	// Assignments
		assign sum = full_scale_sum[32:0]; // keep the overflowed sign in the 32nd bit.

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) temp_sum <=0;
		else begin 
				temp_sum <= $signed(i) + $signed(q); //output of this usbtraction is 2s comp.
				if(temp_sum[64]) begin //check negtive
					if (temp_sum[63]) full_scale_sum <= temp_sum[63:0];
					else 			  full_scale_sum <= 64'h_8000_0000_0000_0000;// max negative 64 bit value
				end
				else begin // Is positive.
					if (temp_sum[63]) full_scale_sum<= 64'h_7FFF_FFFF_FFFF_FFFF; // max positive 64 bit value 
					else 			  full_scale_sum<=temp_sum[63:0];
				end

		end
	
	end



endmodule // Adder