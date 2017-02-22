-- VHDL Entity i2c_slave.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-NBX200T)
--          at - 16:49:15 07/19/2013
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2012.1 (Build 6)
--
-- For reading from the slave, if RE = '1', rdata is used for the
-- serialized output data. If RE is left open or '0', an internal
-- counter is used, starting at 0x55.
--
-- For writing to the slave, once the serialized data is received,
-- it is presented on wdata and the WE output is asserted.
--
-- The start and stop outputs simply identify the bit-level I2C
-- states, and are present primarily for diagnostic purposes.
--
-- 
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY i2c_slave IS
   GENERIC( 
      I2C_ADDR : std_logic_vector(6 DOWNTO 0) := "1000000"
   );
   PORT( 
      clk   : IN     std_logic;
      rdata : IN     std_logic_vector (7 DOWNTO 0);
      rst   : IN     std_logic;
      scl   : IN     std_logic;
      en    : IN     std_logic;
      WE    : OUT    std_logic;
      start : OUT    std_logic;
      stop  : OUT    std_logic;
      wdata : OUT    std_logic_vector (7 DOWNTO 0);
      rdreq : OUT    std_logic;
      RE    : INOUT  std_logic;
      sda   : INOUT  std_logic
   );

-- Declarations

END i2c_slave ;

--
-- VHDL Architecture i2c_slave.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-NBX200T)
--          at - 16:49:15 07/19/2013
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2012.1 (Build 6)
--
--  Copyright 2011 President and Fellows of Harvard College
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ARCHITECTURE struct OF i2c_slave IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL err  : std_logic;
   SIGNAL stop_internal : std_logic;

   -- Implicit buffer signal declarations
   SIGNAL start_internal : std_logic;


   -- Component Declarations
   COMPONENT i2c_slave_bits
   GENERIC (
      I2C_ADDR : std_logic_vector(6 downto 0) := "1000000"
   );
   PORT (
      clk   : IN     std_logic;
      err   : IN     std_logic;
      rdata : IN     std_logic_vector (7 DOWNTO 0);
      rst   : IN     std_logic;
      scl   : IN     std_logic;
      start : IN     std_logic;
      stop  : IN     std_logic;
      en    : IN     std_logic;
      WE    : OUT    std_logic;
      wdata : OUT    std_logic_vector (7 DOWNTO 0);
      rdreq : OUT    std_logic;
      RE    : INOUT  std_logic;
      sda   : INOUT  std_logic 
   );
   END COMPONENT;
   COMPONENT i2c_slave_sup
   PORT (
      clk    : IN     std_logic;
      rst    : IN     std_logic;
      scl_in : IN     std_logic;
      sda_in : IN     std_logic;
      err    : OUT    std_logic;
      start  : OUT    std_logic;
      stop   : OUT    std_logic 
   );
   END COMPONENT;

   -- Optional embedded configurations

BEGIN

   -- Instance port mappings.
   U_0 : i2c_slave_bits
      GENERIC MAP (
         I2C_ADDR => I2C_ADDR
      )
      PORT MAP (
         clk   => clk,
         err   => err,
         rdata => rdata,
         rst   => rst,
         scl   => scl,
         en    => en,
         start => start_internal,
         stop  => stop_internal,
         WE    => WE,
         wdata => wdata,
         rdreq => rdreq,
         RE    => RE,
         sda   => sda
      );
   U_1 : i2c_slave_sup
      PORT MAP (
         clk    => clk,
         rst    => rst,
         scl_in => scl,
         sda_in => sda,
         err    => err,
         start  => start_internal,
         stop   => stop_internal
      );

   -- Implicit buffered output assignments
   start <= start_internal;
   stop <= stop_internal;

END struct;
