--
-- VHDL Architecture BCtr_lib.BCtr_sys_tester.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 21:45:05 01/11/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.textio.all;
USE ieee.std_logic_textio.all;

ENTITY BCtr_sys_tester IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8      := 8;
    N_CHANNELS : integer range 4 downto 1       := 1;
    CTR_WIDTH  : integer range 32 downto 1      := 16;
    FAIL_WIDTH : integer range 16 downto 0      := 2;
    SW_WIDTH   : integer range 16 downto 0      := 1;
    BIN_OPT    : integer range 10 downto 1      := 1;
    SIM_LOOPS  : integer range 50 downto 0      := 20;
    NC         : integer range 2**24-1 downto 0 := 3000
  );
  PORT( 
    Data_i        : IN     std_logic_vector (15 DOWNTO 0);
    Fail_Out      : IN     std_logic_vector (FAIL_WIDTH-1 DOWNTO 0);
    Flt_CPU_Reset : IN     std_logic;
    Status        : IN     std_logic_vector (3 DOWNTO 0);
    Addr          : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    Ctrl          : OUT    std_logic_vector (6 DOWNTO 0);
    Data_o        : OUT    std_logic_vector (15 DOWNTO 0);
    PMTs          : OUT    std_logic_vector (N_CHANNELS-1 DOWNTO 1);
    Switches      : OUT    std_logic_vector (SW_WIDTH-1 DOWNTO 0);
    clk           : OUT    std_logic
  );

-- Declarations

END ENTITY BCtr_sys_tester ;

--
ARCHITECTURE beh OF BCtr_sys_tester IS
  SIGNAL NWords : unsigned(15 DOWNTO 0);
  SIGNAL SimDone : std_logic;
  SIGNAL ReadResult : std_logic_vector(15 DOWNTO 0);
  CONSTANT NCU : unsigned(23 DOWNTO 0) := to_unsigned(NC,24);
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
BEGIN
  PMTs <= (others => '0');

  f100m_clk : Process is
  Begin
    clk <= '0';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk <= '1';
      wait for 5 ns;
      clk <= '0';
      wait for 5 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process;

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
   
    variable my_line : line;
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

    sbrd( X"10", '1');
    assert ReadResult = X"0000" report "Invalid startup status" severity error;
    CASE BIN_OPT IS
    WHEN 1 =>
      -- Configure for 1 bins of 10
      sbwr(X"13", std_logic_vector(to_unsigned(10,16)), '1');
      sbwr(X"14", std_logic_vector(to_unsigned(1,16)), '1');
      -- Check the status again: should be 'Ready' but not enabled
      sbrd(X"10", '1');
      assert ReadResult = X"0020" report "Expected Ready status" severity error;
      -- Now add a second bin of 350ns
      sbwr(X"15", std_logic_vector(to_unsigned(35,16)), '1');
      sbwr(X"16", std_logic_vector(to_unsigned(1,16)), '1');
      sbrd(X"10", '1');
      assert ReadResult = X"0020" report "Expected Ready status again" severity error;
      -- And a third bin of 2500ns
      sbwr(X"17", std_logic_vector(to_unsigned(250,16)), '1');
      sbwr(X"18", std_logic_vector(to_unsigned(1,16)), '1');
      sbrd(X"10", '1');
      assert ReadResult = X"0020" report "Expected Ready status still" severity error;
    WHEN others =>
      sbwr(X"13", std_logic_vector(to_unsigned(4,16)), '1');
      sbwr(X"14", std_logic_vector(to_unsigned(75,16)), '1');
      -- Check the status again: should be 'Ready' but not enabled
      sbrd(X"10", '1');
      assert ReadResult = X"0020" report "Expected Ready status" severity error;
    END CASE;
    sbwr(X"1B", std_logic_vector(NCU(15 DOWNTO 0)),'1');
    sbwr(X"1C", X"00" & std_logic_vector(NCU(23 DOWNTO 16)),'1');

    -- Enable and check status
    sbwr( X"10", X"0001", '1');
    sbrd( X"10", '1');
    assert ReadResult = X"0021" report "Expected Ready|En status" severity error;
    
    for i in 1 to SIM_LOOPS loop
      sbrd(X"10",'1');
      while ReadResult(1) = '0' loop
        sbrd(X"10",'1');
      end loop;
      write(my_line, now);
      sbrd(X"11",'1'); -- NWords
      NWords <= unsigned(ReadResult);
      wait for 10 ns;
      write(my_line, string'(": "));
      write(my_line, to_integer(NWords));
      write(my_line, string'(":"));
      while NWords > 0 loop
        sbrd(X"12",'1');
        write(my_line, string'(" "));
        write(my_line, to_integer(unsigned(ReadResult)));
        NWords <= NWords - 1;
        wait for 10 ns;
      end loop;
      writeline(output, my_line);
    end loop;
    
    sbwr( X"10", X"0000", '1');
    sbrd( X"10", '1');
    assert ReadResult(0) = '0' report "Counter not disabled after writing disable" severity error;
    
    SimDone <= '1';
    wait;
   -- pragma synthesis_on
  END PROCESS;
END ARCHITECTURE beh;

