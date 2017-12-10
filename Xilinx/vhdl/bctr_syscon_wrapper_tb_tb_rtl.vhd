--
-- VHDL Test Bench BCtr_lib.BCtr_syscon_wrapper_tb.BCtr_syscon_wrapper_tester
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 12:41:33 01/19/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY BCtr_syscon_wrapper_tb IS
END ENTITY BCtr_syscon_wrapper_tb;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;


ARCHITECTURE rtl OF BCtr_syscon_wrapper_tb IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL Addr    : std_logic_vector(7 DOWNTO 0);
  SIGNAL Ctrl    : std_logic_vector(6 DOWNTO 0);
  SIGNAL Data_o  : std_logic_vector(15 DOWNTO 0);
  SIGNAL PMTs    : std_logic_vector(1 DOWNTO 0);
  SIGNAL Trigger : std_logic;
  SIGNAL clk     : std_logic;
  SIGNAL Data_i  : std_logic_vector(15 DOWNTO 0);
  SIGNAL Fail    : std_logic;
  SIGNAL SimPMT  : std_logic;
  SIGNAL SimTrig : std_logic;
  SIGNAL Status  : std_logic_vector(3 DOWNTO 0);
  SIGNAL temp_scl : std_logic;
  SIGNAL temp_sda : std_logic;
  SIGNAL aio_scl  : std_logic;
  SIGNAL aio_sda  : std_logic;
  SIGNAL RE        : std_logic;
  SIGNAL WE        : std_logic;
  SIGNAL start     : std_logic;
  SIGNAL wdata     : std_logic_vector(7 DOWNTO 0);
  SIGNAL rdata     : std_logic_vector(7 DOWNTO 0);
  SIGNAL en        : std_logic;
  SIGNAL stop      : std_logic;
  SIGNAL rdreq     : std_logic;
  SIGNAL htr1_cmd  : std_logic;
  SIGNAL htr2_cmd  : std_logic;
  SIGNAL dac_reset : std_logic;
  SIGNAL dac_ldac  : std_logic;

  -- Component declarations
  COMPONENT BCtr_syscon_wrapper
    PORT (
      Addr    : IN     std_logic_vector(7 DOWNTO 0);
      Ctrl    : IN     std_logic_vector(6 DOWNTO 0);
      Data_o  : IN     std_logic_vector(15 DOWNTO 0);
      PMTs    : IN     std_logic_vector(1 DOWNTO 0);
      Trigger : IN     std_logic;
      clk     : IN     std_logic;
      temp_scl : INOUT  std_logic;
      temp_sda : INOUT  std_logic;
      aio_scl  : INOUT  std_logic;
      aio_sda  : INOUT  std_logic;
      aio_scl_mon  : OUT std_logic;
      aio_sda_mon  : OUT std_logic;
      htr1_cmd : OUT std_logic;
      htr2_cmd : OUT std_logic;
      Data_i  : OUT    std_logic_vector(15 DOWNTO 0);
      Fail    : OUT    std_logic;
      SimPMT  : OUT    std_logic;
      SimTrig : OUT    std_logic;
      Status  : OUT    std_logic_vector(3 DOWNTO 0);
      dac_reset : OUT   std_logic;
      dac_ldac  : OUT    std_logic
    );
  END COMPONENT BCtr_syscon_wrapper;

  COMPONENT BCtr_syscon_wrapper_tester
    GENERIC( 
      N_CHANNELS : integer range 4 downto 1       := 2;
      CTR_WIDTH  : integer range 32 downto 1      := 16;
      BIN_OPT    : integer range 10 downto 0      := 0; -- 0 to disable, 1,2,3 currently supported
      CTR_OPT    : integer := 1; -- 0 to disable basic counter tests
      SIM_LOOPS  : integer range 50 downto 0      := 10;
      TEMP_OPT   : std_logic := '0'; -- Set true to run temp sensor tests
      AIO_OPT   : std_logic := '0'; -- Set true to run basic AIO tests
      DACSCAN_OPT : std_logic := '0'; -- Set true to run DACSCAN tests
      NC         : integer range 2**24-1 downto 0 := 30000
    );
    PORT (
      Addr    : OUT    std_logic_vector(7 DOWNTO 0);
      Ctrl    : OUT    std_logic_vector(6 DOWNTO 0);
      Data_o  : OUT    std_logic_vector(15 DOWNTO 0);
      clk     : OUT    std_logic;
      Data_i  : IN     std_logic_vector(15 DOWNTO 0);
      Status  : IN     std_logic_vector(3 DOWNTO 0);
      en      : OUT    std_logic;
      rdata   : OUT    std_logic_vector (7 DOWNTO 0);
      WE      : IN     std_logic;
      rdreq   : IN     std_logic;
      start   : IN     std_logic;
      stop    : IN     std_logic;
      wdata   : IN     std_logic_vector (7 DOWNTO 0);
      RE      : INOUT  std_logic
    );
  END COMPONENT BCtr_syscon_wrapper_tester;

  COMPONENT i2c_slave
  GENERIC (
    I2C_ADDR : std_logic_vector(6 DOWNTO 0) := "1000000"
  );
  PORT (
    clk   : IN     std_logic;
    rst   : IN     std_logic;
    scl   : IN     std_logic;
    en    : IN     std_logic;
    rdata : IN     std_logic_vector (7 DOWNTO 0);
    WE    : OUT    std_logic;
    rdreq : OUT    std_logic;
    start : OUT    std_logic;
    stop  : OUT    std_logic;
    wdata : OUT    std_logic_vector (7 DOWNTO 0);
    RE    : INOUT  std_logic;
    sda   : INOUT  std_logic
  );
  END COMPONENT i2c_slave;

  COMPONENT ads1115
    PORT (
      clk : IN     std_logic;
      rst : IN     std_logic;
      sda : INOUT  std_logic;
      scl : IN     std_logic
    );
  END COMPONENT ads1115;

  COMPONENT ad5693
    GENERIC (
      I2C_ADDR : std_logic_vector(6 DOWNTO 0) := "1001100"
    );
    PORT (
      clk : IN     std_logic;
      rst : IN     std_logic;
      sda : INOUT  std_logic;
      scl : IN     std_logic
    );
  END COMPONENT ad5693;

  -- embedded configurations
  -- pragma synthesis_off
  FOR dut : BCtr_syscon_wrapper USE ENTITY BCtr_lib.BCtr_syscon_wrapper;
  FOR tester : BCtr_syscon_wrapper_tester USE ENTITY BCtr_lib.BCtr_syscon_wrapper_tester;
  FOR slave : i2c_slave USE ENTITY BCtr_lib.i2c_slave;
  FOR ALL : ads1115 USE ENTITY BCtr_lib.ads1115;
  FOR ALL : ad5693 USE ENTITY BCtr_lib.ad5693;
  -- pragma synthesis_on

