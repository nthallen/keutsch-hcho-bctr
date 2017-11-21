-- VHDL Entity BCtr_lib.BCtr2_sbbd.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:21:02 11/20/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr2_sbbd IS
  GENERIC( 
    ADDR_WIDTH      : integer range 16 downto 8  := 8;
    BASE_ADDR       : unsigned(15 downto 0)      := X"0010";
    FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9;
    N_CHANNELS      : integer range 4 downto 1   := 1;
    CTR_WIDTH       : integer range 32 downto 1  := 16;
    FIFO_WIDTH      : integer range 128 downto 1 := 16
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : IN     std_logic;
    ExpReset : IN     std_logic;
    ExpWr    : IN     std_logic;
    IPS      : IN     std_logic;
    IPnum    : IN     std_logic_vector (5 DOWNTO 0);
    LaserV   : IN     std_logic_vector (15 DOWNTO 0);
    PMTs     : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    Trigger  : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    clk      : IN     std_logic;
    ExpAck   : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0)
  );

-- Declarations

END ENTITY BCtr2_sbbd ;

--
-- VHDL Architecture BCtr_lib.BCtr2_sbbd.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:21:02 11/20/2017
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

-- LIBRARY BCtr_lib;

ARCHITECTURE struct OF BCtr2_sbbd IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL BdEn       : std_logic;
  SIGNAL BdWrEn     : std_logic;
  SIGNAL CData      : std_logic_vector(15 DOWNTO 0);
  SIGNAL C_Dbar     : std_logic;
  SIGNAL CfgAddr    : unsigned(3 DOWNTO 0);
  SIGNAL CfgStatus  : std_logic_vector(5 DOWNTO 0);
  SIGNAL DData      : std_logic_vector(15 DOWNTO 0);
  SIGNAL DRdy       : std_logic;
  SIGNAL DataAddr   : std_logic_vector(1 DOWNTO 0);
  SIGNAL En         : std_logic;
  SIGNAL Expired    : std_logic;
  SIGNAL IPnumOut   : std_logic_vector(5 DOWNTO 0);
  SIGNAL LaserVOut  : std_logic_vector(15 DOWNTO 0);
  SIGNAL NA         : unsigned(15 DOWNTO 0);
  SIGNAL NArd       : std_logic;
  SIGNAL NBtot      : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NTriggered : std_logic_vector(31 DOWNTO 0);
  SIGNAL RdEn       : std_logic;
  SIGNAL RptData    : std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
  SIGNAL RptRE      : std_logic;
  SIGNAL TrigArm    : std_logic;
  SIGNAL WrEn       : std_logic;
  SIGNAL rst        : std_logic;
  SIGNAL txing      : std_logic;


  -- Component Declarations
  COMPONENT BCtr2
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9;
    N_CHANNELS      : integer range 4 downto 1   := 1;
    CTR_WIDTH       : integer range 32 downto 1  := 16;
    FIFO_WIDTH      : integer range 128 downto 1 := 16
  );
  PORT (
    En         : IN     std_logic ;
    IPS        : IN     std_logic ;
    IPnum      : IN     std_logic_vector (5 DOWNTO 0);
    LaserV     : IN     std_logic_vector (15 DOWNTO 0);
    NA         : IN     unsigned (15 DOWNTO 0);
    NBtot      : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    PMTs       : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    RptRE      : IN     std_logic ;
    Trigger    : IN     std_logic ;
    clk        : IN     std_logic ;
    rst        : IN     std_logic ;
    txing      : IN     std_logic ;
    DRdy       : OUT    std_logic ;
    Expired    : OUT    std_logic ;
    IPnumOut   : OUT    std_logic_vector (5 DOWNTO 0);
    LaserVOut  : OUT    std_logic_vector (15 DOWNTO 0);
    NArd       : OUT    std_logic ;
    NTriggered : OUT    std_logic_vector (31 DOWNTO 0);
    RptData    : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    TrigArm    : OUT    std_logic 
  );
  END COMPONENT BCtr2;
  COMPONENT BCtr2_Addr
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := X"0010"
  );
  PORT (
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    BdEn     : OUT    std_logic ;
    BdWrEn   : OUT    std_logic ;
    C_Dbar   : OUT    std_logic ;
    CfgAddr  : OUT    unsigned (3 DOWNTO 0);
    DataAddr : OUT    std_logic_vector (1 DOWNTO 0)
  );
  END COMPONENT BCtr2_Addr;
  COMPONENT BCtr2_cfg
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT (
    CfgAddr   : IN     unsigned (3 DOWNTO 0);
    ExpReset  : IN     std_logic ;
    WData     : IN     std_logic_vector (15 DOWNTO 0);
    clk       : IN     std_logic ;
    CData     : OUT    std_logic_vector (15 DOWNTO 0);
    En        : OUT    std_logic ;
    NA        : OUT    unsigned (15 DOWNTO 0);
    NBtot     : OUT    unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    rst       : OUT    std_logic ;
    WrEn      : IN     std_logic ;
    RdEn      : IN     std_logic ;
    NArd      : IN     std_logic ;
    TrigArm   : IN     std_logic ;
    CfgStatus : OUT    std_logic_vector (5 DOWNTO 0)
  );
  END COMPONENT BCtr2_cfg;
  COMPONENT BCtr2_data
  GENERIC (
    N_CHANNELS      : integer range 4 downto 1   := 2;
    CTR_WIDTH       : integer range 32 downto 16 := 24;
    FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9;
    FIFO_WIDTH      : integer range 128 downto 1 := 48
  );
  PORT (
    CfgStatus  : IN     std_logic_vector (5 DOWNTO 0);
    DRdy       : IN     std_logic ;
    DataAddr   : IN     std_logic_vector (1 DOWNTO 0);
    En         : IN     std_logic ;
    Expired    : IN     std_logic ;
    IPnumOut   : IN     std_logic_vector (5 DOWNTO 0);
    LaserVOut  : IN     std_logic_vector (15 DOWNTO 0);
    NBtot      : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NTriggered : IN     std_logic_vector (31 DOWNTO 0);
    RdEn       : IN     std_logic ;
    RptData    : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    clk        : IN     std_logic ;
    rst        : IN     std_logic ;
    DData      : OUT    std_logic_vector (15 DOWNTO 0);
    RptRE      : OUT    std_logic ;
    txing      : OUT    std_logic 
  );
  END COMPONENT BCtr2_data;
  COMPONENT BCtr_Dmux
  PORT (
    CData  : IN     std_logic_vector (15 DOWNTO 0);
    C_Dbar : IN     std_logic;
    DData  : IN     std_logic_vector (15 DOWNTO 0);
    RData  : OUT    std_logic_vector (15 DOWNTO 0)
  );
  END COMPONENT BCtr_Dmux;
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
-- FOR ALL : BCtr2 USE ENTITY BCtr_lib.BCtr2;
-- FOR ALL : BCtr2_Addr USE ENTITY BCtr_lib.BCtr2_Addr;
-- FOR ALL : BCtr2_cfg USE ENTITY BCtr_lib.BCtr2_cfg;
-- FOR ALL : BCtr2_data USE ENTITY BCtr_lib.BCtr2_data;
-- FOR ALL : BCtr_Dmux USE ENTITY BCtr_lib.BCtr_Dmux;
-- FOR ALL : subbus_io USE ENTITY BCtr_lib.subbus_io;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  BCtr : BCtr2
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
      N_CHANNELS      => N_CHANNELS,
      CTR_WIDTH       => CTR_WIDTH,
      FIFO_WIDTH      => FIFO_WIDTH
    )
    PORT MAP (
      En         => En,
      IPS        => IPS,
      IPnum      => IPnum,
      LaserV     => LaserV,
      NA         => NA,
      NBtot      => NBtot,
      PMTs       => PMTs,
      RptRE      => RptRE,
      Trigger    => Trigger,
      clk        => clk,
      rst        => rst,
      txing      => txing,
      DRdy       => DRdy,
      Expired    => Expired,
      IPnumOut   => IPnumOut,
      LaserVOut  => LaserVOut,
      NArd       => NArd,
      NTriggered => NTriggered,
      RptData    => RptData,
      TrigArm    => TrigArm
    );
  Addr : BCtr2_Addr
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => BASE_ADDR
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      BdEn     => BdEn,
      BdWrEn   => BdWrEn,
      C_Dbar   => C_Dbar,
      CfgAddr  => CfgAddr,
      DataAddr => DataAddr
    );
  cfg : BCtr2_cfg
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      CfgAddr   => CfgAddr,
      ExpReset  => ExpReset,
      WData     => WData,
      clk       => clk,
      CData     => CData,
      En        => En,
      NA        => NA,
      NBtot     => NBtot,
      rst       => rst,
      WrEn      => WrEn,
      RdEn      => RdEn,
      NArd      => NArd,
      TrigArm   => TrigArm,
      CfgStatus => CfgStatus
    );
  data : BCtr2_data
    GENERIC MAP (
      N_CHANNELS      => N_CHANNELS,
      CTR_WIDTH       => CTR_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
      FIFO_WIDTH      => FIFO_WIDTH
    )
    PORT MAP (
      CfgStatus  => CfgStatus,
      DRdy       => DRdy,
      DataAddr   => DataAddr,
      En         => En,
      Expired    => Expired,
      IPnumOut   => IPnumOut,
      LaserVOut  => LaserVOut,
      NBtot      => NBtot,
      NTriggered => NTriggered,
      RdEn       => RdEn,
      RptData    => RptData,
      clk        => clk,
      rst        => rst,
      DData      => DData,
      RptRE      => RptRE,
      txing      => txing
    );
  dmux : BCtr_Dmux
    PORT MAP (
      CData  => CData,
      C_Dbar => C_Dbar,
      DData  => DData,
      RData  => RData
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