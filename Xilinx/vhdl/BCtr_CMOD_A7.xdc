# clk, uart, reset are handled by board definition

# FAIL to led[0]
# Trigger to PIO.46  W7
# PMTS[0] to PIO.43  W6
# PMTS[1] to PIO.40  W4
# SimTrig to PIO.1   M3
# SimPMT  to PIO.3   A16
#create_clock -period 10 [get_ports { PMTs[0] }];
#create_clock -period 10 [get_ports { PMTs[1] }];
#create_clock -period 10 [get_ports Trigger];

set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports Fail]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {PMTs[0]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {PMTs[1]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports Trigger]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports SimPMT]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports SimTrig]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property MARK_DEBUG true [get_nets BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/DRdy]
set_property MARK_DEBUG false [get_nets BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/En]
set_property MARK_DEBUG true [get_nets BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/Empty1]
set_property MARK_DEBUG true [get_nets BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/Empty2]
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list BCtr_block_i/clk_wiz_1/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 1 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/DRdy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 1 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/Empty1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list BCtr_block_i/BCtr_syscon_wrapper_0/U0/U_0/adjgatectr/Empty2]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_0_clk_out1]
