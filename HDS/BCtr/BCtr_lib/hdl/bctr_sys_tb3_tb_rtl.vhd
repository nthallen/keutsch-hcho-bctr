--
-- VHDL Test Bench BCtr_lib.BCtr_sys_tb3.BCtr_sys_tester
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 18:41:33 01/20/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY BCtr_sys_tb3 IS
  GENERIC (
    ADDR_WIDTH      : integer range 16 downto 8 := 8;
    N_CHANNELS      : integer range 4 downto 1  := 1;
    CTR_WIDTH       : integer range 32 downto 1 := 16;
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9;
    N_BOARDS        : integer range 10 downto 1 := 1;
    FAIL_WIDTH      : integer range 16 downto 0 := 1;
    SW_WIDTH        : integer range 16 downto 0 := 1;
    N_INTERRUPTS    : integer range 16 downto 0 := 0
  );
END ENTITY BCtr_sys_tb3;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;


ARCHITECTURE rtl OF BCtr_sys_tb3 IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL Addr          : std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL clk           : std_logic;
  SIGNAL Ctrl          : std_logic_vector(6 DOWNTO 0);
  SIGNAL Data_i        : std_logic_vector(15 DOWNTO 0);
  SIGNAL Data_o        : std_logic_vector(15 DOWNTO 0);
  SIGNAL Fail_Out      : std_logic_vector(FAIL_WIDTH-1 DOWNTO 0);
  SIGNAL Flt_CPU_Reset : std_logic;
  SIGNAL PMTs          : std_logic_vector(N_CHANNELS-1 DOWNTO 0);
  SIGNAL Status        : std_logic_vector(3 DOWNTO 0);
  SIGNAL Switches      : std_logic_vector(SW_WIDTH-1 DOWNTO 0);
  CONSTANT NA1 : unsigned(15 DOWNTO 0) := to_unsigned(1,16);
  CONSTANT NB1 : unsigned(15 DOWNTO 0) := to_unsigned(3,16);
  CONSTANT NA2 : unsigned(15 DOWNTO 0) := to_unsigned(5,16);
  CONSTANT NB2 : unsigned(15 DOWNTO 0) := to_unsigned(5,16);
  CONSTANT NC  : unsigned(15 DOWNTO 0) := to_unsigned(3,16);
  SIGNAL Trigger       : std_logic;
  SIGNAL SimDone       : std_logic;
  alias RdEn is Ctrl(0);
  alias WrEn is Ctrl(1);
  alias CS is Ctrl(2);
  alias CE is Ctrl(3);
  alias rst is Ctrl(4);
  alias arm is Ctrl(6);
  alias TickTock is Ctrl(5);
  alias Done is Status(0);
  alias Ack is Status(1);
  alias ExpIntr is Status(2);
  alias TwoSecondTO is Status(3);
  SIGNAL ReadResult : std_logic_vector(15 DOWNTO 0);
  SIGNAL product : unsigned(15 DOWNTO 0);


  -- Component declarations
  COMPONENT BCtr_sys
    GENERIC (
      ADDR_WIDTH      : integer range 16 downto 8 := 8;
      N_CHANNELS      : integer range 4 downto 1  := 1;
      CTR_WIDTH       : integer range 32 downto 1 := 16;
      FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9;
      N_BOARDS        : integer range 10 downto 1 := 1;
      FAIL_WIDTH      : integer range 16 downto 0 := 2;
      SW_WIDTH        : integer range 16 downto 0 := 1;
      N_INTERRUPTS    : integer range 16 downto 0 := 1
    );
    PORT (
      Addr          : IN     std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
      clk           : IN     std_logic;
      Ctrl          : IN     std_logic_vector(6 DOWNTO 0);
      Data_i        : OUT    std_logic_vector(15 DOWNTO 0);
      Data_o        : IN     std_logic_vector(15 DOWNTO 0);
      Fail_Out      : OUT    std_logic_vector(FAIL_WIDTH-1 DOWNTO 0);
      Flt_CPU_Reset : OUT    std_logic;
      PMTs          : IN     std_logic_vector(N_CHANNELS-1 DOWNTO 0);
      Status        : OUT    std_logic_vector(3 DOWNTO 0);
      Switches      : IN     std_logic_vector(SW_WIDTH-1 DOWNTO 0);
      Trigger       : IN     std_logic
    );
  END COMPONENT BCtr_sys;

  -- embedded configurations
  -- pragma synthesis_off
  FOR U_0 : BCtr_sys USE ENTITY BCtr_lib.BCtr_sys;
  -- pragma synthesis_on

