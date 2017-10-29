-- VHDL Entity BCtr_lib.pps_sbbd.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 15:39:17 10/26/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY pps_sbbd IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 downto 0)     := x"0060";
    CLK_FREQ   : unsigned(31 downto 0)     := to_unsigned(100000000,32)
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : IN     std_logic;
    ExpReset : IN     std_logic;
    ExpWr    : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    clk      : IN     std_logic;
    ExpAck   : OUT    std_logic;
    PPS      : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0)
  );

-- Declarations

END ENTITY pps_sbbd ;

--
-- VHDL Architecture BCtr_lib.pps_sbbd.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 15:39:17 10/26/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--

-- Generation properties:
--   Component declarations : yes
--   Configurations         : embedded statements
--                          : add pragmas
--                          : exclude view name
--   
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY BCtr_lib;

ARCHITECTURE struct OF pps_sbbd IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL BdEn   : std_logic;
  SIGNAL BdWrEn : std_logic;
  SIGNAL RdEn   : std_logic;
  SIGNAL WrEn   : std_logic;


  -- Component Declarations
  COMPONENT ppsgen
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := x"0060";
    CLK_FREQ   : unsigned(31 DOWNTO 0)     := to_unsigned(100000000,32);
    MSW_SHIFT  : integer range 16 downto 0 := 11
  );
  PORT (
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpReset : IN     std_logic;
    RdEn     : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    WrEn     : IN     std_logic;
    clk      : IN     std_logic;
    BdEn     : OUT    std_logic;
    BdWrEn   : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    pps      : OUT    std_logic
  );
  END COMPONENT ppsgen;
  COMPONENT subbus_io
  GENERIC (
    USE_BD_WR_EN : std_logic := '0'
  );
  PORT (
    BdEn   : IN     std_logic;
    BdWrEn : IN     std_logic;
    ExpRd  : IN     std_logic;
    ExpWr  : IN     std_logic;
    F8M    : IN     std_logic;
    ExpAck : OUT    std_logic;
    RdEn   : OUT    std_logic;
    WrEn   : OUT    std_logic
  );
  END COMPONENT subbus_io;

  -- Optional embedded configurations
  -- pragma synthesis_off
  FOR ALL : ppsgen USE ENTITY BCtr_lib.ppsgen;
  FOR ALL : subbus_io USE ENTITY BCtr_lib.subbus_io;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  U_1 : ppsgen
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => BASE_ADDR,
      CLK_FREQ   => CLK_FREQ
    )
    PORT MAP (
      clk      => clk,
      pps      => PPS,
      ExpAddr  => ExpAddr,
      WData    => WData,
      RData    => RData,
      RdEn     => RdEn,
      WrEn     => WrEn,
      BdEn     => BdEn,
      BdWrEn   => BdWrEn,
      ExpReset => ExpReset
    );
  U_0 : subbus_io
    GENERIC MAP (
      USE_BD_WR_EN => '1'
    )
    PORT MAP (
      ExpRd  => ExpRd,
      ExpWr  => ExpWr,
      ExpAck => ExpAck,
      F8M    => clk,
      RdEn   => RdEn,
      WrEn   => WrEn,
      BdEn   => BdEn,
      BdWrEn => BdWrEn
    );

END ARCHITECTURE struct;
