set_false_path -from * -to [get_ports LED*]
set_false_path -from * -to [get_ports out]
set_false_path -to * -from [get_ports Switch*]
set_false_path -to * -from [get_ports Button*]
set_false_path -to * -from [get_ports reset_n*]
set_false_path -from * -to [get_ports Arduino_IO*]
set_false_path -to * -from [get_ports SW*]

create_clock -period 20 [get_ports CLK]
derive_pll_clocks -create_base_clocks -use_net_name
derive_clock_uncertainty
# Reference the SDRAM clock to the pin
create_generated_clock \
-source [get_pins {my_PLL|altpll_component|auto_generated|pll1|clk[1]}] \
-name DRAM_CLK [get_ports {SDRAM_Clock}]

set_clock_groups -logically_exclusive \
-group [get_clocks CLK] \
-group [get_clocks {DRAM_CLK *my_PLL*}]

set_multicycle_path -from [get_clocks {DRAM_CLK}] -to [get_clocks {*altpll_component*clk[0]}] -setup 2

# Suppose 100 ps uncertainty
set_output_delay -max -clock DRAM_CLK 1.6 [get_ports OP_DRAM*]
set_output_delay -min -clock DRAM_CLK -0.9 [get_ports OP_DRAM*]
set_output_delay -max -clock DRAM_CLK 1.6 [get_ports BP_DRAM*]
set_output_delay -min -clock DRAM_CLK -0.9 [get_ports BP_DRAM*]
# Suppose 100 ps uncertainty and 200 ps PCB delay (each way)
set_input_delay -max -clock DRAM_CLK 5.9 [get_ports BP_DRAM*]
set_input_delay -min -clock DRAM_CLK 3.0 [get_ports BP_DRAM*]

# Don't specify the altera_reserved_tck frequency,
# Quartus knows what it is.
set_clock_groups -exclusive \
-group [get_clocks {altera_reserved_tck}]
set_input_delay -clock altera_reserved_tck 20 \
[get_ports {altera_reserved_tdi}]
set_input_delay -clock altera_reserved_tck 20 \
[get_ports {altera_reserved_tms}]
set_output_delay -clock altera_reserved_tck 20 \
[get_ports {altera_reserved_tdo}]
