module Virtual_JTAG_v1 (
	input 			 aclr,
	input 			 CLK,

	output [7:0]		SS0,
	output [7:0]		SS1,
	output [7:0]		SS2,
	output [7:0]		SS3,
	output [7:0]		SS4,
	output [7:0]		SS5,

	output 			 [9:0] LED, 
	output reg 		 tdo

);

	// Virtual JTAG Parameters
	//
		reg 					ir_in;
		reg						virtual_state_sdr;
		reg 					virtual_state_udr;
		reg						tdi;
		reg 					tck;
		reg 					ir_out;

		wire					virtual_state_cdr;
		wire					virtual_state_e1d;
		wire					virtual_state_pdr;
		wire					virtual_state_e2d;
		wire					virtual_state_cir;
		wire					virtual_state_uir;
		vJTAG vJTAG_inst (tdi,tdo,ir_in,ir_out,virtual_state_cdr,virtual_state_sdr,virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,virtual_state_udr,virtual_state_cir,virtual_state_uir,tck);
	//
	
	// Seven Segment Interface
	//	
		reg [3:0] state;
		Seven_Seg_Driver Seven_Seg_Driver_inst (state,SS0,SS1,SS2,SS3,SS4,SS5);
	//

	reg DR0;
	reg [31:0] DR1;
	

	always @ (posedge tck or posedge aclr) begin //Because asynchronously clear as there will be multiple drivers
		if (aclr)begin
			DR0 <= 1'b0;
			DR1 <= 0;
		end 
		else begin
			DR0 <= tdi; // Check if there is data on the device.
				
			if (virtual_state_sdr) begin  // JTAG shift state.
				if (&ir_in)begin //Data is availiable to be taken out.
					DR1 <= {DR0, DR1[31:1]}; // Collect the data and shift.
				end
			end
		end
	end
		

	always @ (*) begin
		if (&ir_in) // If data is vailiable
			tdo <= DR1[0]; //give it new data 
	    else 
			tdo <= DR0;	// tell it there is adata on device.
	end

	always @(virtual_state_udr) begin
		// Check the incomming data to see if we need to do anything.
		if(DR1[7]) state <= 4'b_0001; // DELAY
		else if(DR1[15] ) state <= 4'b_1000; // DOPPLER		
		else if(  DR1[23]) state <= 4'b_0010; // SCALE
		else if(  DR1[31]) state <= 4'b_0100; // SCALE	
		else state <= 4'b_0000; //Waiting state
		

		LED <= DR1;
	end


endmodule // Virtual_JTAG_v1