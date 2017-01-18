--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
--Date        : Sun Jan 15 11:18:41 2017
--Host        : nort-xps14 running 64-bit Service Pack 1  (build 7601)
--Command     : generate_target BCtr_block_wrapper.bd
--Design      : BCtr_block_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity BCtr_block_wrapper is
  port (
    Fail : out STD_LOGIC;
    PMTs : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SimPMT : out STD_LOGIC;
    SimTrig : out STD_LOGIC;
    Trigger : in STD_LOGIC;
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    usb_uart_rxd : in STD_LOGIC;
    usb_uart_txd : out STD_LOGIC
  );
  attribute clock_buffer_type : string;
  attribute clock_buffer_type of Trigger: signal is "BUFR";
  attribute clock_buffer_type of PMTs: signal is "BUFR";
end BCtr_block_wrapper;

architecture STRUCTURE of BCtr_block_wrapper is
  component BCtr_block is
  port (
    reset : in STD_LOGIC;
    sys_clock : in STD_LOGIC;
    PMTs : in STD_LOGIC_VECTOR ( 1 downto 0 );
    SimTrig : out STD_LOGIC;
    SimPMT : out STD_LOGIC;
    Trigger : in STD_LOGIC;
    Fail : out STD_LOGIC_VECTOR ( 0 to 0 );
    usb_uart_rxd : in STD_LOGIC;
    usb_uart_txd : out STD_LOGIC
  );
  end component BCtr_block;
begin
BCtr_block_i: component BCtr_block
     port map (
      Fail(0) => Fail,
      PMTs(1 downto 0) => PMTs(1 downto 0),
      SimPMT => SimPMT,
      SimTrig => SimTrig,
      Trigger => Trigger,
      reset => reset,
      sys_clock => sys_clock,
      usb_uart_rxd => usb_uart_rxd,
      usb_uart_txd => usb_uart_txd
    );
end STRUCTURE;
