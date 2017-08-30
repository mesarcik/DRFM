module NCO (
	input [31:0]		doppler_shift,
	input 				M100CLK,
	input 				reset,

	output [16:0]		sin,
	output [16:0]		cos

);
	reg	[31:0] 			phase_acc;
	reg					local_reset;

	wire [16:0]			unsigned_sin;
	wire [16:0]			unsigned_cos;

	Sine_LUT 			my_Sine_LUT  (phase_acc[31:20],phase_acc[31:20] + 12'd_1024 ,M100CLK,unsigned_sin,unsigned_cos);
	// 1024 to get 90 degree phase shift. // 2's comp offset binary
	assign sin = 		{~unsigned_sin[16], unsigned_sin[15:0]}; //~unsigned_sin +1'b1;
	assign cos = 		{~unsigned_cos[16], unsigned_cos[15:0]}; // ~unsigned_cos+1'b1; 

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) phase_acc <=0;
		else			 phase_acc <= phase_acc +doppler_shift;
	
	end



endmodule // NCO