--
-- VHDL Test Bench BCtr_lib.BCtr_tb.BCtr_tester
--
-- Created:
--          by - . (NORT-XPS14)
--          at - 19:00:00 12/31/69
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;


ENTITY BCtr_tb IS
   GENERIC (
      FIFO_WIDTH      : integer range 32 downto 1 := 16;
      FIFO_ADDR_WIDTH : integer range 10 downto 4 := 8
   );
END BCtr_tb;


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;


ARCHITECTURE rtl OF BCtr_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL clk     : std_logic;
   SIGNAL rst     : std_logic;
   SIGNAL DRdy    : std_logic;
   SIGNAL En      : std_logic;
   SIGNAL NA      : std_logic_vector(15 DOWNTO 0);
   SIGNAL NB      : std_logic_vector(FIFO_ADDR_WIDTH-1 DOWNTO 0);
   SIGNAL NC      : std_logic_vector(15 DOWNTO 0);
   SIGNAL PMT     : std_logic;
   SIGNAL RData   : std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
   SIGNAL RE      : std_logic;
   SIGNAL Trigger : std_logic;
   SIGNAL NSkipped : std_logic_vector (15 DOWNTO 0);
   SIGNAL SimDone : std_logic;


   -- Component declarations
   COMPONENT BCtr
      GENERIC (
         FIFO_WIDTH      : integer range 32 downto 1 := 16;
         FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
      );
      PORT (
         clk      : IN     std_logic;
         rst      : IN     std_logic;
         DRdy     : OUT    std_logic;
         En       : IN     std_logic;
         NA       : IN     std_logic_vector(15 DOWNTO 0);
         NC       : IN     std_logic_vector(15 DOWNTO 0);
         NB       : IN     std_logic_vector(FIFO_ADDR_WIDTH-1 DOWNTO 0);
         PMT      : IN     std_logic;
         RData    : OUT    std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
         RE       : IN     std_logic;
         NSkipped : OUT    std_logic_vector (15 DOWNTO 0);
         Trigger  : IN     std_logic
      );
   END COMPONENT;

   -- embedded configurations
   -- pragma synthesis_off
   FOR U_0 : BCtr USE ENTITY BCtr_lib.BCtr;
   -- pragma synthesis_on

BEGIN

         U_0 : BCtr
            GENERIC MAP (
               FIFO_WIDTH      => FIFO_WIDTH,
               FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
            )
            PORT MAP (
               clk     => clk,
               rst     => rst,
               DRdy    => DRdy,
               En      => En,
               NA      => NA,
               NB      => NB,
               NC      => NC,
               PMT     => PMT,
               RData   => RData,
               RE      => RE,
               Trigger => Trigger,
               NSkipped => NSkipped
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
      for i in 1 to (conv_integer(NA)+1)*(conv_integer(NB)+1)+3 loop
        wait until clk'Event AND clk = '1';
      end loop;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process trig_proc;

  test_proc: Process is
    procedure wait_for_triggers(N : integer) is
      variable delay : integer := (conv_integer(NA)+1)*(conv_integer(NB)+1)+7;
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
       B : std_logic_vector(FIFO_ADDR_WIDTH-1 downto 0);
       C : std_logic_vector(15 downto 0)) is
    begin
      NA <= A;
      NB <= B;
      NC <= C;
      -- pragma synthesis_off
      wait until clk'Event and clk = '1';
      En <= '1';
      
      wait_for_triggers(conv_integer(NC)+2);
      assert DRdy = '1' report "Expected DRdy" severity error;
      wait_for_triggers(conv_integer(NC)+1);
      wait until clk'Event and clk = '1';
      wait until clk'Event and clk = '1';
      wait until clk'Event and clk = '1';
      RE <= '1';
      for i in 1 to conv_integer(NB)+1 loop
        assert conv_integer(RData) = (conv_integer(NA)+1)*(conv_integer(NC)+1)
        report "Invalid RData" severity error;
        wait until clk'Event and clk = '1';
      end loop;
      RE <= '0';
      wait until clk'Event and clk = '1';
      wait for 2 ns;
      assert DRdy = '0' report "Expected DRdy=0 after read" severity error;
      wait_for_triggers(conv_integer(NC)+2);
      En <= '0';
      wait for 200 ns;
      assert DRdy = '1' report "Expected DRdy" severity error;
      RE <= '1';
      for i in 1 to conv_integer(NB)+1 loop
        assert conv_integer(RData) = (conv_integer(NA)+1)*(conv_integer(NC)+1)
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
    NC <= X"0001";
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
  End Process;
End rtl;
