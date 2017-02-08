--
-- VHDL Test Bench BCtr_lib.BCtr_syscon_wrapper_tester.BCtr_syscon_wrapper_tester
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
LIBRARY std;
USE std.textio.all;
USE ieee.std_logic_textio.all;


ENTITY BCtr_syscon_wrapper_tester IS
  GENERIC( 
    N_CHANNELS : integer range 4 downto 1       := 2;
    CTR_WIDTH  : integer range 32 downto 1      := 16;
    BIN_OPT    : integer range 10 downto 0      := 0; -- 0,1,2,3 currently supported
    SIM_LOOPS  : integer range 50 downto 0      := 10;
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
    start   : IN     std_ulogic;
    stop    : IN     std_ulogic;
    wdata   : IN     std_ulogic_vector (7 DOWNTO 0);
    RE      : INOUT  std_logic
  );
END ENTITY BCtr_syscon_wrapper_tester;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;

ARCHITECTURE rtl OF BCtr_syscon_wrapper_tester IS
  SIGNAL clk_int : std_logic;
  SIGNAL NWords : unsigned(15 DOWNTO 0);
  SIGNAL SimDone : std_logic;
  SIGNAL ReadResult : std_logic_vector(15 DOWNTO 0);
  SIGNAL ctr_base : unsigned(7 DOWNTO 0);
  CONSTANT temp_base : unsigned(7 DOWNTO 0) := to_unsigned(16#30#,8);
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


  f100m_clk_int : Process is
  Begin
    clk_int <= '0';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk_int <= '1';
      wait for 5 ns;
      clk_int <= '0';
      wait for 5 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process;
  
  clk <= clk_int;

  test_proc: Process is
    procedure sbwr(
        addr_in : IN unsigned(7 DOWNTO 0);
        data : IN std_logic_vector(15 DOWNTO 0);
        AckExpected : std_logic ) is
    begin
      Addr <= std_logic_vector(addr_in);
      Data_o <= data;
      -- pragma synthesis_off
      wait until clk_int'EVENT AND clk_int = '1';
      WrEn <= '1';
      for i in 1 to 8 loop
        wait until clk_int'EVENT AND clk_int = '1';
      end loop;
      if AckExpected = '1' then
        assert Ack = '1' report "Expected Ack" severity error;
      else
        assert Ack = '0' report "Expected no Ack" severity error;
      end if;
      WrEn <= '0';
      wait until clk_int'EVENT AND clk_int = '1';
      -- pragma synthesis_on
      return;
    end procedure sbwr;

    procedure sbrd( addr_in : unsigned (7 DOWNTO 0);
                    AckExpected : std_logic ) is
    begin
      Addr <= std_logic_vector(addr_in);
      -- pragma synthesis_off
      wait until clk_int'Event AND clk_int = '1';
      wait for 1 ns;
      RdEn <= '1';
      for i in 1 to 8 loop
        wait until clk_int'Event AND clk_int = '1';
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
    
    procedure check_read(addr_in : unsigned(7 DOWNTO 0);
                  expected : std_logic_vector(15 DOWNTO 0) ) is
      variable my_line : line;
    begin
      if ReadResult /= expected then
        write(my_line, now);
        write(my_line, string'(": sbrd("));
        hwrite(my_line, std_logic_vector(addr_in));
        write(my_line, string'(") Expected: "));
        hwrite(my_line, expected, RIGHT, 4);
        write(my_line, string'(" read: "));
        hwrite(my_line, std_logic_vector(ReadResult), RIGHT, 4);
        writeline(output, my_line);
      end if;
    end procedure check_read;
   
    variable my_line : line;
  Begin
    SimDone <= '0';
    Addr <= (others => '0');
    ReadResult <= (others => '0');
    Data_o <= (others => '0');
    Ctrl <= (others => '0');
    en <= '1';
    RE <= '0';
    rdata <= (others => '0');
    
    CASE BIN_OPT IS
    WHEN 1 =>
        ctr_base <= to_unsigned(16#10#,8);
    WHEN 2 =>
        ctr_base <= to_unsigned(16#20#,8);
    WHEN others =>
        ctr_base <= to_unsigned(16#20#,8);
    END CASE;
    
    -- PMTs <= (others => '0');
    rst <= '1';
    -- pragma synthesis_off
    wait until clk_int'Event and clk_int = '1';
    wait until clk_int'Event and clk_int = '1';
    rst <= '0';
    wait until clk_int'Event and clk_int = '1';
    wait until clk_int'Event and clk_int = '1';

    sbrd(ctr_base, '1');
    assert ReadResult = X"0000" report "Invalid startup status" severity error;

    IF BIN_OPT > 0 THEN
      CASE BIN_OPT IS
      WHEN 1 =>
        -- Configure for 1 bins of 10
        sbwr(ctr_base+3, std_logic_vector(to_unsigned(10,16)), '1');
        sbwr(ctr_base+4, std_logic_vector(to_unsigned(1,16)), '1');
        sbrd(ctr_base, '1');
        assert ReadResult = X"0040" report "Expected N_NAB=1 status" severity error;
        -- Now add a second bin of 350ns
        sbwr(ctr_base+5, std_logic_vector(to_unsigned(35,16)), '1');
        sbwr(ctr_base+6, std_logic_vector(to_unsigned(1,16)), '1');
        sbrd(ctr_base, '1');
        assert ReadResult = X"0080" report "Expected N_NAB=2 status" severity error;
        -- And a third bin of 2500ns
        sbwr(ctr_base+7, std_logic_vector(to_unsigned(250,16)), '1');
        sbwr(ctr_base+8, std_logic_vector(to_unsigned(1,16)), '1');
        sbrd(ctr_base, '1');
        assert ReadResult = X"00C0" report "Expecte N_NAB=3 status still" severity error;
      WHEN 2 => -- 75x4, needs to be the bin ctr
        sbwr(ctr_base+3, std_logic_vector(to_unsigned(4,16)), '1');
        sbwr(ctr_base+4, std_logic_vector(to_unsigned(75,16)), '1');
        -- Check the status again: should be 'Ready' but not enabled
        sbrd(ctr_base, '1');
        assert ReadResult = X"0040" report "Expected N_NAB=1 status" severity error;
      WHEN OTHERS =>
        -- Configure for 45 bins of 1
        sbwr(ctr_base+3, std_logic_vector(to_unsigned(1,16)), '1');
        sbwr(ctr_base+4, std_logic_vector(to_unsigned(45,16)), '1');
        -- Check the status again: should be 'Ready' but not enabled
        sbrd(ctr_base, '1');
        assert ReadResult = X"0040" report "Expected N_NAB=1 status" severity error;
        -- 40 bins of 5
        sbwr(ctr_base+5, std_logic_vector(to_unsigned(5,16)), '1');
        sbwr(ctr_base+6, std_logic_vector(to_unsigned(40,16)), '1');
        sbrd(ctr_base, '1');
        assert ReadResult = X"0080" report "Expected N_NAB=2 status" severity error;
      END CASE;
      sbwr(ctr_base+11, std_logic_vector(NCU(15 DOWNTO 0)),'1');
      sbwr(ctr_base+12, X"00" & std_logic_vector(NCU(23 DOWNTO 16)),'1');
      sbrd(ctr_base, '1');
      assert ReadResult(5 DOWNTO 0) = "100000" report "Expected Ready status" severity error;
  
      -- Enable and check status
      sbwr(ctr_base, X"0001", '1');
      sbrd(ctr_base, '1');
      assert ReadResult(5 DOWNTO 0) = "100001" report "Expected Ready|En status" severity error;
      
      for i in 1 to SIM_LOOPS loop
        sbrd(ctr_base,'1');
        while ReadResult(1) = '0' loop
          sbrd(ctr_base,'1');
        end loop;
        write(my_line, now);
        sbrd(ctr_base+1,'1'); -- NWords
        NWords <= unsigned(ReadResult);
        wait for 10 ns;
        write(my_line, string'(": "));
        write(my_line, to_integer(NWords));
        write(my_line, string'(":"));
        while NWords > 0 loop
          sbrd(ctr_base+2,'1');
          write(my_line, string'(" "));
          write(my_line, to_integer(unsigned(ReadResult)));
          NWords <= NWords - 1;
          wait for 10 ns;
        end loop;
        writeline(output, my_line);
      end loop;
      
      sbrd(ctr_base,'1');
      while ReadResult(1) = '0' loop
        sbrd(ctr_base,'1');
      end loop;
      sbrd(ctr_base+1,'1'); -- NWords
      NWords <= unsigned(ReadResult);
      wait for 10 ns;
      sbrd(ctr_base,'1'); -- Check status inbetween
      sbrd(ctr_base+2,'1'); -- Read NSkipped
      sbrd(ctr_base,'1'); -- Check status inbetween
  
      sbwr(ctr_base, X"0000", '1'); -- Try to disable the counter
      sbrd(ctr_base, '1');
      assert ReadResult(0) = '0' report "Counter not disabled after writing disable" severity error;
      
      sbwr(ctr_base, X"8000", '1'); -- Try reset
      sbrd(ctr_base, '1');
      assert ReadResult = X"0000" report "Counter not reset after reset" severity error;
    END IF;
    
    -- Temp sensor test
    for i in 1 to 2 loop
      if i > 1 then
        wait for 1000 ms;
      end if;
      for sensor in 0 to 5 loop
        sbrd(temp_base + sensor*3,'1');
        check_read(temp_base+sensor*3, X"0000");
        sbrd(temp_base + sensor*3+1,'1');
        check_read(temp_base+sensor*3, X"0000");
        sbrd(temp_base + sensor*3+2,'1');
        check_read(temp_base+sensor*3, X"0000");
      end loop;
    end loop;
    
    SimDone <= '1';
    wait;
   -- pragma synthesis_on
  END PROCESS;
END ARCHITECTURE rtl;
