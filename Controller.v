module Controller(
 input M100CLK,
 input lock,
 input request,
 input [7:1] SW, //SW from fifo-q 
 // output [9:0]LED,

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

 output [7:0] SS0,
 output [7:0] SS1,
 output [7:0] SS2,
 output [7:0] SS3,
 output [7:0] SS4,
 output [7:0] SS5,
 
 output[9:0]  LED,

 output reg TDO


);


//FIFO BLOCK Regsiters
reg rdreq ; //  Read request from fifo
reg wrreq;  // Write request from fifo
reg empty ; //Empty flag from qu
reg full; // Full flag from q
reg [8:0] usedw; //Number of words used.
reg [15:0]fifo_out ;

//Fifo Output Segmentaion
reg part = 1'b_0;
reg [7:0] part_A;
reg [7:0] part_B;

reg [24:0] Address_counter ; 
reg [8:0] q_counter;
 


// AVALONSTUFF
reg   Avalon_ChipEnable;
reg [24:0]  Avalon_Address;
reg [ 1:0]  Avalon_ByteEnable;
reg    Avalon_WaitRequest;
reg [15:0]  Avalon_WriteData;
reg    Avalon_Write;
reg [15:0] Avalon_ReadData;
reg    Avalon_ReadDataValid;
reg   aAvalon_Read;


reg    Read_ChipEnable;
wire [24:0]  Read_Address;
reg [ 1:0] Read_ByteEnable;
reg    Read_WaitRequest;
reg [15:0]  Read_WriteData;
reg    Read_Write;
reg [15:0] Read_ReadData;
reg    Read_ReadDataValid;
reg   Read_Read =  1'b_0;

reg    Write_ChipEnable;
reg [24:0]  Write_Address;
reg [ 1:0] Write_ByteEnable;
reg    Write_WaitRequest;
reg [15:0]  Write_WriteData;
reg    Write_Write;
reg [15:0] Write_ReadData;
reg    Write_ReadDataValid;
reg   Write_Read;



VirtualJTAG_MM_Write my_VirtualJTAG_MM_Write(
       M100CLK,
        ~lock ,
         SW[2],
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
        TDO
        );

  
Qsys myQsys (
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

 reg [9:0]  rdaddress;
 reg [8:0]  wraddress;

RAM myRAM(M100CLK,Read_ReadData,rdaddress,wraddress,Read_ReadDataValid,data_out);

// assign LED[9:1] = Avalon_Address [24:16];

reg MasterSelect;
always @(posedge M100CLK) MasterSelect <= SW[1];

 always @ (*) begin
  if(SW[2]) begin
    if (MasterSelect) begin
     Avalon_ChipEnable   <=  Write_ChipEnable;
     Avalon_Address    <=  Write_Address;
     Avalon_ByteEnable   <=  Write_ByteEnable;
     Avalon_WriteData   <=  Write_WriteData;
     Avalon_Write    <=  Write_Write;
     Avalon_Read    <=  Write_Read;

     Write_WaitRequest   <=  Avalon_WaitRequest;
     Write_ReadData    <=  Avalon_ReadData;
     Write_ReadDataValid  <=  Avalon_ReadDataValid;

     Read_WaitRequest   <=  1'b1;
     Read_ReadData      <=  0;
     Read_ReadDataValid <=  0;

    end else begin
     Avalon_ChipEnable   <=  1'b1;
     Avalon_Address    <=  Read_Address;
     Avalon_ByteEnable   <=  2'b11;
     Avalon_WriteData   <=  Read_WriteData;
     Avalon_Write    <=  0;
     Avalon_Read    <=  Read_Read;

     Read_WaitRequest   <=  Avalon_WaitRequest;
     Read_ReadData    <=  Avalon_ReadData;
     Read_ReadDataValid   <=  Avalon_ReadDataValid;

     Write_WaitRequest   <=  1'b1;
     Write_ReadData      <=  0;
     Write_ReadDataValid <=  0;
    end
  end
 end

assign Read_Address = Address_counter;

 always @(posedge M100CLK) begin
  if(SW[2]) begin

     if(!lock) begin
      wraddress <= 0;
      rdaddress <= 0;
      Address_counter <= 0;
     end else begin

     if(Read_ReadDataValid) wraddress <= wraddress + 1'b1;

     if(!Read_WaitRequest) begin
      if((Address_counter[8:0] - rdaddress[9:1]) < 9'd_450) begin
       Read_Read<=1'b_1;  
       Address_counter<= Address_counter +1'b1;
      end else Read_Read <=1'b_0;
     end


    // Read_WaitRequest
     if(&request) begin
      rdaddress <= rdaddress + 1'b_1;
     end
    end
  end
 end
endmodule
