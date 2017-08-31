module Controller(
 input M100CLK,
 input lock,
 input request,
 input [9:0] SW, //sw

 output wire [12:0] OP_DRAM_ADDR,                  //     wires.addr
 output wire [1:0]  OP_DRAM_Bank_Address,                 //          .ba
 output wire        OP_DRAM_Column_Address_Strobe,         //          .cas_n
 output wire        OP_DRAM_Clock_Enable,           //          .cke
 output wire        OP_DRAM_Chip_Select,             //          .cs_n
 inout  wire [15:0] BP_DRAM_Data,                  //          .dq
 output wire [1:0]  OP_DRAM_Data_Mask,                 //          .dqm upper and lower PIN_V22 & PIN_J21
 output wire        OP_DRAM_Row_Address_Strobe,            //          .ras_n
 output wire        OP_DRAM_Write_Enable,             //          .we_n

 output [7:0] data_out,

 // Seven Segment Display
  output [7:0]    SS0,
  output [7:0]    SS1,
  output [7:0]    SS2,
  output [7:0]    SS3,
  output [7:0]    SS4,
  output [7:0]    SS5,

  output [9:0]    LED,

  output reg      TDO
);



reg [24:0] Address_counter; 


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
          doppler_shift,
          amplitude_scale
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
   reg [15:0]  ram_out; // MAKE 2s compl

   RAMRAMAM my_RAM(M100CLK,Read_ReadData,rdaddress,wraddress,Read_ReadDataValid,ram_out);

// Arbiter Stuff
  reg            ready;
  reg [31:0]     arbiter_out;
  reg [15:0]     shifted_output;

  reg [31:0]      q_shifted_val;
  reg [31:0]      i_shited_val;

  Arbiter my_Arbiter(M100CLK,~lock,1'b1,ram_out,doppler_shift,amplitude_scale,ready,arbiter_out,q_shifted_val,i_shited_val);

// Scaler Stuff
  reg [63:0]        i_scaled;
  reg [63:0]        q_scaled;
  reg [63:0]        sum_scaled;
  wire              wrreq;
  Scaler my_Scaler (M100CLK,~lock,amplitude_scale,ready,i_shited_val,q_shifted_val,arbiter_out,wrreq,i_scaled,q_scaled,sum_scaled);

// FIFO Stuff
reg                 empty;
reg                 full;
reg [63:0]          q;
reg [6:0]           usedw;

FIFO my_FIFO (M100CLK,sum_scaled,request,wrreq,empty,full,q,usedw);

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
   Read_ReadData        <=    Avalon_ReadData;//{~Avalon_ReadData[15],Avalon_ReadData[14:0]}; // 2s compl in.
   Read_ReadDataValid   <=  Avalon_ReadDataValid;

   Write_WaitRequest    <=  1'b1;
   Write_ReadData       <=  0;
   Write_ReadDataValid  <=  0;
  end

 end


  assign Read_Address    =  Address_counter;
  assign data_out        =  q[31:24];
  // assign data_out           = arbiter_out[31:24];


  always @(posedge M100CLK) begin
     if(!lock) begin
      wraddress          <= 0;
      rdaddress          <= 0;
      Address_counter    <= 0;
     end 
     else begin

     ////////////DELAY///////////////
      if(state[0] == 1 ) begin
        if (old_time_delay != time_delay) begin
            if (delay) begin
              old_time_delay <=time_delay;
              delay <=0;
            end
            else delay <=1;
            rdaddress <= rdaddress + 1'b_1 - {1'b_0,time_delay};
        end 
        else rdaddress <= rdaddress + 1'b_1;
      end
     //////////////////////////////////


     rdaddress           <= rdaddress + 1'b_1;
 
     if(Read_ReadDataValid) wraddress <= wraddress + 1'b1;

     if(!Read_WaitRequest) begin
      // if ( (Address_counter -rdaddress)   <10'd_1024) begin 
      // if((Address_counter[8:0] - rdaddress[9:1]) < 9'd_450) begin
       Read_Read        <=1'b_1;  
       Address_counter  <= Address_counter +1'b1;
      //end else Read_Read <=1'b_0;
     end else Read_Read <=1'b_0;


    end
   end


   // always @(posedge M100CLK) begin
   //   if(!lock) begin
   //    wraddress <= 0;
   //    rdaddress <= 0;
   //    Address_counter <= 0;
   //   end else begin
   //    ////////////DELAY///////////////
   //    if(state[0] == 1 ) begin
   //      if (old_time_delay != time_delay) begin
   //          if (delay) begin
   //            old_time_delay <=time_delay;
   //            delay <=0;
   //          end
   //          else delay <=1;
   //          rdaddress <= rdaddress + 1'b_1 - {1'b_0,time_delay};
   //      end 
   //      else rdaddress <= rdaddress + 1'b_1;
   //    end
   //    //////////////////////////////////

   //    // if (state[3]== 1) begin
   //    //     // doppler_flag <=1;
   //    //     // data_out <= {~shifted_output[15],shifted_output[14:0]};
   //    //     // data_out <= sum_scaled[31:24]; //-- what about this? -- fixed it!
   //    //     // data_out <= q_shifted_val[31:24];
   //    //     data_out <= sum_scaled[31:24];


   //    // end
   //    // else begin
   //    //   // doppler_flag <=0;
   //    //   // data_out <= {~shifted_output[15],shifted_output[14:0]};
   //    //   // data_out <= Read_ReadData[15:8]; //-- this works!
   //    //   // data_out <= ram_out[15:8]; //-- what about this? -- fixed it!
   //    //   data_out <= sum_scaled[31:24];
   //    //   // data_out <= q_shifted_val[31:24];
   //    // end
   //    //////////////////////////////////

   //   if(ready) wraddress <= wraddress + 1'b1;

   //   if(!Read_WaitRequest) begin
   //    if((Address_counter[9:0] - rdaddress[10:1]) < 10'd_1024) begin
   //     Read_Read<=1'b_1;  
   //     Address_counter<= Address_counter +1'b1;
   //    end else Read_Read <=1'b_0;
   //   end


   //  // Read_WaitRequest
   //   if(&request) begin
   //    rdaddress <= rdaddress + 1'b_1;
   //   end
   //  end
   // end


endmodule
