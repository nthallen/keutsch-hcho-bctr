--
-- VHDL Architecture BCtr_lib.temp_top_tester.rtl
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 16:57:04 10/28/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY std;
USE std.textio.ALL;

ENTITY temp_top_tester IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8    --
  );
  PORT( 
    ExpAck : IN     std_logic;
    RData  : IN     std_logic_vector (15 DOWNTO 0);
    Addr   : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd  : OUT    std_logic;
    ExpWr  : OUT    std_logic;
    clk    : OUT    std_logic;
    rst    : OUT    std_logic;
    scl    : INOUT  std_logic;
    sda    : INOUT  std_logic;
    tsen24 : OUT    std_logic;
    tsdata : OUT    std_logic_vector (31 DOWNTO 0);
    tsen14 : OUT    std_logic
  );

-- Declarations

END ENTITY temp_top_tester ;

--
ARCHITECTURE rtl OF temp_top_tester IS
  SIGNAL SimDone : std_logic;
  SIGNAL clk_100M : std_logic;
  SIGNAL ReadData : std_logic_vector(15 downto 0);
  SIGNAL result : std_logic_vector(31 downto 0);
  SIGNAL result_cnt : integer;
BEGIN

  f100m_clk : Process
  Begin
    clk_100M <= '0';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk_100M <= '1';
      wait for 5 ns;
      clk_100M <= '0';
      wait for 5 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process;
   
  test_proc : Process
    procedure sbrd(
        addr_in : IN std_logic_vector(15 DOWNTO 0) ) is
    begin
      Addr <= addr_in(ADDR_WIDTH-1 DOWNTO 0);
      -- pragma synthesis_off
      wait until clk_100M'EVENT AND clk_100M = '1';
      ExpRd <= '1';
      for i in 1 to 8 loop
        wait until clk_100M'EVENT AND clk_100M = '1';
      end loop;
      assert ExpAck = '1' report "Expected Ack on sbrd" severity error;
      ReadData <= rData;
      ExpRd <= '0';
      wait until clk_100M'EVENT AND clk_100M = '1';
      -- pragma synthesis_on
      return;
    end procedure sbrd;
    
    procedure chk_test_value(
        brd_no : IN integer;
        exp_cnt1 : IN integer;
        exp_val1 : std_logic_vector(31 downto 0);
        exp_cnt2 : IN integer;
        exp_val2 : std_logic_vector(31 downto 0)) is
      variable my_line : line;
    begin
      sbrd(std_logic_vector(to_unsigned(48+3*brd_no,16)));
      result_cnt <= to_integer(unsigned(ReadData));
      sbrd(std_logic_vector(to_unsigned(48+3*brd_no+1,16)));
      result(15 downto 0) <= ReadData;
      sbrd(std_logic_vector(to_unsigned(48+3*brd_no+2,16)));
      result(31 downto 16) <= ReadData;
      -- pragma synthesis_off
      wait until clk_100M'event and clk_100M = '1';
      if result_cnt /= exp_cnt1 or result /= exp_val1 then
        if result_cnt /= exp_cnt2 or result /= exp_val2 then
          write(my_line, now);
          write(my_line, string'(": Values for board "));
          write(my_line, brd_no);
          write(my_line, string'(" did not match either "));
          hwrite(my_line, exp_val1);
          write(my_line, string'(" or "));
          hwrite(my_line, exp_val2);
          writeline(output, my_line);
          report "Values did not match" severity error;
        end if;
      end if;
      -- pragma synthesis_on
    end procedure chk_test_value;
    
    procedure test_value(
        val : IN std_logic_vector(31 DOWNTO 0);
        exp_cnt1 : IN integer;
        exp_val1 : std_logic_vector(31 downto 0);
        exp_cnt2 : IN integer;
        exp_val2 : std_logic_vector(31 downto 0)) is
    begin
      tsdata <= val;
      -- pragma synthesis_off
      wait for 1000 ms;
      -- pragma synthesis_on
      chk_test_value(0, exp_cnt1, exp_val1, exp_cnt2, exp_val2);
      chk_test_value(1, 0, x"00000000", 0, x"00000000");
      chk_test_value(2, 0, x"00000000", 0, x"00000000");
      chk_test_value(3, exp_cnt1, exp_val1, exp_cnt2, exp_val2);
      chk_test_value(4, 0, x"00000000", 0, x"00000000");
      chk_test_value(5, 0, x"00000000", 0, x"00000000");
    end procedure test_value;
  Begin
    SimDone <= '0';
    ExpRd <= '0';
    ExpWr <= '0';
    ReadData <= (others => '0');
    scl <= 'H';
    sda <= 'H';
    rst <= '1';
    tsen14 <= '1';
    tsen24 <= '1';
    tsdata <= x"BFEECC88";
    -- pragma synthesis_off
    wait until clk_100M'event AND clk_100M = '1';
    wait until clk_100M'event AND clk_100M = '1';
    rst <= '0';
    -- Allow all boards to initialize, then disable slave14
    -- wait for 10 ms;
    -- tsen14 <= '0';
    -- wait for 200 ms;
    -- tsen14 <= '1';
    
    -- large positive value
    --   readback should be 7FDD9910/8 or 6FE1E5EE/7
    test_value(x"BFEECC88", 8, x"7FDD9910", 7, x"6FE1E5EE");
    -- small negative value
    --   readback should be FFDD9910/8 or FFE1E5EE/7
    test_value(x"7FEECC88", 8, x"FFDD9910", 7, x"FFE1E5EE");
    -- overflow positive value
    --   readback should be 0/0
    test_value(x"C1234567", 0, x"00000000", 0, x"00000000");
    -- overflow negative value
    --   readback should be 0/0
    test_value(x"3F000000", 0, x"00000000", 0, x"00000000");
    SimDone <= '1';
    wait;
    -- pragma synthesis_on
  End Process;
  
  clk <= clk_100M;
END ARCHITECTURE rtl;

