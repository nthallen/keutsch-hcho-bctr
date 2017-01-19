--
-- VHDL Architecture BCtr_lib.BCtr_syscon.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 11:22:15 01/13/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_syscon IS
    GENERIC (
      BUILD_NUMBER  : std_logic_vector(15 DOWNTO 0) := X"0001"; -- Relative to HCHO
      INSTRUMENT_ID : std_logic_vector(15 DOWNTO 0) := X"0008"; -- HCHO
      N_INTERRUPTS  : integer range 15 downto 0     := 1;
      N_BOARDS      : integer range 15 downto 0     := 2;
      ADDR_WIDTH    : integer range 16 downto 8     := 8;
      FAIL_WIDTH    : integer range 16 downto 1     := 1;
      SW_WIDTH      : integer range 16 DOWNTO 0     := 1;
      N_CTR_CHANNELS : integer range 4 DOWNTO 0     := 2
    );
    PORT (
      clk     : IN std_logic;
      PMTs    : IN std_logic_vector(N_CTR_CHANNELS-1 DOWNTO 0);
      Trigger : IN std_logic;
      Fail    : OUT std_logic;
      Ctrl    : IN std_logic_vector(6 DOWNTO 0);
      Addr    : IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      Data_i  : OUT std_logic_vector(15 DOWNTO 0);
      Data_o  : IN std_logic_vector(15 DOWNTO 0);
      Status  : OUT std_logic_vector(3 DOWNTO 0);
      SimTrig : OUT std_logic;
      SimPMT  : OUT std_logic
    );
END ENTITY BCtr_syscon;

ARCHITECTURE beh OF BCtr_syscon IS
  SIGNAL ExpAddr       : std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL ExpRd         : std_logic;
  SIGNAL ExpReset      : std_logic;
  SIGNAL ExpWr         : std_logic;
  SIGNAL WData         : std_logic_vector(15 DOWNTO 0);
  SIGNAL RData         : std_logic_vector(16*N_BOARDS-1 DOWNTO 0);
  SIGNAL ExpAck        : std_logic_vector(N_BOARDS-1 DOWNTO 0);
  SIGNAL BdIntr        : std_logic_vector(N_INTERRUPTS-1 downto 0);
  SIGNAL Collision     : std_logic;
  SIGNAL INTA          : std_logic;
  SIGNAL CmdEnbl       : std_logic;
  SIGNAL CmdStrb       : std_logic;
  SIGNAL Fail_Out      : std_logic_vector(FAIL_WIDTH-1 DOWNTO 0);
  SIGNAL Switches      : std_logic_vector(SW_WIDTH-1 DOWNTO 0);
  SIGNAL Flt_CPU_Reset : std_logic;

  COMPONENT syscon
    GENERIC (
      BUILD_NUMBER  : std_logic_vector(15 DOWNTO 0) := X"0007";
      INSTRUMENT_ID : std_logic_vector(15 DOWNTO 0) := X"0001";
      N_INTERRUPTS  : integer range 15 downto 0     := 1;
      N_BOARDS      : integer range 15 downto 0     := 1;
      ADDR_WIDTH    : integer range 16 downto 8     := 16;
      INTA_ADDR     : std_logic_vector(15 DOWNTO 0) := X"0001";
      BDID_ADDR     : std_logic_vector(15 DOWNTO 0) := X"0002";
      FAIL_ADDR     : std_logic_vector(15 DOWNTO 0) := X"0004";
      SW_ADDR       : std_logic_vector(15 DOWNTO 0) := X"0005";
      FAIL_WIDTH    : integer range 16 downto 1     := 1;
      SW_WIDTH      : integer range 16 DOWNTO 0     := 16;
      TO_ENABLED    : boolean := false
    );
    PORT (
      clk           : IN     std_logic;
      Ctrl          : IN     std_logic_vector(6 DOWNTO 0);
      Addr          : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      Data_i        : OUT    std_logic_vector(15 DOWNTO 0);
      Data_o        : IN     std_logic_vector(15 DOWNTO 0);
      Status        : OUT    std_logic_vector(3 DOWNTO 0);
      ExpRd         : OUT    std_logic;
      ExpWr         : OUT    std_logic;
      WData         : OUT    std_logic_vector(15 DOWNTO 0);
      RData         : IN     std_logic_vector(16*N_BOARDS-1 DOWNTO 0);
      ExpAddr       : OUT    std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpAck        : IN     std_logic_vector(N_BOARDS-1 DOWNTO 0);
      BdIntr        : IN     std_logic_vector(N_INTERRUPTS-1 downto 0);
      Collision     : OUT    std_logic;
      INTA          : OUT    std_logic;
      CmdEnbl       : OUT    std_logic;
      CmdStrb       : OUT    std_logic;
      ExpReset      : OUT    std_logic;
      Fail_Out      : OUT    std_logic_vector(FAIL_WIDTH-1 DOWNTO 0);
      Switches      : IN     std_logic_vector(SW_WIDTH-1 DOWNTO 0);
      Flt_CPU_Reset : OUT    std_logic
    );
  END COMPONENT syscon;
  
  COMPONENT BCtr_sbbd
    GENERIC (
      ADDR_WIDTH      : integer range 16 downto 8 := 8;
      BASE_ADDR       : unsigned(15 DOWNTO 0)     := to_unsigned(16,16);
      N_CHANNELS      : integer range 4 downto 1  := 1;
      CTR_WIDTH       : integer range 32 downto 1 := 16;
      FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
    );
    PORT (
      ExpAddr  : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd    : IN     std_logic;
      ExpReset : IN     std_logic;
      ExpWr    : IN     std_logic;
      PMTs     : IN     std_logic_vector(N_CHANNELS-1 DOWNTO 0);
      Trigger  : IN     std_logic;
      WData    : IN     std_logic_vector(15 DOWNTO 0);
      clk      : IN     std_logic;
      ExpAck   : OUT    std_logic;
      RData    : OUT    std_logic_vector(15 DOWNTO 0)
    );
  END COMPONENT BCtr_sbbd;

  COMPONENT simfluor IS
    GENERIC (
      TRIGCNT_WIDTH : integer range 15 downto 6 := 9;
      TRIG_PERIOD : integer range 100000 downto 100 := 333;
      PULSECNT_WIDTH : integer range 16 downto 4 := 9
    );
    PORT (
      Trigger : OUT std_logic;
      PMT : OUT std_logic;
      clk : IN std_logic;
      rst : IN std_logic
    );
  END COMPONENT simfluor;
