	myQsys u0 (
		.clk_clk                 (<connected-to-clk_clk>),                 //       clk.clk
		.reset_reset_n           (<connected-to-reset_reset_n>),           //     reset.reset_n
		.interface_address       (<connected-to-interface_address>),       // interface.address
		.interface_byteenable_n  (<connected-to-interface_byteenable_n>),  //          .byteenable_n
		.interface_chipselect    (<connected-to-interface_chipselect>),    //          .chipselect
		.interface_writedata     (<connected-to-interface_writedata>),     //          .writedata
		.interface_read_n        (<connected-to-interface_read_n>),        //          .read_n
		.interface_write_n       (<connected-to-interface_write_n>),       //          .write_n
		.interface_readdata      (<connected-to-interface_readdata>),      //          .readdata
		.interface_readdatavalid (<connected-to-interface_readdatavalid>), //          .readdatavalid
		.interface_waitrequest   (<connected-to-interface_waitrequest>),   //          .waitrequest
		.wires_addr              (<connected-to-wires_addr>),              //     wires.addr
		.wires_ba                (<connected-to-wires_ba>),                //          .ba
		.wires_cas_n             (<connected-to-wires_cas_n>),             //          .cas_n
		.wires_cke               (<connected-to-wires_cke>),               //          .cke
		.wires_cs_n              (<connected-to-wires_cs_n>),              //          .cs_n
		.wires_dq                (<connected-to-wires_dq>),                //          .dq
		.wires_dqm               (<connected-to-wires_dqm>),               //          .dqm
		.wires_ras_n             (<connected-to-wires_ras_n>),             //          .ras_n
		.wires_we_n              (<connected-to-wires_we_n>)               //          .we_n
	);

