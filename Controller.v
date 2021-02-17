//Misha Mesarcik
//15/09/17
//DRFM Project

/*The controller receives and transmits the external peripheral data signals from the SDRAM and the PLL
  and routes them to and from the SDRAM Controller, JTAG interface and the DSP subsystems. In addition
  to this, it serves as a means to ensure the data being outputted from SDRAM is correctly handled as the
  SDRAM controller can not output data on every clock cycle.
*/


module Controller(
 input M100CLK,
 input lock, // From PLL
 input request, //request for PWM
 input [9:0] SW, //switches 

//SDRAM Stuff
 output wire [12:0] OP_DRAM_ADDR,                 
 output wire [1:0]  OP_DRAM_Bank_Address,         
 output wire        OP_DRAM_Column_Address_Strobe,
 output wire        OP_DRAM_Clock_Enable,         
 output wire        OP_DRAM_Chip_Select,          
 inout  wire [15:0] BP_DRAM_Data,                 
 output wire [1:0]  OP_DRAM_Data_Mask,            
 output wire        OP_DRAM_Row_Address_Strobe,   
 output wire        OP_DRAM_Write_Enable,         

 output [7:0] data_out, // Data to be outputted via pwm

 // Seven Segment Display
  output [7:0]    SS0,
  output [7:0]    SS1,
  output [7:0]    SS2,
  output [7:0]    SS3,
  output [7:0]    SS4,
  output [7:0]    SS5,

  output [9:0]    LED,

  output reg      TDO // FOR JTAG
);



reg [24:0] Address_counter; // for addressing SDRAM


// AVALONSTUFF
  reg   Avalon_ChipEnable;
  reg [24:0]  Avalon_Address;
  reg [ 1:0]  Avalon_ByteEnable;
  reg    Avalon_WaitRequest;
  reg [15:0]  Avalon_WriteData;
  reg    Avalon_Write;
  reg [15:0] Avalon_ReadData;
  reg    Avalon_ReadDataValid;
  reg   Avalon_Read;


  reg    Read_ChipEnable;
  wire [24:0]  Read_Address;
  reg [ 1:0] Read_ByteEnable;
  reg    Read_WaitRequest;
  reg [15:0]  Read_WriteData;
  reg    Read_Write;
  reg [15:0] Read_ReadData;
  reg    Read_ReadDataValid;
  reg   Read_Read;

  reg    Write_ChipEnable;
  reg [24:0]  Write_Address;
  reg [ 1:0] Write_ByteEnable;
  reg    Write_WaitRequest;
  reg [15:0]  Write_WriteData;
  reg    Write_Write;
  reg [15:0] Write_ReadData;
  reg    Write_ReadDataValid;
  reg   Write_Read;

  reg MasterSelect;


// Virtual JTAF Stuff.
  reg [3:0] state;
  reg [9:0] time_delay;
  reg  [9:0] old_time_delay;// For dectecting changes.
  reg       delay;
  reg [31:0] doppler_shift;
  reg [15:0] amplitude_scale;
  reg [31:0] doppler_shift_temp;
  reg [15:0] amplitude_scale_temp;
  VirtualJTAG_MM_Write my_VirtualJTAG_MM_Write(
         M100CLK,
          ~lock ,
          MasterSelect,
          Write_ChipEnable,
          Write_Address,
          Write_ByteEnable,
          Write_WaitRequest, 
          Write_WriteData,
          Write_Write,
          Write_ReadData,
          Write_ReadDataValid,
          Write_Read,
          SS0,
          SS1,
          SS2,
          SS3,
          SS4,
          SS5,
          LED,
          TDO,
          state,
          time_delay,
          doppler_shift_temp,
          amplitude_scale_temp
          );

// QSys Stuff.  
 myQsys my_myQsys (
   M100CLK, 
   Avalon_Address,
   ~Avalon_ByteEnable,
   Avalon_ChipEnable,
   Avalon_WriteData,
   ~Avalon_Read,
   ~Avalon_Write,
   Avalon_ReadData,
   Avalon_ReadDataValid,
   Avalon_WaitRequest,
   lock,           //     reset.reset_n
   OP_DRAM_ADDR,                
   OP_DRAM_Bank_Address,          
   OP_DRAM_Column_Address_Strobe, 
   OP_DRAM_Clock_Enable,         
   OP_DRAM_Chip_Select,        
   BP_DRAM_Data,                 
   OP_DRAM_Data_Mask,             
   OP_DRAM_Row_Address_Strobe,    
   OP_DRAM_Write_Enable                       
 );


