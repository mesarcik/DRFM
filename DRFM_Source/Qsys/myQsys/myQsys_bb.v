
module myQsys (
	clk_clk,
	reset_reset_n,
	interface_address,
	interface_byteenable_n,
	interface_chipselect,
	interface_writedata,
	interface_read_n,
	interface_write_n,
	interface_readdata,
	interface_readdatavalid,
	interface_waitrequest,
	wires_addr,
	wires_ba,
	wires_cas_n,
	wires_cke,
	wires_cs_n,
	wires_dq,
	wires_dqm,
	wires_ras_n,
	wires_we_n);	

	input		clk_clk;
	input		reset_reset_n;
	input	[24:0]	interface_address;
	input	[1:0]	interface_byteenable_n;
	input		interface_chipselect;
	input	[15:0]	interface_writedata;
	input		interface_read_n;
	input		interface_write_n;
	output	[15:0]	interface_readdata;
	output		interface_readdatavalid;
	output		interface_waitrequest;
	output	[12:0]	wires_addr;
	output	[1:0]	wires_ba;
	output		wires_cas_n;
	output		wires_cke;
	output		wires_cs_n;
	inout	[15:0]	wires_dq;
	output	[1:0]	wires_dqm;
	output		wires_ras_n;
	output		wires_we_n;
endmodule
