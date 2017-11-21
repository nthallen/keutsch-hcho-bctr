# clk, uart, reset are handled by board definition
# For Build 7, uart will be mapped to pads

# FAIL to led[0]
# Trigger to PIO.46  W7  J6
# PMTS[0] to PIO.43  W6  J7
# PMTS[1] to PIO.40  W4  J8
# SimTrig to PIO.1   M3  E22
# SimPMT  to PIO.3   A16 E24
#
# temp_scl to SCL1 at PIO.35 V3
# temp_sda to SDA1 at PIO.34 W3
# aio_scl to SCL3 at PIO.31 U1
# aio_sda to SDA3 at PIO.30 T2
# aio_scl_mon to SCL2, J5.3 at PIO.33 V2
# aio_sda_mon to SDA2, J5.4 at PIO.32 W2
# htr1_cmd to htr1, PIO.47 U8
# htr2_cmd to htr2, PIO.41 U5
# dac_reset, PIO.45 U7
# dac_ldac, PIO.44 U3
#
# uart_rx, E18 PIO.38 U4
# uart_tx, E19 PIO.37 V4
#
#create_clock -period 10 [get_ports { PMTs[0] }];
#create_clock -period 10 [get_ports { PMTs[1] }];
#create_clock -period 10 [get_ports Trigger];

set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports Fail]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {PMTs[0]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {PMTs[1]}]
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports Trigger]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports SimPMT]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports SimTrig]

set_property PACKAGE_PIN V3 [get_ports temp_scl]
set_property IOSTANDARD LVCMOS33 [get_ports temp_scl]
set_property PULLUP true [get_ports temp_scl]
set_property PACKAGE_PIN W3 [get_ports temp_sda]
set_property IOSTANDARD LVCMOS33 [get_ports temp_sda]
set_property PULLUP true [get_ports temp_sda]

set_property PACKAGE_PIN U1 [get_ports aio_scl]
set_property IOSTANDARD LVCMOS33 [get_ports aio_scl]
set_property PULLUP true [get_ports aio_scl]
set_property PACKAGE_PIN T2 [get_ports aio_sda]
set_property IOSTANDARD LVCMOS33 [get_ports aio_sda]
set_property PULLUP true [get_ports aio_sda]

set_property PACKAGE_PIN V2 [get_ports aio_scl_mon]
set_property IOSTANDARD LVCMOS33 [get_ports aio_scl_mon]
set_property PACKAGE_PIN W2 [get_ports aio_sda_mon]
set_property IOSTANDARD LVCMOS33 [get_ports aio_sda_mon]

set_property PACKAGE_PIN U8 [get_ports htr1_cmd]
set_property IOSTANDARD LVCMOS33 [get_ports htr1_cmd]
set_property PACKAGE_PIN U5 [get_ports htr2_cmd]
set_property IOSTANDARD LVCMOS33 [get_ports htr2_cmd]

set_property PACKAGE_PIN U7 [get_ports dac_reset]
set_property IOSTANDARD LVCMOS33 [get_ports dac_reset]
set_property PACKAGE_PIN U3 [get_ports dac_ldac]
set_property IOSTANDARD LVCMOS33 [get_ports dac_ldac]

set_property PACKAGE_PIN U4 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN V4 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
