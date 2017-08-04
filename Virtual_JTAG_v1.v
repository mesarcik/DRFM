module Virtual_JTAG_v1 (
	input [7:0] 	 	SW,
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
	output reg 		 	tdo,
	output 				out

);

	reg[7:0] PWM_Counter   =    8'b_0000_0000;

	
	// PLL Initialiation
		wire M100CLK;
		wire lock;
		reg rst       = 0;
		wire Clock_780;
		PLL my_PLL (CLK,M100CLK,SDRAM_Clock,Clock_780,lock);
	//
	
	// Controller Initialization
		reg request;
		reg [7:0] data_out;

		Controller my_Controller(
		 M100CLK,
		 lock,
		 request,
		 SW, //data from fifo-q 
		 // LED,

		 OP_DRAM_ADDR,                  //     wires.addr
		 OP_DRAM_Bank_Address,                 //          .ba
		 OP_DRAM_Column_Address_Strobe,         //          .cas_n
		 OP_DRAM_Clock_Enable,           //          .cke
		 OP_DRAM_Chip_Select,             //          .cs_n
		 BP_DRAM_Data,                  //          .dq
		 OP_DRAM_Data_Mask,                 //          .dqm upper and lower PIN_V22 & PIN_J21
		 OP_DRAM_Row_Address_Strobe,            //          .ras_n
		 OP_DRAM_Write_Enable,             //          .we_n
		 data_out,
		 SS0,
		 SS1,
		 SS2,
		 SS3,
		 SS4,
		 SS5,
		 LED,
		 TDO
		 );
	//

	always @(posedge M100CLK) begin
	  if (!SW[1]) begin
	   if(!PWM_Counter) request <=1;
	   if(|PWM_Counter) request <=0;

	   PWM_Counter <= PWM_Counter + 1'b_1;
	   if(&PWM_Counter)PWM_Counter <= 8'b_0000_0000;
	     
	   if(PWM_Counter > data_out) out <= 1'b_0;
	   else out <= 1'b_1;
	  end
	end

	


endmodule // Virtual_JTAG_v1