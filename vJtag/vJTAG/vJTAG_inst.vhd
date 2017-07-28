	component vJTAG is
		port (
			tdi                : out std_logic;                                       -- tdi
			tdo                : in  std_logic                    := 'X';             -- tdo
			ir_in              : out std_logic_vector(0 downto 0);                    -- ir_in
			ir_out             : in  std_logic_vector(0 downto 0) := (others => 'X'); -- ir_out
			virtual_state_cdr  : out std_logic;                                       -- virtual_state_cdr
			virtual_state_sdr  : out std_logic;                                       -- virtual_state_sdr
			virtual_state_e1dr : out std_logic;                                       -- virtual_state_e1dr
			virtual_state_pdr  : out std_logic;                                       -- virtual_state_pdr
			virtual_state_e2dr : out std_logic;                                       -- virtual_state_e2dr
			virtual_state_udr  : out std_logic;                                       -- virtual_state_udr
			virtual_state_cir  : out std_logic;                                       -- virtual_state_cir
			virtual_state_uir  : out std_logic;                                       -- virtual_state_uir
			tck                : out std_logic                                        -- clk
		);
	end component vJTAG;

	u0 : component vJTAG
		port map (
			tdi                => CONNECTED_TO_tdi,                -- jtag.tdi
			tdo                => CONNECTED_TO_tdo,                --     .tdo
			ir_in              => CONNECTED_TO_ir_in,              --     .ir_in
			ir_out             => CONNECTED_TO_ir_out,             --     .ir_out
			virtual_state_cdr  => CONNECTED_TO_virtual_state_cdr,  --     .virtual_state_cdr
			virtual_state_sdr  => CONNECTED_TO_virtual_state_sdr,  --     .virtual_state_sdr
			virtual_state_e1dr => CONNECTED_TO_virtual_state_e1dr, --     .virtual_state_e1dr
			virtual_state_pdr  => CONNECTED_TO_virtual_state_pdr,  --     .virtual_state_pdr
			virtual_state_e2dr => CONNECTED_TO_virtual_state_e2dr, --     .virtual_state_e2dr
			virtual_state_udr  => CONNECTED_TO_virtual_state_udr,  --     .virtual_state_udr
			virtual_state_cir  => CONNECTED_TO_virtual_state_cir,  --     .virtual_state_cir
			virtual_state_uir  => CONNECTED_TO_virtual_state_uir,  --     .virtual_state_uir
			tck                => CONNECTED_TO_tck                 --  tck.clk
		);

