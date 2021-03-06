-- VHDL Entity BCtr_lib.BCtr.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 11:31:38 01/11/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr IS
  GENERIC( 
    N_CHANNELS      : integer range 4 downto 1  := 1;
    CTR_WIDTH       : integer range 32 downto 1 := 16;
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT( 
    En       : IN     std_logic;
    NA       : IN     unsigned (15 DOWNTO 0);
    NB       : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NC       : IN     unsigned (23 DOWNTO 0);
    PMTs     : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    RE       : IN     std_logic;
    Trigger  : IN     std_logic;
    clk      : IN     std_logic;
    rst      : IN     std_logic;
    DRdy     : OUT    std_logic;
    NArd     : OUT    std_logic;
    NSkipped : OUT    unsigned (15 DOWNTO 0);
    RData    : OUT    std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
    TrigArm  : OUT    std_logic
  );

-- Declarations

END ENTITY BCtr ;

--
-- VHDL Architecture BCtr_lib.BCtr.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 13:50:29 10/13/2017
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

ARCHITECTURE struct OF BCtr IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL CntEn     : std_logic;
  SIGNAL CtrData0  : std_logic_vector(N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
  SIGNAL CtrData1  : std_logic_vector(N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
  SIGNAL Empty1    : std_logic;
  SIGNAL Empty2    : std_logic;
  SIGNAL Full1     : std_logic;
  SIGNAL Full2     : std_logic;
  SIGNAL RE1       : std_logic;
  SIGNAL TrigClr   : std_logic;
  SIGNAL TrigOE    : std_logic;
  SIGNAL TrigSeen  : std_logic;
  SIGNAL WE1       : std_logic;
  SIGNAL WE2       : std_logic;
  SIGNAL first_col : std_logic;
  SIGNAL first_row : std_logic;

  -- Implicit buffer signal declarations
  SIGNAL TrigArm_internal : std_logic;


  -- Component Declarations
  COMPONENT BCtrCtrl
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
  );
  PORT (
    Empty1    : IN     std_logic;
    Empty2    : IN     std_logic;
    En        : IN     std_logic;
    Full1     : IN     std_logic;
    NA        : IN     unsigned (15 DOWNTO 0);
    NB        : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NC        : IN     unsigned (23 DOWNTO 0);
    TrigSeen  : IN     std_logic;
    clk       : IN     std_logic;
    rst       : IN     std_logic;
    CntEn     : OUT    std_logic;
    DRdy      : OUT    std_logic;
    NArd      : OUT    std_logic;
    NSkipped  : OUT    unsigned (15 DOWNTO 0);
    RE1       : OUT    std_logic;
    TrigArm   : OUT    std_logic;
    TrigClr   : OUT    std_logic;
    TrigOE    : OUT    std_logic;
    WE1       : OUT    std_logic;
    WE2       : OUT    std_logic;
    first_col : OUT    std_logic;
    first_row : OUT    std_logic
  );
  END COMPONENT BCtrCtrl;
  COMPONENT BCtrSums
  GENERIC (
    N_CHANNELS : integer range 4 DOWNTO 1  := 1;
    CTR_WIDTH  : integer range 32 DOWNTO 1 := 16
  );
  PORT (
    CntEn     : IN     std_logic;
    CtrData0  : IN     std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
    PMTs      : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
    clk       : IN     std_logic;
    first_col : IN     std_logic;
    first_row : IN     std_logic;
    rst       : IN     std_logic;
    CtrData1  : OUT    std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0)
  );
  END COMPONENT BCtrSums;
  COMPONENT BitClk
  GENERIC (
    TRIG_POS : boolean := true;
    TRIG_NEG : boolean := true
  );
  PORT (
    CLR    : IN     std_logic;
    OE     : IN     std_logic;
    PMT    : IN     std_logic;
    PMT_EN : IN     std_logic;
    Q      : OUT    std_logic
  );
  END COMPONENT BitClk;
  COMPONENT FIFO
  GENERIC (
    FIFO_WIDTH      : integer range 256 downto 1 := 1;
    FIFO_ADDR_WIDTH : integer range 10 downto 1  := 8
  );
  PORT (
    Clk   : IN     std_ulogic;
    RE    : IN     std_logic;
    Rst   : IN     std_logic;
    WData : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    WE    : IN     std_logic;
    Empty : OUT    std_logic;
    Full  : OUT    std_logic;
    RData : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0)
  );
  END COMPONENT FIFO;

  -- Optional embedded configurations
  -- pragma synthesis_off
  FOR ALL : BCtrCtrl USE ENTITY BCtr_lib.BCtrCtrl;
  FOR ALL : BCtrSums USE ENTITY BCtr_lib.BCtrSums;
  FOR ALL : BitClk USE ENTITY BCtr_lib.BitClk;
  FOR ALL : FIFO USE ENTITY BCtr_lib.FIFO;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  CtrCtrl : BCtrCtrl
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      Empty1    => Empty1,
      Empty2    => Empty2,
      En        => En,
      Full1     => Full1,
      NA        => NA,
      NC        => NC,
      NB        => NB,
      TrigSeen  => TrigSeen,
      clk       => clk,
      rst       => rst,
      CntEn     => CntEn,
      DRdy      => DRdy,
      RE1       => RE1,
      TrigArm   => TrigArm_internal,
      NArd      => NArd,
      TrigClr   => TrigClr,
      TrigOE    => TrigOE,
      WE1       => WE1,
      WE2       => WE2,
      first_col => first_col,
      first_row => first_row,
      NSkipped  => NSkipped
    );
  sums : BCtrSums
    GENERIC MAP (
      N_CHANNELS => N_CHANNELS,
      CTR_WIDTH  => CTR_WIDTH
    )
    PORT MAP (
      CntEn     => CntEn,
      CtrData0  => CtrData0,
      PMTs      => PMTs,
      clk       => clk,
      first_col => first_col,
      first_row => first_row,
      rst       => rst,
      CtrData1  => CtrData1
    );
  trig : BitClk
    GENERIC MAP (
      TRIG_POS => true,
      TRIG_NEG => false
    )
    PORT MAP (
      PMT    => Trigger,
      PMT_EN => TrigArm_internal,
      OE     => TrigOE,
      CLR    => TrigClr,
      Q      => TrigSeen
    );
  FIFO_A : FIFO
    GENERIC MAP (
      FIFO_WIDTH      => N_CHANNELS*CTR_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      WData => CtrData1,
      WE    => WE1,
      RE    => RE1,
      Clk   => clk,
      Rst   => rst,
      RData => CtrData0,
      Empty => Empty1,
      Full  => Full1
    );
  FIFO_B : FIFO
    GENERIC MAP (
      FIFO_WIDTH      => N_CHANNELS*CTR_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      WData => CtrData1,
      WE    => WE2,
      RE    => RE,
      Clk   => clk,
      Rst   => rst,
      RData => RData,
      Empty => Empty2,
      Full  => Full2
    );

  -- Implicit buffered output assignments
  TrigArm <= TrigArm_internal;

END ARCHITECTURE struct;
