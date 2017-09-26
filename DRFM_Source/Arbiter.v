//Misha Mesarcik
//15/09/17
//DRFM Project

/* 	Arbiter: As the SDRAM was only 16 bits wide and each I/Q sample was 16 bits wide, the I/Q data had to be
	interlaced into the RAM when being injected. This meant that as the frequency shifting operations 
	required both I/Q samples simultaneously the data had to be arbitrated to perform the addition and 
	multiplication operations. The arbiter module also implements the frequency shifting subsystems.
*/


module Arbiter (
	input 				M100CLK,
	input 				reset,

	input [15:0]        data_in, // unsinged 
	input [31:0]		doppler_shift, //unsinged

	output 				arbiter_ready, //flag


	output [31:0] 		u_i_shifted, //unsigned
	output [31:0] 		u_q_shifted  //unsigned

);
	//'Global'  Vars
		reg 				local_reset;
		reg 				state;
		reg 				output_flag;
		reg 				output_ready;
		reg					ready;


		reg [15:0]			i_temp;
		reg [15:0]			q_temp;

	// NCO init
		wire [16:0] 		sin; //sin
		wire [16:0]			cos; //cos
		NCO my_NCO (doppler_shift,M100CLK,reset,sin,cos);

	//Frequency shifter init
		reg [15:0]			i;
		reg [15:0]			q;
		reg [31:0]  		q_shifted_val;
		reg [31:0] 			i_shited_val;
		Frequency_Shifter my_Frequency_Shifter (M100CLK,reset,i,q,ready,cos,sin,q_shifted_val,i_shited_val);

	//Subtractor Init
		reg [32:0]     		subtractor_out;
		Subtractor my_Subtractor(M100CLK,reset, i_shited_val,q_shifted_val, output_ready, subtractor_out);

	//Adder Init
		reg [32:0]     		adder_out;
		Adder my_Adder          (M100CLK,reset, i_shited_val,q_shifted_val, adder_out);

	//Assignemnts
		assign arbiter_ready = output_ready;
		assign u_i_shifted = {~subtractor_out[32],subtractor_out[31:1]}; // take back to unsigned and loose 1 bit
		assign u_q_shifted = {~adder_out[32],adder_out[31:1]}; // take back to unsigned and loose 1

	//If in state 0 q-data is coming in and we must wait to ouput.
	//If in state 1 i-data is coming in and we output.
	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) begin
			state				<=	0;
		end 
		else begin
			if(ready) ready 	<= 	0; ///this done so ready is high for only 1 clk
			
			if (state == 0)begin
				q_temp 			<=  data_in; //2's comp
				state 			<=	1;
			end
			else begin 
				i_temp 			<=  data_in;
				state 			<=	0;
				ready 			<= 	1;
				i 				<=   {~i_temp[15],i_temp[14:0]}; //2's comp 16'b_0000_0000_0000_0001;
				q 				<=   {~q_temp[15],q_temp[14:0]}; //2's comp 16'b_0000_0000_0000_0001;
			end
			
		end
	end

endmodule // Arbiter