BEGIN
  sys : syscon
    GENERIC MAP (
      BUILD_NUMBER  => BUILD_NUMBER,
      INSTRUMENT_ID => INSTRUMENT_ID,
      N_INTERRUPTS  => N_INTERRUPTS,
      N_BOARDS      => N_BOARDS,
      ADDR_WIDTH    => ADDR_WIDTH,
      INTA_ADDR     => X"0001",
      BDID_ADDR     => X"0002",
      FAIL_ADDR     => X"0004",
      SW_ADDR       => X"0005",
      FAIL_WIDTH    => FAIL_WIDTH,
      SW_WIDTH      => SW_WIDTH,
      TO_ENABLED    => false
    )
    PORT MAP (
      clk           => clk,
      Ctrl          => Ctrl,
      Addr          => Addr,
      Data_i        => Data_i,
      Data_o        => Data_o,
      Status        => Status,
      ExpRd         => ExpRd,
      ExpWr         => ExpWr,
      WData         => WData,
      RData         => RData,
      ExpAddr       => ExpAddr,
      ExpAck        => ExpAck,
      BdIntr        => BdIntr,
      Collision     => Collision,
      INTA          => INTA,
      CmdEnbl       => CmdEnbl,
      CmdStrb       => CmdStrb,
      ExpReset      => ExpReset,
      Fail_Out      => Fail_Out,
      Switches      => Switches,
      Flt_CPU_Reset => Flt_CPU_Reset
    );

  adjgatectr : BCtr_sbbd
    GENERIC MAP (
      ADDR_WIDTH      => ADDR_WIDTH,
      BASE_ADDR       => to_unsigned(16,16),
      N_CHANNELS      => N_CTR_CHANNELS,
      CTR_WIDTH       => 16,
      FIFO_ADDR_WIDTH => 4
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpRd    => ExpRd,
      ExpReset => ExpReset,
      ExpWr    => ExpWr,
      PMTs     => PMTs,
      Trigger  => Trigger,
      WData    => WData,
      clk      => clk,
      ExpAck   => ExpAck(0),
      RData    => RData(15 DOWNTO 0)
    );

  binctr : BCtr_sbbd
    GENERIC MAP (
      ADDR_WIDTH      => ADDR_WIDTH,
      BASE_ADDR       => to_unsigned(32,16),
      N_CHANNELS      => N_CTR_CHANNELS,
      CTR_WIDTH       => 16,
      FIFO_ADDR_WIDTH => 9
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpRd    => ExpRd,
      ExpReset => ExpReset,
      ExpWr    => ExpWr,
      PMTs     => PMTs,
      Trigger  => Trigger,
      WData    => WData,
      clk      => clk,
      ExpAck   => ExpAck(1),
      RData    => RData(31 DOWNTO 16)
    );
    
  sim : simfluor
    GENERIC MAP (
      TRIGCNT_WIDTH => 9,
      TRIG_PERIOD => 333,
      PULSECNT_WIDTH => 9
    )
    PORT MAP (
      Trigger => SimTrig,
      PMT => SimPMT,
      clk => clk,
      rst => ExpReset
    );
    
  BdIntr <= (others => '0');
  Switches <= (others => '0');
  Fail <= Fail_Out(0);
END ARCHITECTURE beh;

