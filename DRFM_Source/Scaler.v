module Scaler (
	input 				M100CLK,
	input 				reset,
	input [15:0]		amp_scale,

	input 				ready,
	input [31:0]		i,
	input [31:0]        q,
	input [31:0]        sum,

	output 				output_ready,
	output [63:0]       i_scaled,
	output [63:0]		q_scaled,
	output [63:0]		sum_scaled

);
	reg					local_reset;

	reg [47:0]          fractional_i;
	reg [47:0]          fractional_q;
	reg [47:0]          fractional_sum;

	reg [47:0] 			fractional_amp_scale;

	reg [95:0]          temp_i_result;
	reg [95:0]          temp_q_result;
	reg [95:0]          temp_sum_result;
	
	//THERE IS A PROBLEM WITH THE BIT SHIFT. 
	// THE 16TH BIT NEEDS TO MAP TO 1 -- THE 15TH BIT NEEDS TO MAP TO 0.5
	//THIS IS A PROBLEM WITH THE MULTIPLICATION.

	assign fractional_i 		 =		{i,   16'b_0000_0000_0000_0000}; // not sute if the shift is working.
	assign fractional_q 		 =		{q,   16'b_0000_0000_0000_0000}; // shift left
 	assign fractional_sum 		 =		{sum, 16'b_0000_0000_0000_0000};
 	assign fractional_amp_scale  =		{32'b_0000_0000_0000_0000_0000_0000_0000_0000,amp_scale}; //shift right.

	assign i_scaled 			 =		temp_i_result	[95:32];  
	assign q_scaled				 =		temp_q_result  	[95:32];
	assign sum_scaled			 =		temp_sum_result	[95:32]; 
	

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset)begin
			temp_i_result		<=	0;
			temp_q_result  		<=	0;
			temp_sum_result		<=	0;
		end
		else begin
			if (ready) begin
				temp_i_result   <=		fractional_i  *fractional_amp_scale;
				temp_q_result   <=		fractional_q  *fractional_amp_scale;
				temp_sum_result <=		fractional_sum*fractional_amp_scale;
				output_ready	<=		1'b_1;
			end
			if (output_ready) output_ready <= 1'b_0;
		end
		
	end



endmodule // Scaler