BEGIN

    dut : BCtr_syscon_wrapper
      PORT MAP (
        Addr    => Addr,
        Ctrl    => Ctrl,
        Data_o  => Data_o,
        PMTs    => PMTs,
        Trigger => Trigger,
        clk     => clk,
        temp_scl => temp_scl,
        temp_sda => temp_sda,
        aio_scl => aio_scl,
        aio_sda => aio_sda,
        htr1_cmd => htr1_cmd,
        htr2_cmd => htr2_cmd,
        Data_i  => Data_i,
        Fail    => Fail,
        SimPMT  => SimPMT,
        SimTrig => SimTrig,
        Status  => Status,
        dac_reset => dac_reset,
        dac_ldac => dac_ldac
      );

    tester : BCtr_syscon_wrapper_tester
      GENERIC MAP (
        BIN_OPT => 3,
        CTR_OPT => 0,
        SIM_LOOPS => 2,
        DACSCAN_OPT => '1'
      )
      PORT MAP (
        Addr    => Addr,
        Ctrl    => Ctrl,
        Data_o  => Data_o,
        clk     => clk,
        Data_i  => Data_i,
        Status  => Status,
        en    => en,
        rdata => rdata,
        WE    => WE,
        start => start,
        stop  => stop,
        wdata => wdata,
        rdreq => rdreq,
        RE    => RE
      );

    slave : i2c_slave
      GENERIC MAP (
        I2C_ADDR => "0010100"
      )
      PORT MAP (
        clk   => clk,
        rdata => rdata,
        rst   => Ctrl(4),
        scl   => temp_scl,
        en    => en,
        WE    => WE,
        start => start,
        stop  => stop,
        wdata => wdata,
        rdreq => rdreq,
        RE    => RE,
        sda   => temp_sda
      );

  adc : ads1115
    PORT MAP (
      clk => clk,
      rst => Ctrl(4),
      sda => aio_sda,
      scl => aio_scl
    );

  dac1 : ad5693
    GENERIC MAP (
      I2C_ADDR => "1001100"
    )
    PORT MAP (
      clk => clk,
      rst => Ctrl(4),
      sda => aio_sda,
      scl => aio_scl
    );

  dac2 : ad5693
    GENERIC MAP (
      I2C_ADDR => "1001110"
    )
    PORT MAP (
      clk => clk,
      rst => Ctrl(4),
      sda => aio_sda,
      scl => aio_scl
    );

  Trigger <= SimTrig;
  PMTs(0) <= SimPMT;
  PMTS(1) <= '0';
  temp_scl <= 'H';
  temp_sda <= 'H';
  aio_scl <= 'H';
  aio_sda <= 'H';
END ARCHITECTURE rtl;