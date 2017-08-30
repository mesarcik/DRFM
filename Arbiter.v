module Arbiter (
	input 				M100CLK,
	input 				reset,
	input 				valid,

	input [15:0]        data_in,
	input [31:0]		doppler_shift,
	input [15:0]		amp_scale,

	output 				arbiter_ready,
	output [31:0] 		shifted_output,

	output [31:0] 		u_q_shifted,
	output [31:0]		u_i_shited

);
	reg 				local_reset;
	reg 				state;
	reg 				output_flag;
	reg 				output_ready;


	reg [15:0]			i_temp;
	reg [15:0]			q_temp;

	reg [15:0]			i;
	reg [15:0]			q;


	wire [16:0] 		sin; //sin
	wire [16:0]			cos; //cos

	reg [31:0]  		q_shifted_val;
	reg [31:0] 			i_shited_val;

	reg [31:0] 			sum;


//change.

	NCO my_NCO (doppler_shift,M100CLK,reset,sin,cos);

	Frequency_Shifter my_Frequency_Shifter (M100CLK,reset,doppler_shift,i,q,ready,cos,sin,q_shifted_val,i_shited_val);

	Adder my_Adder(M100CLK,reset,i_shited_val,q_shifted_val, output_ready, sum);

	assign u_q_shifted 	=  {~q_shifted_val[31], q_shifted_val[30:0]};
	assign u_i_shited 	=  {~i_shited_val[31] , i_shited_val [30:0]};

	assign arbiter_ready = output_ready;



	//If in state 0 q-data is coming in and we must wait to ouput.
	//If in state 1 i-data is coming in and we output.
	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) begin
			shifted_output  	<=	0;
			state				<=	0;
		end 
		else begin
			if(output_ready) shifted_output <= {~sum[31],sum[31:0]};
			// else shifted_output <= 32'b0;
			if(ready) ready 	<= 	0; ///this done so ready is high for only 1 clk
			if(valid) begin
				if (state == 0)begin
					q_temp 			<=  data_in; //2's comp
					state 			<=	1;
				end
				else begin 
					i_temp 			<=  data_in;
					state 			<=	0;
					ready 			<= 	1;
					i 				<= {~i_temp[15],i_temp[14:0]};
					q 				<= {~q_temp[15],q_temp[14:0]};
				end
			end
		end
	end

endmodule // Arbiter