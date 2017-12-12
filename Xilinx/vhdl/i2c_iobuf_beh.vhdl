--
-- VHDL Architecture idx_fpga_lib.i2c_iobuf.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 20:30:36 05/ 7/2015
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY i2c_iobuf IS
  PORT( 
    padoen_o : IN     std_logic;
    pad_i    : OUT    std_logic;
    pad_io   : INOUT  std_logic
  );

END ENTITY i2c_iobuf ;

ARCHITECTURE beh OF i2c_iobuf IS
BEGIN
  IOBUF_inst : IOBUF
    port map (
      O  => pad_i, -- Buffer output
      IO => pad_io, -- Buffer inout port (connect directly to top-level port)
      I  => '0', -- Buffer input
      T  => padoen_o -- 3-state enable input, high=input, low=output
    );
END ARCHITECTURE beh;
