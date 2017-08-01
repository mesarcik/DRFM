module Virtual_JTAG_v1 (
	input [7:1] 	 	SW,
	input 				aclr,
	input 				CLK,
	input			 	reset,
// Seven Segment Display
	output [7:0]		SS0,
	output [7:0]		SS1,
	output [7:0]		SS2,
	output [7:0]		SS3,
	output [7:0]		SS4,
	output [7:0]		SS5,
// SDRAM Stuff
	output wire [12:0]  OP_DRAM_ADDR,                  //     wires.addr
	output wire [1:0]   OP_DRAM_Bank_Address,                 //          .ba
	output wire         OP_DRAM_Column_Address_Strobe,         //          .cas_n
	output wire         OP_DRAM_Clock_Enable,           //          .cke
	output wire         OP_DRAM_Chip_Select,             //          .cs_n
	inout  wire [15:0]  BP_DRAM_Data,                  //          .dq
	output wire [1:0]   OP_DRAM_Data_Mask,                 //          .dqm upper and lower PIN_V22 & PIN_J21
	output wire         OP_DRAM_Row_Address_Strobe,            //          .ras_n
	output wire         OP_DRAM_Write_Enable,             //          .we_n
	output wire         SDRAM_Clock,             //          .we_n
// Other
	output[9:0] 		LED, 
	output reg 		 	tdo

);

	
	// PLL Initialiation
		wire M100CLK;
		wire lock;
		reg rst       = 0;
		wire Clock_780;
		PLL my_PLL (CLK,M100CLK,SDRAM_Clock,Clock_780,lock);
	//
	

	// Virtual JTAG Initialisation
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
	
	// Seven Segment Interface Initialization
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
		if(DR1[10])begin 
			state <= 4'b_0001; // DELAY
			LED <= DR1[9:0];
		end
		else if(DR1[20] ) begin
			state <= 4'b_1000; // DOPPLER
			LED <= DR1[19:10];		
		end 
		else if(  DR1[30]) begin
			state <= 4'b_0010; // SCALE	
			LED <= DR1 [29:20];
		end 
		else if(  DR1[31]) begin 
		state <= 4'b_0100; // LOAD	
		// LED <= DR1 [31:24];
		end 
		else state <= 4'b_0000; //Waiting state
		

	end


endmodule // Virtual_JTAG_v1