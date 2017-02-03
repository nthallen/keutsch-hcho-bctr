--
-- VHDL Architecture BCtr_lib.simfluor.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 21:01:54 01/ 8/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY simfluor IS
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
END ENTITY simfluor;

--
ARCHITECTURE beh OF simfluor IS
  SIGNAL RE    : std_logic;
  SIGNAL Nbins : unsigned(PULSECNT_WIDTH-1 DOWNTO 0);
  SIGNAL TrigCnt : unsigned(TRIGCNT_WIDTH-1 DOWNTO 0);
  SIGNAL TrigTO : std_logic;
  SIGNAL PulseCnt : unsigned(PULSECNT_WIDTH-1 DOWNTO 0);
  SIGNAL PulseTO : std_logic;
  TYPE State_t IS (S_INIT, S_TRIG, S_TRIG2, S_TRIG3, S_PULSE);
  SIGNAL cur_state : State_t;
  SIGNAL PMT_int : std_logic;

   COMPONENT prdelay
      GENERIC (
         LFSR_WIDTH   : integer range 64 downto 4 := 41;
         OUTPUT_WIDTH : integer range 16 downto 4 := 9
      );
      PORT (
         clk   : IN     std_logic;
         rst   : IN     std_logic;
         RE    : IN     std_logic;
         Nbins : OUT    unsigned(OUTPUT_WIDTH-1 DOWNTO 0)
      );
   END COMPONENT;
BEGIN
  PRNG : prdelay
    GENERIC MAP (
      LFSR_WIDTH   => 41,
      OUTPUT_WIDTH => PULSECNT_WIDTH
    )
    PORT MAP (
      clk   => clk,
      rst   => rst,
      RE    => RE,
      Nbins => Nbins
    );
    
  PROCESS (clk) IS
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (rst = '1') THEN
        cur_state <= S_INIT;
        Trigger <= '0';
        TrigTO <= '1';
        TrigCnt <= (others => '0');
        PMT_int <= '0';
        PulseCnt <= (others => '0');
        PulseTO <= '1';
        RE <= '0';
      ELSE
        IF (TrigCnt = to_unsigned(0,TRIGCNT_WIDTH)) THEN
          TrigTO <= '1';
        ELSE
          TrigCnt <= TrigCnt - 1;
        END IF;
        IF (PulseCnt = to_unsigned(0,PULSECNT_WIDTH)) THEN
          PulseTO <= '1';
        ELSE
          PulseCnt <= PulseCnt - 1;
        END IF;
        CASE cur_state IS
          WHEN S_INIT =>
            Trigger <= '0';
            PMT_int <= '0';
            cur_state <= S_TRIG;
          WHEN S_TRIG =>
            TrigCnt <= to_unsigned(TRIG_PERIOD,TRIGCNT_WIDTH);
            TrigTO <= '0';
            Trigger <= '1';
            -- PMT <= '0';
            PulseCnt <= Nbins;
            RE <= '1';
            IF (Nbins /= to_unsigned(0,PULSECNT_WIDTH)) THEN
              PulseTO <= '0';
              cur_state <= S_TRIG2;
            ELSE
              cur_state <= S_TRIG3;
            END IF;
          WHEN S_TRIG2 =>
            Trigger <= '0';
            -- PMT <= '0';
            RE <= '0';
            IF (PulseTO = '1') THEN
              cur_state <= S_PULSE;
            ELSIF (TrigTO = '1') THEN
              cur_state <= S_TRIG;
            ELSE
              cur_state <= S_TRIG2;
            END IF;
          WHEN S_TRIG3 =>
            Trigger <= '0';
            -- PMT <= '0';
            RE <= '0';
            IF (TrigTO = '1') THEN
              cur_state <= S_TRIG;
            ELSE
              cur_state <= S_TRIG3;
            END IF;
          WHEN S_PULSE =>
            IF PMT_int = '1' THEN
              PMT_int <= '0';
            ELSE
              PMT_int <= '1';
            END IF;
            IF (TrigTO = '1') THEN
              cur_state <= S_TRIG;
            ELSE
              cur_state <= S_TRIG3;
            END IF;
          WHEN others =>
            cur_state <= S_INIT;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
  
  PMT <= PMT_int;
END ARCHITECTURE beh;

