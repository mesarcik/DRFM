//Misha Mesarcik
//15/09/17
//DRFM Project

/* The DRFM Module is just the top level module for interfacing with the real world. Not much happens here
   as can be seen below.
*/


module PWM(
	input [9:0] 						SW, // switch inputs
	input 								reset_n, // connect reset and locked together.
	input 								CLK,  //on board clock
	output 								out, //PWM pin output.
	output [9:0]						LED, // LEDS

 // Seven Segment Display
	output [7:0]		SS0,
	output [7:0]		SS1,
	output [7:0]		SS2,
	output [7:0]		SS3,
	output [7:0]		SS4,
	output [7:0]		SS5,

// SDRAM Interfacing
	output wire [12:0] 				OP_DRAM_ADDR,
	output wire [1:0]  				OP_DRAM_Bank_Address,   
	output wire        				OP_DRAM_Column_Address_Strobe, 
	output wire        				OP_DRAM_Clock_Enable,          
	output wire        				OP_DRAM_Chip_Select,           
	inout  wire [15:0] 				BP_DRAM_Data,                  
	output wire [1:0]  				OP_DRAM_Data_Mask,             
	output wire        				OP_DRAM_Row_Address_Strobe,    
	output wire        				OP_DRAM_Write_Enable,          
	output wire        				SDRAM_Clock,    

	output [2:0]					Arduino_IO, //pins for testing

	output reg      				TDO // JTAG Stuff

);

	

	//GLobal params
		reg[7:0] PWM_Counter;
		reg request;

	//PLL INIT
		wire Clock_780;
		wire M100CLK;
		wire lock;
		PLL my_PLL (CLK,M100CLK,SDRAM_Clock,Clock_780,lock);

	//Controller Init
		reg[7:0] data_out;
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

	// Saninity checks.
	assign Arduino_IO = {M100CLK, SDRAM_Clock, Clock_780}; 


	

	always @(posedge M100CLK) begin
	  if (!SW[0]) begin // check if in read mode
	   if(!PWM_Counter) request <=1; // if overflowed, request more data from controller
	   if(|PWM_Counter) request <=0; // set it low afetwards

	   	//DO PWM 
	   PWM_Counter <= PWM_Counter + 1'b_1;
	   if(&PWM_Counter)PWM_Counter <= 8'b_0000_0000; // check overflow. maybe unnecssary
	   if(PWM_Counter > data_out) out <= 1'b_0;
	   else out <= 1'b_1;
	  end
	end
endmodule
