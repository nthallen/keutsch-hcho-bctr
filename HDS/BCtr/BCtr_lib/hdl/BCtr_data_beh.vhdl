--
-- VHDL Architecture BCtr_lib.BCtr_data.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 15:25:43 01/10/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_data IS
   GENERIC( 
      N_CHANNELS      : integer range 4 downto 1   := 2;
      CTR_WIDTH       : integer range 32 downto 16 := 24;
      FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9
   );
   PORT( 
      DRdy     : IN     std_logic;
      DataAddr : IN     unsigned (1 DOWNTO 0);
      En       : IN     std_logic;
      FData    : IN     std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
      NBtot    : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
      NSkipped : IN     unsigned (15 DOWNTO 0);
      RdEn     : IN     std_logic;
      Status   : IN     std_logic_vector (2 DOWNTO 0);
      clk      : IN     std_logic;
      rst      : IN     std_logic;
      DData    : OUT    std_logic_vector (15 DOWNTO 0);
      RE       : OUT    std_logic
   );

-- Declarations

END BCtr_data ;

--
ARCHITECTURE beh OF BCtr_data IS
  TYPE State_t IS (
    S_INIT, S_RD
  );
  SIGNAL current_state : State_t;
  TYPE TX_t IS (
    TX_IDLE, TX_NSK, TX_DATA
  );
  SIGNAL current_tx : TX_t;
  SIGNAL tx_active : std_logic;
  SIGNAL NWremaining : unsigned(15 DOWNTO 0);
  SIGNAL IData : std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
  CONSTANT CTR_WORDS : integer := (CTR_WIDTH+15)/16;
  CONSTANT CTR_LAST_WIDTH : integer := CTR_WIDTH-((CTR_WORDS-1)*16);
  SIGNAL DRdy_int : std_logic;
  -- Are these still used?
  -- SIGNAL tx_ctr_bits : integer range CTR_WIDTH DOWNTO 0;
  -- SIGNAL tx_bits : integer range N_CHANNELS*CTR_WIDTH-CTR_LAST_WIDTH DOWNTO 0;
  SIGNAL word_cnt : integer range CTR_WORDS-1 DOWNTO 0;
  SIGNAL chan_cnt : integer range N_CHANNELS-1 DOWNTO 0;
  SIGNAL bin_cnt : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL tx_err_ovf : std_logic;
