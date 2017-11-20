--
-- VHDL Test Bench BCtr_lib.BCtr2_tb.BCtr2_tester
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 21:24:21 11/19/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY BCtr2_tb IS
END ENTITY BCtr2_tb;


LIBRARY BCtr_lib;
USE BCtr_lib.lfsr_pkg.all;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;


ARCHITECTURE rtl OF BCtr2_tb IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL clk        : std_logic;
  SIGNAL DRdy       : std_logic;
  SIGNAL En         : std_logic;
  SIGNAL Expired    : std_logic;
  SIGNAL IPnum      : std_logic_vector(5 DOWNTO 0);
  SIGNAL IPnumu     : unsigned(5 DOWNTO 0);
  SIGNAL IPnumOut   : std_logic_vector(5 DOWNTO 0);
  SIGNAL IPS        : std_logic;
  SIGNAL LaserV     : std_logic_vector(15 DOWNTO 0);
  SIGNAL LaserVOut  : std_logic_vector(15 DOWNTO 0);
  SIGNAL NA         : unsigned(15 DOWNTO 0);
  SIGNAL NArd       : std_logic;
  SIGNAL NBtot      : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NTriggered : std_logic_vector(31 DOWNTO 0);
  SIGNAL PMTs       : std_logic_vector(N_CHANNELS-1 DOWNTO 0);
  SIGNAL RptData    : std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
  SIGNAL RptRE      : std_logic;
  SIGNAL rst        : std_logic;
  SIGNAL TrigArm    : std_logic;
  SIGNAL Trigger    : std_logic;
  SIGNAL txing      : std_logic;


  -- Component declarations
  COMPONENT BCtr2
    PORT (
      clk        : IN     std_logic;
      DRdy       : OUT    std_logic;
      En         : IN     std_logic;
      Expired    : OUT    std_logic;
      IPnum      : IN     std_logic_vector(5 DOWNTO 0);
      IPnumOut   : OUT    std_logic_vector(5 DOWNTO 0);
      IPS        : IN     std_logic;
      LaserV     : IN     std_logic_vector(15 DOWNTO 0);
      LaserVOut  : OUT    std_logic_vector(15 DOWNTO 0);
      NA         : IN     unsigned(15 DOWNTO 0);
      NArd       : OUT    std_logic;
      NBtot      : IN     unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
      NTriggered : OUT    std_logic_vector(31 DOWNTO 0);
      PMTs       : IN     std_logic_vector(N_CHANNELS-1 DOWNTO 0);
      RptData    : OUT    std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
      RptRE      : IN     std_logic;
      rst        : IN     std_logic;
      TrigArm    : OUT    std_logic;
      Trigger    : IN     std_logic;
      txing      : IN     std_logic
    );
  END COMPONENT BCtr2;

  -- embedded configurations
  -- pragma synthesis_off
  FOR U_0 : BCtr2 USE ENTITY BCtr_lib.BCtr2;
  -- pragma synthesis_on

