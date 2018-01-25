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
      BUILD_NUMBER  : std_logic_vector(15 DOWNTO 0) := X"0008"; -- Relative to HCHO
      INSTRUMENT_ID : std_logic_vector(15 DOWNTO 0) := X"0008"; -- HCHO BCtr
      N_INTERRUPTS  : integer range 15 downto 0     := 1;
      N_BOARDS      : integer range 15 downto 0     := 7;
      ADDR_WIDTH    : integer range 16 downto 8     := 8;
      FAIL_WIDTH    : integer range 16 downto 1     := 1;
      SW_WIDTH      : integer range 16 DOWNTO 0     := 1;
      N_CTR_CHANNELS : integer range 4 DOWNTO 0     := 2;
      Nbps_default  : integer range 63 downto 1     := 10
    );
    PORT (
      clk       : IN std_logic;
      PMTs      : IN std_logic_vector(N_CTR_CHANNELS-1 DOWNTO 0);
      Trigger   : IN std_logic;
      Fail      : OUT std_logic;
      Ctrl      : IN std_logic_vector(6 DOWNTO 0);
      Addr      : IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      Data_i    : OUT std_logic_vector(15 DOWNTO 0);
      Data_o    : IN std_logic_vector(15 DOWNTO 0);
      Status    : OUT std_logic_vector(3 DOWNTO 0);
      temp_scl_o  : OUT std_logic;
      temp_scl_i  : IN  std_logic;
      temp_sda_o  : OUT std_logic;
      temp_sda_i  : IN  std_logic;
      aio_scl_o : OUT   std_logic;
      aio_scl_i : IN    std_logic;
      aio_sda_o : OUT   std_logic;
      aio_sda_i : IN    std_logic;
      htr1_cmd  : OUT std_logic;
      htr2_cmd  : OUT std_logic;
      SimTrig   : OUT std_logic;
      SimPMT    : OUT std_logic;
      LDAC      : OUT std_logic
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
  SIGNAL PPS           : std_logic;
  SIGNAL IPS           : std_logic;
  SIGNAL IPnum         : std_logic_vector(5 DOWNTO 0);
  SIGNAL idxData       : std_logic_vector (15 DOWNTO 0);
  SIGNAL idxWr         : std_logic;
  SIGNAL idxAck        : std_logic;
  SIGNAL LaserV        : std_logic_vector(15 DOWNTO 0);
  SIGNAL ScanStat      : std_logic_vector (4 DOWNTO 0);
  SIGNAL tap_ack2      : std_logic;
  SIGNAL tap_ack2_ign  : std_logic;
  SIGNAL tap_rdy2      : std_logic;
  SIGNAL tap_data2     : std_logic_vector(31 DOWNTO 0);
  
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
  
--  COMPONENT BCtr_sbbd
--    GENERIC (
--      ADDR_WIDTH      : integer range 16 downto 8 := 8;
--      BASE_ADDR       : unsigned(15 DOWNTO 0)     := to_unsigned(16,16);
--      N_CHANNELS      : integer range 4 downto 1  := 1;
--      CTR_WIDTH       : integer range 32 downto 1 := 16;
--      FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
--    );
--    PORT (
--      ExpAddr  : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
--      ExpRd    : IN     std_logic;
--      ExpReset : IN     std_logic;
--      ExpWr    : IN     std_logic;
--      PMTs     : IN     std_logic_vector(N_CHANNELS-1 DOWNTO 0);
--      Trigger  : IN     std_logic;
--      WData    : IN     std_logic_vector(15 DOWNTO 0);
--      clk      : IN     std_logic;
--      ExpAck   : OUT    std_logic;
--      RData    : OUT    std_logic_vector(15 DOWNTO 0)
--    );
--  END COMPONENT BCtr_sbbd;
  
  COMPONENT BCtr2_sbbd IS
    GENERIC( 
      ADDR_WIDTH      : integer range 16 downto 8  := 8;
      BASE_ADDR       : unsigned(15 downto 0)      := X"0010";
      FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9;
      N_CHANNELS      : integer range 4 downto 1   := 1;
      CTR_WIDTH       : integer range 32 downto 1  := 16;
      FIFO_WIDTH      : integer range 128 downto 1 := 16
    );
    PORT( 
      ExpAddr   : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
      ExpRd     : IN     std_logic;
      ExpReset  : IN     std_logic;
      ExpWr     : IN     std_logic;
      PMTs      : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
      Trigger   : IN     std_logic;
      WData     : IN     std_logic_vector (15 DOWNTO 0);
      clk       : IN     std_logic;
      ExpAck    : OUT    std_logic;
      RData     : OUT    std_logic_vector (15 DOWNTO 0);
      IPS       : IN     std_logic;
      IPnum     : IN     std_logic_vector (5 DOWNTO 0);
      LasPwrIn  : IN     std_logic_vector (31 DOWNTO 0);
      LasPwrRdy : IN     std_logic;
      LasPwrAck : OUT    std_logic;
      LaserV    : IN     std_logic_vector (15 DOWNTO 0);
      ScanStat  : IN     std_logic_vector (4 DOWNTO 0)
    );
  END COMPONENT BCtr2_sbbd ;

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
  
  COMPONENT temp_top
    GENERIC (
      BASE_ADDR  : unsigned (15 DOWNTO 0)    := X"0000";
      ADDR_WIDTH : integer range 16 downto 8 := 8
    );
    PORT (
      Addr      : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd     : IN     std_logic;
      ExpWr     : IN     std_logic;
      clk       : IN     std_logic;
      rst       : IN     std_logic;
      tap_ack2  : IN     std_logic;
      ExpAck    : OUT    std_logic;
      RData     : OUT    std_logic_vector(15 DOWNTO 0);
      scl_o     : OUT    std_logic;
      scl_i     : IN     std_logic;
      sda_o     : OUT    std_logic;
      sda_i     : IN     std_logic;
      tap_data2 : OUT    std_logic_vector (31 DOWNTO 0);
      tap_rdy2  : OUT    std_logic
    );
  END COMPONENT temp_top;
  
  COMPONENT i2c_aio
    GENERIC (
      BASE_ADDR  : std_logic_vector(15 DOWNTO 0) := X"0050";
      ADDR_WIDTH : integer                       := 16
    );
    PORT (
      ExpAddr : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd   : IN     std_logic;
      ExpWr   : IN     std_logic;
      clk     : IN     std_logic;
      rst     : IN     std_logic;
      idxData : IN     std_logic_vector (15 DOWNTO 0);
      idxWr   : IN     std_logic;
      wData   : IN     std_logic_vector(15 DOWNTO 0);
      ExpAck  : OUT    std_logic;
      rData   : OUT    std_logic_vector(15 DOWNTO 0);
      scl_o   : OUT    std_logic;
      scl_i   : IN     std_logic;
      sda_o   : OUT    std_logic;
      sda_i   : IN     std_logic;
      idxAck  : OUT    std_logic;
      htr1_cmd : OUT std_logic;
      htr2_cmd : OUT std_logic
    );
  END COMPONENT i2c_aio;
  
  COMPONENT pps_sbbd
    GENERIC (
      ADDR_WIDTH : integer range 16 downto 8 := 8;
      BASE_ADDR  : unsigned(15 downto 0)     := x"0060";
      CLK_FREQ   : unsigned(31 downto 0)     := to_unsigned(100000000,32);
      MSW_SHIFT  : integer range 16 downto 0 := 11
    );
    PORT (
      ExpAddr  : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd    : IN     std_logic;
      ExpReset : IN     std_logic;
      ExpWr    : IN     std_logic;
      WData    : IN     std_logic_vector(15 DOWNTO 0);
      clk      : IN     std_logic;
      ExpAck   : OUT    std_logic;
      PPS      : OUT    std_logic;
      RData    : OUT    std_logic_vector(15 DOWNTO 0)
    );
  END COMPONENT pps_sbbd;

  COMPONENT ips_sbbd
    GENERIC (
      ADDR_WIDTH : integer range 16 downto 8 := 8;
      BASE_ADDR  : unsigned(15 downto 0)     := x"0070";
      Nbps_default : integer range 63 downto 1 := 10;
      NC0_default  : integer                   := 10**7
    );
    PORT (
      ExpAddr  : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd    : IN     std_logic;
      ExpReset : IN     std_logic;
      ExpWr    : IN     std_logic;
      PPS      : IN     std_logic;
      WData    : IN     std_logic_vector(15 DOWNTO 0);
      clk      : IN     std_logic;
      ExpAck   : OUT    std_logic;
      IPS      : OUT    std_logic;
      IPnum    : OUT    std_logic_vector(5 DOWNTO 0);
      RData    : OUT    std_logic_vector(15 DOWNTO 0)
    );
  END COMPONENT ips_sbbd;
  COMPONENT dacscan_sbbd
    GENERIC (
      ADDR_WIDTH : integer range 16 downto 8      := 8;
      BASE_ADDR  : unsigned (15 downto 0) := x"0080"
    );
    PORT (
      ExpAddr  : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      ExpRd    : IN     std_logic;
      ExpReset : IN     std_logic;
      ExpWr    : IN     std_logic;
      IPS      : IN     std_logic;
      WData    : IN     std_logic_vector(15 DOWNTO 0);
      clk      : IN     std_logic;
      idxAck   : IN     std_logic;
      ExpAck   : OUT    std_logic;
      LDAC     : OUT    std_logic;
      RData    : OUT    std_logic_vector(15 DOWNTO 0);
      idxData  : OUT    std_logic_vector(15 DOWNTO 0);
      ScanStat : OUT    std_logic_vector (4 DOWNTO 0);
      SetPoint : OUT    std_logic_vector(15 DOWNTO 0);
      idxWr    : OUT    std_logic
    );
  END COMPONENT dacscan_sbbd;
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

  adjgatectr : BCtr2_sbbd
    GENERIC MAP (
      ADDR_WIDTH      => ADDR_WIDTH,
      BASE_ADDR       => to_unsigned(16#10#,16),
      N_CHANNELS      => N_CTR_CHANNELS,
      CTR_WIDTH       => 16,
      FIFO_ADDR_WIDTH => 4,
      FIFO_WIDTH      => 16 * N_CTR_CHANNELS
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
      RData    => RData(15 DOWNTO 0),
      IPS      => IPS,
      IPnum    => IPnum,
      LaserV   => LaserV,
      ScanStat => ScanStat,
      LasPwrAck => tap_ack2_ign,
      LasPwrRdy => tap_rdy2,
      LasPwrIn  => tap_data2
    );

  binctr : BCtr2_sbbd
    GENERIC MAP (
      ADDR_WIDTH      => ADDR_WIDTH,
      BASE_ADDR       => to_unsigned(16#20#,16),
      N_CHANNELS      => N_CTR_CHANNELS,
      CTR_WIDTH       => 16,
      FIFO_ADDR_WIDTH => 9,
      FIFO_WIDTH      => 16 * N_CTR_CHANNELS
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
      RData    => RData(31 DOWNTO 16),
      IPS      => IPS,
      IPnum    => IPnum,
      LaserV   => LaserV,
      ScanStat => ScanStat,
      LasPwrAck => tap_ack2,
      LasPwrRdy => tap_rdy2,
      LasPwrIn  => tap_data2
    );

  temps : temp_top
    GENERIC MAP (
      BASE_ADDR  => to_unsigned(16#30#,16),
      ADDR_WIDTH => ADDR_WIDTH
    )
    PORT MAP (
      Addr      => Addr,
      ExpRd     => ExpRd,
      ExpWr     => ExpWr,
      clk       => clk,
      rst       => ExpReset,
      ExpAck    => ExpAck(2),
      RData     => RData(47 DOWNTO 32),
      scl_o     => temp_scl_o,
      scl_i     => temp_scl_i,
      sda_o     => temp_sda_o,
      sda_i     => temp_sda_i,
      tap_ack2  => tap_ack2,
      tap_rdy2   => tap_rdy2,
      tap_data2 => tap_data2
    );

  aio : i2c_aio
    GENERIC MAP (
      BASE_ADDR  => X"0050",
      ADDR_WIDTH => 8
    )
    PORT MAP (
      ExpAddr => ExpAddr,
      ExpRd   => ExpRd,
      ExpWr   => ExpWr,
      clk     => clk,
      rst     => ExpReset,
      idxData => idxData,
      idxWr   => idxWr,
      idxAck  => idxAck,
      wData   => WData,
      ExpAck  => ExpAck(3),
      rData   => RData(16*3+15 DOWNTO 16*3),
      scl_o   => aio_scl_o,
      scl_i   => aio_scl_i,
      sda_o   => aio_sda_o,
      sda_i   => aio_sda_i,
      htr1_cmd => htr1_cmd,
      htr2_cmd => htr2_cmd
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

  pps_gen : pps_sbbd
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => x"0060",
      CLK_FREQ   => to_unsigned(100000000,32),
      MSW_SHIFT  => 11
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpRd    => ExpRd,
      ExpReset => ExpReset,
      ExpWr    => ExpWr,
      WData    => WData,
      clk      => clk,
      ExpAck   => ExpAck(4),
      PPS      => PPS,
      RData    => RData(16*4+15 DOWNTO 16*4)
    );

  ips_gen : ips_sbbd
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => x"0070",
      Nbps_default => Nbps_default,
      NC0_default  => (10**8)/Nbps_default
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpRd    => ExpRd,
      ExpReset => ExpReset,
      ExpWr    => ExpWr,
      PPS      => PPS,
      WData    => WData,
      clk      => clk,
      ExpAck   => ExpAck(5),
      IPS      => IPS,
      IPnum    => IPnum,
      RData    => RData(16*5+15 DOWNTO 16*5)
    );

  dacscan : dacscan_sbbd
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      BASE_ADDR  => x"0080"
    )
    PORT MAP (
      ExpAddr  => ExpAddr,
      ExpRd    => ExpRd,
      ExpReset => ExpReset,
      ExpWr    => ExpWr,
      IPS      => IPS,
      WData    => WData,
      clk      => clk,
      idxAck   => idxAck,
      ExpAck   => ExpAck(6),
      LDAC     => LDAC,
      RData    => RData(16*6+15 DOWNTO 16*6),
      idxData  => idxData,
      idxWr    => idxWr,
      SetPoint => LaserV,
      ScanStat => ScanStat
    );
    
  BdIntr <= (others => '0');
  Switches <= (others => '0');
  Fail <= Fail_Out(0);
END ARCHITECTURE beh;

