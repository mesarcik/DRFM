//Misha Mesarcik
//15/09/17
//DRFM Project

/* 	Amplitude Scaling Module: As control word allocates 16 bits to the amplitude scaling information,
	a model was implemented to translate the control data to a value between 1 and 0. This was achieved
	by applying a non circular bit shift to the amplitude scaling portion of the control word. Such that the
	amplitude scaling information would be shifted 16 bits to the right in order to scale it between 1 and 
	close to zero.
*/

module Scaler (
	input 				M100CLK,
	input 				reset,
	input [15:0]		amp_scale, //control word

	input 				ready, //flag
	input [31:0]		i, // unsigned
	input [31:0]        q, // unsigned

	output 				output_ready,
	output [31:0]       i_scaled,//unsigned
	output [31:0]		q_scaled//unsigned

);
	//global registers
		reg					local_reset;

		reg [47:0]          fractional_i;
		reg [47:0]          fractional_q;

		reg [47:0] 			fractional_amp_scale;

		reg [95:0]          temp_i_result;
		reg [95:0]          temp_q_result;
	
	// THE 16TH BIT NEEDS TO MAP TO 1 -- THE 15TH BIT NEEDS TO MAP TO 0.5

	assign fractional_i 		 =		{i,   16'b_0000_0000_0000_0000}; // shift left
	assign fractional_q 		 =		{q,   16'b_0000_0000_0000_0000}; // 
 	assign fractional_amp_scale  =		{32'b_0000_0000_0000_0000_0000_0000_0000_0000,amp_scale}; //shift right.

	assign i_scaled 			 =		temp_i_result	[63:32];  // reassign to get the right stuff
	assign q_scaled				 =		temp_q_result  	[63:32]; // reassign to get the right stuff
	

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset)begin
			temp_i_result		<=	0;
			temp_q_result  		<=	0;
		end
		else begin
			if (ready) begin
				temp_i_result   <=		fractional_i  *fractional_amp_scale;
				temp_q_result   <=		fractional_q  *fractional_amp_scale;
				output_ready	<=		1'b_1; // set the flags.
			end
			if (output_ready) output_ready <= 1'b_0;
		end
		
	end



endmodule // Scaler