BEGIN
  PROCESS (clk) IS
    VARIABLE NW : unsigned(15 DOWNTO 0);
    -- VARIABLE tx_bits_nxt : integer range N_CHANNELS*CTR_WIDTH DOWNTO 0;
    -- VARIABLE tx_ctr_bits_nxt : integer range CTR_WIDTH DOWNTO 0;
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (rst = '1') THEN
        RE <= '0';
        tx_active <= '0';
        tx_err_ovf <= '0';
        DData <= (others => '0');
        current_state <= S_INIT;
        current_tx <= TX_IDLE;
        NWremaining <= to_unsigned(0,16);
      ELSE
        IF DRdy = '1' OR NWremaining > 0 THEN
          DRdy_int <= '1';
        ELSE
          DRdy_int <= '0';
        END IF;
        CASE current_state IS
        WHEN S_INIT =>
          IF (RdEn = '1') THEN
            IF (DataAddr = 0) THEN
              DData(6 DOWNTO 0) <= tx_err_ovf & Status & tx_active & DRdy_int & En;
              DData(14 DOWNTO 7) <= (others => '0');
            ELSIF (DataAddr = 1) THEN -- Reading NWremaining
              IF (current_tx = TX_IDLE) THEN
                IF (DRdy = '1') THEN
                  NW := resize(N_CHANNELS * CTR_WORDS * (NBtot+1) + 1,16);
                  NWremaining <= NW;
                  DData <= std_logic_vector(NW);
                  bin_cnt <= NBtot;
                  chan_cnt <= N_CHANNELS-1;
                  word_cnt <= CTR_WORDS-1;
                  IData <= FData;
                  RE <= '1';
                  -- tx_bits <= 0;
                  -- tx_bins <= to_unsigned(0,FIFO_ADDR_WIDTH);
                  current_tx <= TX_NSK;
                ELSE
                  NWremaining <= to_unsigned(0,16);
                  DData <= X"0000";
                END IF;
              ELSE
                DData <= std_logic_vector(NWremaining);
              END IF;
            ELSIF (DataAddr = 2) THEN
              CASE current_tx IS
              WHEN TX_IDLE =>
                IF (DRdy = '1') THEN
                  NW := resize(N_CHANNELS * CTR_WORDS * (NBtot+1)+1,16);
                  NWremaining <= NW;
                  DData <= std_logic_vector(NSkipped);
                  bin_cnt <= NBtot;
                  chan_cnt <= N_CHANNELS-1;
                  IData <= FData;
                  RE <= '1';
                  -- tx_bits <= 0;
                  -- tx_bins <= to_unsigned(0,FIFO_ADDR_WIDTH);
                  tx_active <= '1';
                  current_tx <= TX_DATA;
                ELSE
                  NWremaining <= to_unsigned(0,16);
                  DData <= X"0000";
                END IF;
              WHEN TX_NSK =>
                DData <= std_logic_vector(NSkipped);
                NWremaining <= NWremaining - 1;
                current_tx <= TX_DATA;
                tx_active <= '1';
              WHEN TX_DATA =>
                IF (word_cnt /= 0) THEN
                  DData <= IData(15 DOWNTO 0);
                  IData(N_CHANNELS*CTR_WIDTH-1-16 DOWNTO 0) <=
                    IData(N_CHANNELS*CTR_WIDTH-1 DOWNTO 16);
                  word_cnt <= word_cnt - 1;
                ELSE
                  DData(CTR_LAST_WIDTH-1 DOWNTO 0) <=
                    IData(CTR_LAST_WIDTH-1 DOWNTO 0);
                  DData(15 DOWNTO CTR_LAST_WIDTH) <= (others => '0');
                  IData(N_CHANNELS*CTR_WIDTH-1-CTR_LAST_WIDTH DOWNTO 0) <=
                    IData(N_CHANNELS*CTR_WIDTH-1 DOWNTO CTR_LAST_WIDTH);
                  word_cnt <= CTR_WORDS-1;
                  IF (chan_cnt = 0) THEN -- end of bin
                    IF (bin_cnt = 0) THEN -- last bin
                      -- pragma synthesis_off
                      assert NWremaining = 1 report "NWremaining /= 1 at bin_cnt=chan_cnt=0" severity error;
                      -- pragma synthesis_on
                      IF NWremaining /= 1 THEN
                        tx_err_ovf <= '1';
                      END IF;
                      tx_active <= '0';
                      current_tx <= TX_IDLE;
                    ELSE
                      bin_cnt <= bin_cnt-1;
                      chan_cnt <= N_CHANNELS-1;
                      IData <= FData;
                      RE <= '1';
                    END IF;
                  ELSE
                    chan_cnt <= chan_cnt - 1;
                  END IF;
                END IF;
                IF (NWremaining /= 0) THEN
                  NWremaining <= NWremaining - 1;
                END IF;
              WHEN OTHERS =>
                DData <= (others => '0');
                current_tx <= TX_IDLE;
              END CASE;
            ELSE -- Invalid address
              DData <= (others => '0');
            END IF;
            current_state <= S_RD;
          ELSE
            current_state <= S_INIT;
          END IF;
        WHEN S_RD =>
          RE <= '0';
          IF (RdEn = '0') THEN
            current_state <= S_INIT;
          ELSE
            current_state <= S_RD;
          END IF;
        WHEN OTHERS =>
          current_state <= S_INIT;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE beh;
