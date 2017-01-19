-- VHDL Entity BCtr_lib.BCtr_sbbd.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:20:26 01/11/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_sbbd IS
  GENERIC( 
    ADDR_WIDTH      : integer range 16 downto 8 := 8;
    BASE_ADDR       : unsigned(15 DOWNTO 0)     := to_unsigned(16,16);
    N_CHANNELS      : integer range 4 downto 1  := 1;
    CTR_WIDTH       : integer range 32 downto 1 := 16;
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : IN     std_logic;
    ExpReset : IN     std_logic;
    ExpWr    : IN     std_logic;
    PMTs     : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    Trigger  : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    clk      : IN     std_logic;
    ExpAck   : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0)
  );

-- Declarations

END ENTITY BCtr_sbbd ;

--
-- VHDL Architecture BCtr_lib.BCtr_sbbd.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 16:30:36 01/13/2017
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

ARCHITECTURE struct OF BCtr_sbbd IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL BdEn     : std_logic;
  SIGNAL BdWrEn   : std_logic;
  SIGNAL CData    : std_logic_vector(15 DOWNTO 0);
  SIGNAL C_Dbar   : std_logic;
  SIGNAL CfgAddr  : unsigned(3 DOWNTO 0);
  SIGNAL DData    : std_logic_vector(15 DOWNTO 0);
  SIGNAL DRdy     : std_logic;
  SIGNAL DataAddr : unsigned(1 DOWNTO 0);
  SIGNAL En       : std_logic;
  SIGNAL FData    : std_logic_vector(N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
  SIGNAL NA       : unsigned(15 DOWNTO 0);
  SIGNAL NArd     : std_logic;
  SIGNAL NBtot    : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NC       : unsigned(23 DOWNTO 0);
  SIGNAL NSkipped : unsigned(15 DOWNTO 0);
  SIGNAL RE       : std_logic;
  SIGNAL RdEn     : std_logic;
  SIGNAL Status   : std_logic_vector(2 DOWNTO 0);
  SIGNAL TrigArm  : std_logic;
  SIGNAL WrEn     : std_logic;
  SIGNAL rst      : std_logic;


  -- Component Declarations
  COMPONENT BCtr
  GENERIC (
    N_CHANNELS      : integer range 4 downto 1  := 1;
    CTR_WIDTH       : integer range 32 downto 1 := 16;
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT (
    En       : IN     std_logic ;
    NA       : IN     unsigned (15 DOWNTO 0);
    NB       : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NC       : IN     unsigned (23 DOWNTO 0);
    PMTs     : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    RE       : IN     std_logic ;
    Trigger  : IN     std_logic ;
    clk      : IN     std_logic ;
    rst      : IN     std_logic ;
    DRdy     : OUT    std_logic ;
    NArd     : OUT    std_logic ;
    NSkipped : OUT    unsigned (15 DOWNTO 0);
    RData    : OUT    std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
    TrigArm  : OUT    std_logic 
  );
  END COMPONENT BCtr;
  COMPONENT BCtr_Dmux
  PORT (
    CData  : IN     std_logic_vector (15 DOWNTO 0);
    C_Dbar : IN     std_logic ;
    DData  : IN     std_logic_vector (15 DOWNTO 0);
    RData  : OUT    std_logic_vector (15 DOWNTO 0)
  );
  END COMPONENT BCtr_Dmux;
  COMPONENT BCtr_addr
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := X"0010"
  );
  PORT (
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    BdEn     : OUT    std_logic ;
    C_Dbar   : OUT    std_logic ;
    CfgAddr  : OUT    unsigned (3 DOWNTO 0);
    DataAddr : OUT    unsigned (1 DOWNTO 0);
    BdWrEn   : OUT    std_logic 
  );
  END COMPONENT BCtr_addr;
  COMPONENT BCtr_cfg
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT (
    CfgAddr  : IN     unsigned (3 DOWNTO 0);
    ExpReset : IN     std_logic ;
    NArd     : IN     std_logic ;
    RdEn     : IN     std_logic ;
    TrigArm  : IN     std_logic ;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    WrEn     : IN     std_logic ;
    clk      : IN     std_logic ;
    CData    : OUT    std_logic_vector (15 DOWNTO 0);
    En       : OUT    std_logic ;
    NA       : OUT    unsigned (15 DOWNTO 0);
    NBtot    : OUT    unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NC       : OUT    unsigned (23 DOWNTO 0);
    rst      : OUT    std_logic ;
    Status   : OUT    std_logic_vector (2 DOWNTO 0)
  );
  END COMPONENT BCtr_cfg;
  COMPONENT BCtr_data
  GENERIC (
    N_CHANNELS      : integer range 4 downto 1   := 2;
    CTR_WIDTH       : integer range 32 downto 16 := 24;
    FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9
  );
  PORT (
    DRdy     : IN     std_logic ;
    DataAddr : IN     unsigned (1 DOWNTO 0);
    En       : IN     std_logic ;
    FData    : IN     std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
    NBtot    : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NSkipped : IN     unsigned (15 DOWNTO 0);
    RdEn     : IN     std_logic ;
    Status   : IN     std_logic_vector (2 DOWNTO 0);
    clk      : IN     std_logic ;
    rst      : IN     std_logic ;
    DData    : OUT    std_logic_vector (15 DOWNTO 0);
    RE       : OUT    std_logic 
  );
  END COMPONENT BCtr_data;
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
-- FOR ALL : BCtr USE ENTITY BCtr_lib.BCtr;
-- FOR ALL : BCtr_Dmux USE ENTITY BCtr_lib.BCtr_Dmux;
-- FOR ALL : BCtr_addr USE ENTITY BCtr_lib.BCtr_addr;
-- FOR ALL : BCtr_cfg USE ENTITY BCtr_lib.BCtr_cfg;
-- FOR ALL : BCtr_data USE ENTITY BCtr_lib.BCtr_data;
-- FOR ALL : subbus_io USE ENTITY BCtr_lib.subbus_io;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  ctr : BCtr
    GENERIC MAP (
      N_CHANNELS      => N_CHANNELS,
      CTR_WIDTH       => CTR_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      En       => En,
      NA       => NA,
      NB       => NBtot,
      NC       => NC,
      PMTs     => PMTs,
      RE       => RE,
      Trigger  => Trigger,
      clk      => clk,
      rst      => rst,
      DRdy     => DRdy,
      NArd     => NArd,
      NSkipped => NSkipped,
      RData    => FData,
      TrigArm  => TrigArm
    );
  dmux : BCtr_Dmux
    PORT MAP (
      CData  => CData,
      C_Dbar => C_Dbar,
      DData  => DData,
      RData  => RData
    );
  addr : BCtr_addr
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => BASE_ADDR
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      BdEn     => BdEn,
      C_Dbar   => C_Dbar,
      CfgAddr  => CfgAddr,
      DataAddr => DataAddr,
      BdWrEn   => BdWrEn
    );
  cfg : BCtr_cfg
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      CfgAddr  => CfgAddr,
      ExpReset => ExpReset,
      NArd     => NArd,
      RdEn     => RdEn,
      TrigArm  => TrigArm,
      WData    => WData,
      WrEn     => WrEn,
      clk      => clk,
      CData    => CData,
      En       => En,
      NA       => NA,
      NBtot    => NBtot,
      NC       => NC,
      rst      => rst,
      Status   => Status
    );
  data : BCtr_data
    GENERIC MAP (
      N_CHANNELS      => N_CHANNELS,
      CTR_WIDTH       => CTR_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      DRdy     => DRdy,
      DataAddr => DataAddr,
      En       => En,
      FData    => FData,
      NBtot    => NBtot,
      NSkipped => NSkipped,
      RdEn     => RdEn,
      Status   => Status,
      clk      => clk,
      rst      => rst,
      DData    => DData,
      RE       => RE
    );
  subbus : subbus_io
    GENERIC MAP (
      USE_BD_WR_EN => '0'
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