BEGIN

    U_0 : BCtr_sys
      GENERIC MAP (
        ADDR_WIDTH      => ADDR_WIDTH,
        N_CHANNELS      => N_CHANNELS,
        CTR_WIDTH       => CTR_WIDTH,
        FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
        N_BOARDS        => N_BOARDS,
        FAIL_WIDTH      => FAIL_WIDTH,
        SW_WIDTH        => SW_WIDTH,
        N_INTERRUPTS    => N_INTERRUPTS
      )
      PORT MAP (
        Addr          => Addr,
        clk           => clk,
        Ctrl          => Ctrl,
        Data_i        => Data_i,
        Data_o        => Data_o,
        Fail_Out      => Fail_Out,
        Flt_CPU_Reset => Flt_CPU_Reset,
        PMTs          => PMTs,
        Status        => Status,
        Switches      => Switches,
        Trigger       => Trigger
      );
      
  f100m_clk : Process is
  Begin
    clk <= '0';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk <= '1';
      PMTs(0) <= '0';
      wait for 5 ns;
      clk <= '0';
      PMTs(0) <= '1';
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
      for i in 1 to 42 loop
        wait until clk'Event AND clk = '1';
      end loop;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process trig_proc;

  test_proc: Process is
    procedure sbwr(
        addr_in : IN std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
        data : IN std_logic_vector(15 DOWNTO 0);
        AckExpected : std_logic ) is
    begin
      Addr <= addr_in(ADDR_WIDTH-1 DOWNTO 0);
      Data_o <= data;
      -- pragma synthesis_off
      wait until clk'EVENT AND clk = '1';
      WrEn <= '1';
      for i in 1 to 8 loop
        wait until clk'EVENT AND clk = '1';
      end loop;
      if AckExpected = '1' then
        assert Ack = '1' report "Expected Ack" severity error;
      else
        assert Ack = '0' report "Expected no Ack" severity error;
      end if;
      WrEn <= '0';
      wait until clk'EVENT AND clk = '1';
      -- pragma synthesis_on
      return;
    end procedure sbwr;

    procedure sbrd( addr_in : std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
                    AckExpected : std_logic ) is
    begin
      Addr <= addr_in;
      -- pragma synthesis_off
      wait until clk'Event AND clk = '1';
      wait for 1 ns;
      RdEn <= '1';
      for i in 1 to 8 loop
        wait until clk'Event AND clk = '1';
      end loop;
      if AckExpected = '1' then
        assert Ack = '1' report "Expected Ack on read" severity error;
      else
        assert Ack = '0' report "Expected no Ack on read" severity error;
      end if;
      ReadResult <= Data_i;
      RdEn <= '0';
      wait for 125 ns;
      -- pragma synthesis_on
      return;
    end procedure sbrd;
  Begin
    SimDone <= '0';
    Addr <= (others => '0');
    ReadResult <= (others => '0');
    Data_o <= (others => '0');
    Ctrl <= (others => '0');
    -- PMTs <= (others => '0');
    rst <= '1';
    -- pragma synthesis_off
    wait until clk'Event and clk = '1';
    wait until clk'Event and clk = '1';
    rst <= '0';
    wait until clk'Event and clk = '1';
    wait until clk'Event and clk = '1';

    -- Check NACK
    sbrd( std_logic_vector(to_unsigned(0,ADDR_WIDTH)), '0');
    -- Read baseline status:
    sbrd( X"10", '1');
    assert ReadResult = X"0000" report "Invalid startup status" severity error;
    -- Configure for NB1 bins of NA1
    sbwr( X"13", std_logic_vector(NA1), '1');
    sbwr( X"14", std_logic_vector(NB1), '1');
    -- Check the status again: should not be 'Ready' but not enabled
    sbrd( X"10", '1');
    assert ReadResult = X"0040" report "Unexpected status" severity error;
    -- Configure for NB2 bins of NA2
    sbwr( X"15", std_logic_vector(NA2), '1');
    sbwr( X"16", std_logic_vector(NB2), '1');
    -- Check the status again: should not be 'Ready'
    sbrd( X"10", '1');
    assert ReadResult = X"0080" report "Unexpected Ready status again" severity error;
    -- NC = 3
    sbwr(X"1B", std_logic_vector(NC), '1');
    sbrd( X"10", '1');
    assert ReadResult = X"00A0" report "Expected Ready status" severity error;
    -- Enable and check status
    sbwr( X"10", X"0001", '1');
    sbrd( X"10", '1');
    assert ReadResult = X"00A1" report "Expected Ready|En status" severity error;

    sbrd(X"10",'1');
    while ReadResult(1) = '0' loop
      sbrd(X"10",'1');
    end loop;
    
    sbrd(X"11",'1');
    assert ReadResult = std_logic_vector(NB1+NB2+1) report "Expected NB1+NB2+1" severity  error;
    
    sbrd(X"12",'1');
    assert ReadResult = X"0000" report "Expected NSk 0" severity error;
    
    product <= resize(NA1*NC,16);
    for i in 1 to to_integer(NB1) loop
      sbrd(X"12",'1');
      assert ReadResult = std_logic_vector(product) report "Expected NA1*NC in first NB1 bins" severity error;
    end loop;
    
    product <= resize(NA2*NC,16);
    for i in 1 to to_integer(NB2) loop
      sbrd(X"12",'1');
      assert ReadResult = std_logic_vector(product) report "Expected NA2*NC in bins NB1+1 to NB1+NB2"
         severity error;
    end loop;
  
    -- Now reset and check status
    sbwr( X"10", X"8000", '1');
    sbrd( X"10", '1');
    assert ReadResult = X"0000" report "Expected startup status after reset" severity error;
    
    SimDone <= '1';
    wait;
   -- pragma synthesis_on
  END PROCESS;


END ARCHITECTURE rtl;