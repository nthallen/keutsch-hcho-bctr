-- VHDL Entity BCtr_lib.dacscan_sbbd.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 12:06:12 11/19/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY dacscan_sbbd IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8      := 8;
    BASE_ADDR  : std_logic_vector (15 downto 0) := x"0080"
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : IN     std_logic;
    ExpReset : IN     std_logic;
    ExpWr    : IN     std_logic;
    IPS      : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    clk      : IN     std_logic;
    idxAck   : IN     std_logic;
    ExpAck   : OUT    std_logic;
    LDAC     : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    SetPoint : OUT    std_logic_vector (15 DOWNTO 0);
    idxData  : OUT    std_logic_vector (15 DOWNTO 0);
    idxWr    : OUT    std_logic
  );

-- Declarations

END ENTITY dacscan_sbbd ;

--
-- VHDL Architecture BCtr_lib.dacscan_sbbd.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 12:06:12 11/19/2017
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

ARCHITECTURE struct OF dacscan_sbbd IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL BdEn   : std_logic;
  SIGNAL BdWrEn : std_logic;
  SIGNAL RdEn   : std_logic;
  SIGNAL WrEn   : std_logic;


  -- Component Declarations
  COMPONENT dacscan
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := x"0080";
    STEP_RES   : integer range 8 downto 0  := 3
  );
  PORT (
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpReset : IN     std_logic ;
    IPS      : IN     std_logic ;
    RdEn     : IN     std_logic ;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    WrEn     : IN     std_logic ;
    clk      : IN     std_logic ;
    idxAck   : IN     std_logic ;
    BdEn     : OUT    std_logic ;
    BdWrEn   : OUT    std_logic ;
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    idxData  : OUT    std_logic_vector (15 DOWNTO 0);
    idxWr    : OUT    std_logic ;
    LDAC     : OUT    std_logic ;
    SetPoint : OUT    std_logic_vector (15 DOWNTO 0)
  );
  END COMPONENT dacscan;
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
  FOR ALL : dacscan USE ENTITY BCtr_lib.dacscan;
  FOR ALL : subbus_io USE ENTITY BCtr_lib.subbus_io;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  scan : dacscan
    GENERIC MAP (
      ADDR_WIDTH => 8,
      BASE_ADDR  => x"0080",
      STEP_RES   => 3
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpReset => ExpReset,
      IPS      => IPS,
      RdEn     => RdEn,
      WData    => WData,
      WrEn     => WrEn,
      clk      => clk,
      idxAck   => idxAck,
      BdEn     => BdEn,
      BdWrEn   => BdWrEn,
      RData    => RData,
      idxData  => idxData,
      idxWr    => idxWr,
      LDAC     => LDAC,
      SetPoint => SetPoint
    );
  subbus : subbus_io
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