BEGIN

    U_0 : BCtr2
      PORT MAP (
        clk        => clk,
        DRdy       => DRdy,
        En         => En,
        Expired    => Expired,
        IPnum      => IPnum,
        IPnumOut   => IPnumOut,
        IPS        => IPS,
        LaserV     => LaserV,
        LaserVOut  => LaserVOut,
        NA         => NA,
        NArd       => NArd,
        NBtot      => NBtot,
        NTriggered => NTriggered,
        PMTs       => PMTs,
        RptData    => RptData,
        RptRE      => RptRE,
        rst        => rst,
        TrigArm    => TrigArm,
        Trigger    => Trigger,
        txing      => txing
      );

  f100m_clk : Process is
  Begin
    clk <= '0';
    PMT <= '1';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk <= '1';
      PMT <= '0';
      wait for 5 ns;
      clk <= '0';
      PMT <= '1';
      wait for 5 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process;
  
  trig_proc: Process is
  Begin
    Trigger <= '0';
    -- pragma synthesis_off
    wait for 200 ns;
    while SimDone = '0' loop
      wait until clk'Event AND clk = '1';
      wait for 3 ns;
      Trigger <= '1';
      wait for 5 ns;
      Trigger <= '0';
      for i in 1 to (to_integer(NA)+1)*(to_integer(NB)+1)+3 loop
        wait until clk'Event AND clk = '1';
      end loop;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process trig_proc;
  
  IPSproc : Process is
  Begin
    IPS <= '0';
    IPnumu <= (others => '0');
    -- pragma synthesis_off
    wait for 500 ns;
    while SimDone = '0' loop
      wait until clk'Event AND clk = '1';
      IPS <= '1';
      wait until clk'Event AND clk = '1';
      IPS <= '0';
      IPnumu <= IPnumu + 1;
      wait for 9975 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process IPSproc;

  test_proc: Process is
    procedure wait_for_triggers(N : integer) is
      variable delay : integer := (to_integer(NA)+1)*(to_integer(NB)+1)+7;
    begin
      for i in 1 to N loop
        -- pragma synthesis_off
        wait until Trigger = '1' for delay*10 ns;
        assert Trigger = '1' report "Expected Trigger" severity error;
        wait until Trigger = '0' for delay*10 ns;
        -- pragma synthesis_on
        assert Trigger = '0' report "Expected Trigger to clear" severity error;
      end loop;
      return;
    end procedure wait_for_triggers;
    
    procedure test1(
       A : std_logic_vector(15 downto 0);
       B : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0)
       ) is
    begin
      NA <= unsigned(A);
      NBtot <= unsigned(B);
      -- pragma synthesis_off
      wait until clk'Event and clk = '1';
      En <= '1';
      
      wait until IPS = '1';
      wait until IPS = '0';
      wait until IPS = '1';
      assert DRdy = '1' report "Expected DRdy" severity error;
      wait_for_triggers(to_integer(NC)+1);
      wait until clk'Event and clk = '1';
      wait until clk'Event and clk = '1';
      wait until clk'Event and clk = '1';
      RE <= '1';
      for i in 1 to to_integer(NB)+1 loop
        assert to_integer(unsigned(RData)) = (to_integer(NA)+1)*(to_integer(NC)+1)
        report "Invalid RData" severity error;
        wait until clk'Event and clk = '1';
      end loop;
      RE <= '0';
      wait until clk'Event and clk = '1';
      wait for 2 ns;
      assert DRdy = '0' report "Expected DRdy=0 after read" severity error;
      wait_for_triggers(to_integer(NC)+2);
      En <= '0';
      wait for 200 ns;
      assert DRdy = '1' report "Expected DRdy" severity error;
      RE <= '1';
      for i in 1 to to_integer(NB)+1 loop
        assert to_integer(unsigned(RData)) = (to_integer(NA)+1)*(to_integer(NC)+1)
        report "Invalid RData" severity error;
        wait until clk'Event and clk = '1';
      end loop;
      RE <= '0';
      wait until clk'Event and clk = '1';
      wait for 2 ns;
      -- pragma synthesis_on
      assert DRdy = '0' report "Expected DRdy=0 after read" severity error;
      return;
    end procedure test1;
  Begin
    SimDone <= '0';
    NA <= X"0004";
    NB <= X"02";
    NC <= X"000001";
    En <= '0';
    RE <= '0';
    
    rst <= '1';
    -- pragma synthesis_off
    wait until clk'Event and clk = '1';
    rst <= '0';
    wait until clk'Event and clk = '1';
    
    Test1(X"0004", X"02", X"0001");
    Test1(X"0000", X"07", X"0005");
    Test1(X"0004", X"02", X"0000");

    SimDone <= '1';
    wait;
    -- pragma synthesis_on
  End Process test_proc;

  PMTs(0) <= PMT;
  IPnum <= std_logic_vector(IPnumu);

END ARCHITECTURE rtl;