// RAM STUFF
 reg [10:0]  rdaddress;
 reg [10:0]  wraddress;
 reg [15:0]  ram_out; 

 RAMRAMAM my_RAM(M100CLK,Read_ReadData,rdaddress,wraddress,Read_ReadDataValid,ram_out);

// Arbiter Stuff
  reg            ready;
  reg [31:0]     arbiter_out;

  reg [31:0]      u_i_shifted;
  reg [31:0]      u_q_shifted;


  Arbiter my_Arbiter(M100CLK,~lock,ram_out,doppler_shift,ready,u_i_shifted,u_q_shifted);
 

// Scaler Stuff
  reg [31:0]        u_i_shifted_scaled;
  reg [31:0]        u_q_shifted_scaled;
  wire              wrreq;
  Scaler my_Scaler (M100CLK,~lock,amplitude_scale,ready,u_i_shifted,u_q_shifted,wrreq,u_i_shifted_scaled,u_q_shifted_scaled);

// FIFO Stuff -- just used for PWM Buffering.
  reg                 empty;
  reg                 full;
  reg [31:0]          q;
  reg [6:0]           usedw;

  FIFO my_FIFO (M100CLK,u_i_shifted_scaled,request,wrreq,empty,full,q,usedw);

always @(posedge M100CLK) MasterSelect <= SW[0];

 always @ (*) begin
  if (MasterSelect) begin
   Avalon_ChipEnable    <=  Write_ChipEnable;
   Avalon_Address       <=  Write_Address;
   Avalon_ByteEnable    <=  Write_ByteEnable;
   Avalon_WriteData     <=  Write_WriteData;
   Avalon_Write         <=  Write_Write;
   Avalon_Read          <=  Write_Read;

   Write_WaitRequest    <=  Avalon_WaitRequest;
   Write_ReadData       <=  Avalon_ReadData;
   Write_ReadDataValid  <=  Avalon_ReadDataValid;

   Read_WaitRequest     <=  1'b1;
   Read_ReadData        <=  0;
   Read_ReadDataValid   <=  0;

  end else begin
   Avalon_ChipEnable    <=  1'b1;
   Avalon_Address       <=  Read_Address;
   Avalon_ByteEnable    <=  2'b11;
   Avalon_WriteData     <=  Read_WriteData;
   Avalon_Write         <=  0;
   Avalon_Read          <=  Read_Read;

   Read_WaitRequest     <=  Avalon_WaitRequest;
   Read_ReadData        <=    Avalon_ReadData;
   Read_ReadDataValid   <=  Avalon_ReadDataValid;

   Write_WaitRequest    <=  1'b1;
   Write_ReadData       <=  0;
   Write_ReadDataValid  <=  0;
  end

 end


  assign Read_Address    =  Address_counter;
  assign data_out        =  q[31:24];


  always @(posedge M100CLK) begin
     if(!lock) begin
      wraddress <= 0;
      rdaddress          <= 0;
      Address_counter    <= 0;
     end 
     else begin

     // ////////////DELAY///////////////
      if(state[0] == 1 ) begin
        if (old_time_delay != time_delay) begin
            old_time_delay <=time_delay;
            rdaddress <= rdaddress  - {1'b_0,time_delay}; // append zero to make 11 bits.
        end 
        else rdaddress <= rdaddress + 1'b_1;
      end
     else  rdaddress           <= rdaddress + 1'b_1; 


    // /////////FREQUENCY SHIFT//////////
     if(state[3] == 0 ) begin // not in doppler
          doppler_shift <= 32'b_0000_0000_0000_0000_0000_0000_0000_0001; // frequency shift of basically nothing.
     end 
     else doppler_shift <= doppler_shift_temp;


    // /////////////SCALE////////////////
     if(state[1] == 0 ) begin // not in scale
          amplitude_scale <= 16'b_1111_1111_1111_1111; // amp scale of 1 i.e. no scale
     end 
     else amplitude_scale <= amplitude_scale_temp;


    // //////////////////////////////////
    
 
     if(Read_ReadDataValid) wraddress <= wraddress + 1'b1; // increment the writnig if we cant read.

     if(!Read_WaitRequest) begin // now that we can read do this
      // if ( (Address_counter -rdaddress)   <10'd_1024) begin 
      if((Address_counter[8:0] - rdaddress[9:1]) < 9'd_450) begin
       Read_Read        <=1'b_1;  
       Address_counter  <= Address_counter +1'b1;
      end else Read_Read <=1'b_0;
     end 


    end
   end


endmodule
