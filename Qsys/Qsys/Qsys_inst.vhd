	component Qsys is
		port (
			clk_clk                 : in    std_logic                     := 'X';             -- clk
			reset_reset_n           : in    std_logic                     := 'X';             -- reset_n
			interface_address       : in    std_logic_vector(24 downto 0) := (others => 'X'); -- address
			interface_byteenable_n  : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- byteenable_n
			interface_chipselect    : in    std_logic                     := 'X';             -- chipselect
			interface_writedata     : in    std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			interface_read_n        : in    std_logic                     := 'X';             -- read_n
			interface_write_n       : in    std_logic                     := 'X';             -- write_n
			interface_readdata      : out   std_logic_vector(15 downto 0);                    -- readdata
			interface_readdatavalid : out   std_logic;                                        -- readdatavalid
			interface_waitrequest   : out   std_logic;                                        -- waitrequest
			wires_addr              : out   std_logic_vector(12 downto 0);                    -- addr
			wires_ba                : out   std_logic_vector(1 downto 0);                     -- ba
			wires_cas_n             : out   std_logic;                                        -- cas_n
			wires_cke               : out   std_logic;                                        -- cke
			wires_cs_n              : out   std_logic;                                        -- cs_n
			wires_dq                : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			wires_dqm               : out   std_logic_vector(1 downto 0);                     -- dqm
			wires_ras_n             : out   std_logic;                                        -- ras_n
			wires_we_n              : out   std_logic                                         -- we_n
		);
	end component Qsys;

	u0 : component Qsys
		port map (
			clk_clk                 => CONNECTED_TO_clk_clk,                 --       clk.clk
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --     reset.reset_n
			interface_address       => CONNECTED_TO_interface_address,       -- interface.address
			interface_byteenable_n  => CONNECTED_TO_interface_byteenable_n,  --          .byteenable_n
			interface_chipselect    => CONNECTED_TO_interface_chipselect,    --          .chipselect
			interface_writedata     => CONNECTED_TO_interface_writedata,     --          .writedata
			interface_read_n        => CONNECTED_TO_interface_read_n,        --          .read_n
			interface_write_n       => CONNECTED_TO_interface_write_n,       --          .write_n
			interface_readdata      => CONNECTED_TO_interface_readdata,      --          .readdata
			interface_readdatavalid => CONNECTED_TO_interface_readdatavalid, --          .readdatavalid
			interface_waitrequest   => CONNECTED_TO_interface_waitrequest,   --          .waitrequest
			wires_addr              => CONNECTED_TO_wires_addr,              --     wires.addr
			wires_ba                => CONNECTED_TO_wires_ba,                --          .ba
			wires_cas_n             => CONNECTED_TO_wires_cas_n,             --          .cas_n
			wires_cke               => CONNECTED_TO_wires_cke,               --          .cke
			wires_cs_n              => CONNECTED_TO_wires_cs_n,              --          .cs_n
			wires_dq                => CONNECTED_TO_wires_dq,                --          .dq
			wires_dqm               => CONNECTED_TO_wires_dqm,               --          .dqm
			wires_ras_n             => CONNECTED_TO_wires_ras_n,             --          .ras_n
			wires_we_n              => CONNECTED_TO_wires_we_n               --          .we_n
		);

