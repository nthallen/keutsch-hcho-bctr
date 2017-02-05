--
-- VHDL Architecture Scratch_lib.temp_acquire_tester.sim
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:15:53 05/ 5/2015
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY temp_acquire_tester IS
  PORT( 
    WE        : IN     std_logic;
    brd_num   : IN     std_logic_vector (2 DOWNTO 0);
    rd_data_o : IN     std_logic_vector (31 DOWNTO 0);
    rdy       : IN     std_logic;
    start     : IN     std_ulogic;
    wdata     : IN     std_ulogic_vector (7 DOWNTO 0);
    RE        : OUT    std_logic;
    ack       : OUT    std_logic;
    clk       : OUT    std_logic;
    en        : OUT    std_logic;
    rdata     : OUT    std_logic_vector (7 DOWNTO 0);
    rst       : OUT    std_logic;
    scl       : INOUT  std_logic;
    sda       : INOUT  std_logic
  );

-- Declarations

END ENTITY temp_acquire_tester ;

--
ARCHITECTURE sim OF temp_acquire_tester IS
  SIGNAL SimDone : std_logic;
  SIGNAL clk_100M : std_logic;
BEGIN

  f100m_clk : Process
  Begin
    clk_100M <= '0';
    wait for 20 ns;
    while SimDone = '0' loop
      clk_100M <= '1';
      wait for 5 ns;
      clk_100M <= '0';
      wait for 5 ns;
    end loop;
    wait;
  End Process;
  
  test_proc : Process
  Begin
    SimDone <= '0';
    scl <= 'H';
    sda <= 'H';
    rst <= '1';
    ack <= '0';
    en <= '1';
    RE <= '0';
    rdata <= (others => '0');
    wait until clk_100M'event AND clk_100M = '1';
    wait until clk_100M'event AND clk_100M = '1';
    rst <= '0';
    wait until rdy'event AND rdy = '1';
    wait until clk_100M'event AND clk_100M = '1';
    ack <= '1';
    wait until clk_100M'event AND clk_100M = '1' AND rdy = '0';
    ack <= '0';
    wait until clk_100M'event AND clk_100M = '1' AND rdy = '1';
    ack <= '1';
    wait until clk_100M'event AND clk_100M = '1' AND rdy = '0';
    ack <= '0';
    wait until clk_100M'event AND clk_100M = '1' AND rdy = '1';
    ack <= '1';
    wait until clk_100M'event AND clk_100M = '1' AND rdy = '0';
    ack <= '0';
    SimDone <= '1';
    wait;
  End Process;
  
  clk <= clk_100M;
  
END ARCHITECTURE sim;

