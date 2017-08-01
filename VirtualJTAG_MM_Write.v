//==============================================================================
// Copyright (C) John-Philip Taylor
// jpt13653903@gmail.com
//
// This file is part of a library
//
// This file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>
//============================================================================== 

module VirtualJTAG_MM_Write(
 input Clk, Reset,

 output reg   Busy,

 // All these signals use positive logic
 output       Avalon_ChipEnable,
 output [24:0]Avalon_Address,
 output [ 1:0]Avalon_ByteEnable,
 input        Avalon_WaitRequest,

 output [15:0]Avalon_WriteData,
 output reg   Avalon_Write,

 input  [15:0]Avalon_ReadData,
 input        Avalon_ReadDataValid,
 output       Avalon_Read
);

assign Avalon_ChipEnable = 1'b_1;
assign Avalon_ByteEnable = 2'b11;
assign Avalon_Read       = 1'b_0;
//------------------------------------------------------------------------------

reg  TDO;
wire TCK;
wire TDI;

wire [7:0]Instruction;
wire      Capture;
wire      Shift;
wire      Update;

sld_virtual_jtag #(
 .sld_auto_instance_index("NO"),
 .sld_instance_index     (0),
 .sld_ir_width           (8)

)virtual_jtag_0(
 .tck              (TCK),
 .tdi              (TDI),
 .tdo              (TDO),

 .ir_in            (Instruction),
 .virtual_state_cdr(Capture),
 .virtual_state_sdr(Shift  ),
 .virtual_state_udr(Update )
);
//------------------------------------------------------------------------------

reg [12:0]WrAddress;

altsyncram #(
 // General parameters
 .intended_device_family("MAX 10"),
 .lpm_type              ("altsyncram"),
 .operation_mode        ("DUAL_PORT"),
 .power_up_uninitialized("FALSE"),
 .ram_block_type        ("M9K"),
 
 // Port A parameters
 .clock_enable_input_a  ("BYPASS"),
 .numwords_a            (8192),
 .widthad_a             (13),
 .width_a               (1),
 .width_byteena_a       (1),

 // Port B parameters
 .address_aclr_b        ("NONE"),
 .address_reg_b         ("CLOCK1"),
 .clock_enable_input_b  ("BYPASS"),
 .clock_enable_output_b ("BYPASS"),
 .numwords_b            (512),
 .outdata_aclr_b        ("NONE"),
 .outdata_reg_b         ("UNREGISTERED"),
 .widthad_b             (9),
 .width_b               (16)

)altsyncram_component(
 // Write port
 .clock0        (TCK),
 .address_a     (WrAddress),
 .data_a        (TDI),
 .wren_a        (Shift),

 // Read port
 .clock1        (Clk),
 .address_b     (Avalon_Address[8:0]),
 .q_b           (Avalon_WriteData),

 // Unused features
 .aclr0         (1'b0),
 .aclr1         (1'b0),
 .addressstall_a(1'b0),
 .addressstall_b(1'b0),
 .byteena_a     (1'b1),
 .byteena_b     (1'b1),
 .clocken0      (1'b1),
 .clocken1      (1'b1),
 .clocken2      (1'b1),
 .clocken3      (1'b1),
 .data_b        ({16{1'b1}}),
 .eccstatus     (),
 .q_a           (),
 .rden_a        (1'b1),
 .rden_b        (1'b1),
 .wren_b        (1'b0)
);
//------------------------------------------------------------------------------

reg JTAG_Reset;
reg JTAG_Busy;

always @(posedge TCK) begin
 JTAG_Reset <= Reset;

 if(JTAG_Reset) begin
  TDO       <= 0;
  WrAddress <= 0;
  JTAG_Busy <= 0;
  
 end else begin
  case(1'b1)
   Capture: begin
    WrAddress <= 0;
    JTAG_Busy <= 1'b1;
   end

   Shift: begin
    WrAddress <= WrAddress + 1'b1;
   end

   Update: begin
    JTAG_Busy <= 1'b0;
   end
   default:;
  endcase
 end
end
//------------------------------------------------------------------------------

reg       Local_Reset;
reg [ 1:0]TCK_Sync;
reg [12:0]WrAddress_Sync;
reg       Capture_Sync;

always @(posedge Clk) begin
 Local_Reset  <=  Reset;
 TCK_Sync     <= {TCK_Sync[0], TCK};
 Capture_Sync <=  Capture;
//------------------------------------------------------------------------------

 if(Local_Reset || Capture_Sync) begin
  Avalon_Address <= 0;
  Avalon_Write   <= 0;
  WrAddress_Sync <= 0;
//------------------------------------------------------------------------------

 end else begin
  if(TCK_Sync == 2'b10) WrAddress_Sync <= WrAddress;

  if(~Avalon_Write) begin // Idle
   if(WrAddress_Sync[12:4] != Avalon_Address[8:0]) begin
    Busy         <= 1'b1;
    Avalon_Write <= 1'b1;

   end else begin
    Busy <= JTAG_Busy;
   end

  end else begin // Writing
   if(~Avalon_WaitRequest) begin
    Avalon_Address <= Avalon_Address + 1'b1;
    Avalon_Write   <= 0;
   end
  end
 end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------

