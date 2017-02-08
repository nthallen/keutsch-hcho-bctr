# clk, uart, reset are handled by board definition

# FAIL to led[0]
# Trigger to PIO.46  W7
# PMTS[0] to PIO.43  W6
# PMTS[1] to PIO.40  W4
# SimTrig to PIO.1   M3
# SimPMT  to PIO.3   A16
#
# temp_scl to PIO.35 V3
# temp.sda to PIO.34 W3
#create_clock -period 10 [get_ports { PMTs[0] }];
#create_clock -period 10 [get_ports { PMTs[1] }];
#create_clock -period 10 [get_ports Trigger];

set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports Fail]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {PMTs[0]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {PMTs[1]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports Trigger]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports SimPMT]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports SimTrig]

set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33 PULLUP true} [get_ports temp_scl]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33 PULLUP true} [get_ports temp_sda]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
