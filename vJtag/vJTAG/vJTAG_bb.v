
module vJTAG (
	tdi,
	tdo,
	ir_in,
	ir_out,
	virtual_state_cdr,
	virtual_state_sdr,
	virtual_state_e1dr,
	virtual_state_pdr,
	virtual_state_e2dr,
	virtual_state_udr,
	virtual_state_cir,
	virtual_state_uir,
	tck);	

	output		tdi;
	input		tdo;
	output	[0:0]	ir_in;
	input	[0:0]	ir_out;
	output		virtual_state_cdr;
	output		virtual_state_sdr;
	output		virtual_state_e1dr;
	output		virtual_state_pdr;
	output		virtual_state_e2dr;
	output		virtual_state_udr;
	output		virtual_state_cir;
	output		virtual_state_uir;
	output		tck;
endmodule
