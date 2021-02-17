//Misha Mesarcik
//15/09/17
//DRFM Project

/* 	The NCO Module: The NCO is an oscillator that uses a look up table, an adder and a memory to output
	periodic waveforms. In this case, the periodic waveforms are sin and cos, as they are required to map
	the complex exponential frequency shift to a realisable model. The way the NCO worked was by receiving
	an input frequency word that was integrated to obtain a phase that could be addressed on a Look Up Table
	(LUT). The LUT was implemented through the use of a 4096 address long 16-bit wide dual port	ROM that
	was pre-initialized with a MATLAB generated Memory Initialization File (MIF). The MIF file’s contents
	was a 100Hz sinusoid that was sampled at 212Hz.

	Adapted From John-Philip Taylor's NCO
*/

module NCO (
	input [31:0]		doppler_shift,
	input 				M100CLK,
	input 				reset,

	output [16:0]		sin,
	output [16:0]		cos

);
	reg	[31:0] 			phase_acc;// name says it all 
	reg					local_reset;// name says it all 

	wire [16:0]			unsigned_sin; // name says it all 
	wire [16:0]			unsigned_cos;// name says it all 

	Sine_LUT 			my_Sine_LUT  (phase_acc[31:20],phase_acc[31:20] + 12'd_1024 ,M100CLK,unsigned_cos,unsigned_sin);
	// 1024 to get 90 degree phase shift. // 2's comp  binary
	assign cos = 		{~unsigned_cos[16], unsigned_cos[15:0]}; //2's comp
	assign sin = 		{~unsigned_sin[16], unsigned_sin[15:0]}; //2's comp

	always @ (posedge M100CLK) begin
		local_reset <= reset;
		if (local_reset) phase_acc <=0;
		else			 phase_acc <= phase_acc +doppler_shift; // perform the increment for the control loop
	
	end



endmodule // NCO