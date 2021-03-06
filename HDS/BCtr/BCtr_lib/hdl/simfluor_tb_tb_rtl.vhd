--
-- VHDL Test Bench BCtr_lib.simfluor_tb.simfluor_tester
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 21:42:20 01/ 8/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY simfluor_tb IS
   GENERIC (
      TRIGCNT_WIDTH  : integer range 15 downto 6       := 9;
      TRIG_PERIOD    : integer range 100000 downto 100 := 333;
      PULSECNT_WIDTH : integer range 16 downto 4       := 9
   );
END simfluor_tb;


LIBRARY BCtr_lib;
USE BCtr_lib.ALL;


ARCHITECTURE rtl OF simfluor_tb IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL Trigger : std_logic;
   SIGNAL PMT     : std_logic;
   SIGNAL clk     : std_logic;
   SIGNAL rst     : std_logic;


   -- Component declarations
   COMPONENT simfluor
      GENERIC (
         TRIGCNT_WIDTH  : integer range 15 downto 6       := 9;
         TRIG_PERIOD    : integer range 100000 downto 100 := 333;
         PULSECNT_WIDTH : integer range 16 downto 4       := 9
      );
      PORT (
         Trigger : OUT    std_logic;
         PMT     : OUT    std_logic;
         clk     : IN     std_logic;
         rst     : IN     std_logic
      );
   END COMPONENT;

   -- embedded configurations
   -- pragma synthesis_off
   FOR U_0 : simfluor USE ENTITY BCtr_lib.simfluor;
   -- pragma synthesis_on

  SIGNAL SimDone : std_logic;
  SIGNAL TrigCnt : unsigned(31 DOWNTO 0);
  SIGNAL PulseCnt : unsigned(31 DOWNTO 0);

BEGIN

         U_0 : simfluor
            GENERIC MAP (
               TRIGCNT_WIDTH  => TRIGCNT_WIDTH,
               TRIG_PERIOD    => TRIG_PERIOD,
               PULSECNT_WIDTH => PULSECNT_WIDTH
            )
            PORT MAP (
               Trigger => Trigger,
               PMT     => PMT,
               clk     => clk,
               rst     => rst
            );

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
  
  counts : Process (clk) is
  Begin
    IF (clk'event AND clk = '1') THEN
      IF (rst = '1') THEN
        TrigCnt <= (others => '0');
        PulseCnt <= (others => '0');
      ELSE
        IF (Trigger = '1') THEN
          TrigCnt <= TrigCnt + 1;
        END IF;
        IF (PMT = '1') THEN
          PulseCnt <= PulseCnt + 1;
        END IF;
      END IF;
    END IF;
  End Process;
  
  test_proc: Process is
  Begin
    SimDone <= '0';
    rst <= '1';
    -- pragma synthesis_off
    wait until clk'Event and clk = '1';
    wait until clk'Event and clk = '1';
    rst <= '0';
    wait for 100 ms;
    SimDone <= '1';
    wait;
    -- pragma synthesis_on
  END PROCESS;

END rtl;