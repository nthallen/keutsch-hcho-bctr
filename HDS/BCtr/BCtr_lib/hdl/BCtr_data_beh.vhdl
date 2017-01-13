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
      N_CHANNELS      : integer range 4 downto 1   := 1;
      CTR_WIDTH       : integer range 32 downto 16 := 16;
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
    TX_IDLE, TX_NSK, TX_DATA, TX_ERR
  );
  SIGNAL current_tx : TX_t;
  SIGNAL tx_active : std_logic;
  SIGNAL NWremaining : unsigned(15 DOWNTO 0);
  CONSTANT CTR_WORDS : integer := (CTR_WIDTH+15)/16;
  SIGNAL tx_ctr_bits : integer range CTR_WIDTH DOWNTO 0;
  SIGNAL tx_bits : integer range N_CHANNELS*CTR_WIDTH DOWNTO 0;
  SIGNAL tx_bins : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL tx_err_ovf : std_logic;
BEGIN
  PROCESS (clk) IS
    VARIABLE NW : unsigned(15 DOWNTO 0);
    VARIABLE tx_bits_nxt : integer range N_CHANNELS*CTR_WIDTH DOWNTO 0;
    VARIABLE tx_bits_hi : integer range N_CHANNELS*CTR_WIDTH-1 DOWNTO 0;
    VARIABLE tx_ctr_bits_nxt : integer range CTR_WIDTH DOWNTO 0;
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
        CASE current_state IS
        WHEN S_INIT =>
          IF (RdEn = '1') THEN
            IF (DataAddr = 0) THEN
              DData(6 DOWNTO 0) <= tx_err_ovf & Status & tx_active & DRdy & En;
              DData(14 DOWNTO 7) <= (others => '0');
            ELSIF (DataAddr = 1) THEN
              IF (current_tx = TX_IDLE) THEN
                IF (DRdy = '1') THEN
                  NW := resize(N_CHANNELS * CTR_WORDS * (NBtot+1) + 1,16);
                  NWremaining <= NW;
                  DData <= std_logic_vector(NW);
                  tx_ctr_bits <= CTR_WIDTH;
                  tx_bits <= 0;
                  tx_bins <= to_unsigned(0,FIFO_ADDR_WIDTH);
                  current_tx <= TX_NSK;
                ELSE
                  NWremaining <= to_unsigned(0,16);
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
                  tx_ctr_bits <= CTR_WIDTH;
                  tx_bits <= 0;
                  tx_bins <= to_unsigned(0,FIFO_ADDR_WIDTH);
                  current_tx <= TX_DATA;
                ELSE
                  NWremaining <= to_unsigned(0,16);
                END IF;
              WHEN TX_NSK =>
                DData <= std_logic_vector(NSkipped);
                NWremaining <= NWremaining - 1;
                current_tx <= TX_DATA;
                tx_active <= '1';
              WHEN TX_DATA =>
                tx_active <= '1';
                IF (tx_ctr_bits >= 16) THEN
                  IF (tx_bits+15 < N_CHANNELS*CTR_WIDTH) THEN
                    -- tx_bits_hi := tx_bits+15;
                    DData <= FData(tx_bits+15 DOWNTO tx_bits);
                    tx_bits_nxt := tx_bits + 16;
                    tx_ctr_bits_nxt := tx_ctr_bits - 16;
                  ELSE -- This can't happen:
                    DData <= (others => '0');
                    tx_err_ovf <= '1';
                    current_tx <= TX_ERR;
                    tx_ctr_bits_nxt := 0;
                  END IF;
                ELSIF (tx_ctr_bits+tx_bits <= N_CHANNELS*CTR_WIDTH) THEN
                  -- tx_bits_hi := tx_bits+tx_ctr_bits-1;
                  DData(tx_ctr_bits-1 DOWNTO 0) <=
                    FData(tx_bits+tx_ctr_bits-1 DOWNTO tx_bits);
                  DData(15 DOWNTO tx_ctr_bits) <= (others => '0');
                  tx_bits_nxt := tx_bits + tx_ctr_bits;
                  tx_ctr_bits_nxt := 0;
                ELSE -- This can't happen either
                  DData <= (others => '0');
                  tx_err_ovf <= '1';
                  current_tx <= TX_ERR;
                  tx_ctr_bits_nxt := 0;
                END IF;
                IF (tx_bits_nxt = N_CHANNELS*CTR_WIDTH) THEN
                  -- This means we are at the end of a bin
                  tx_bits_nxt := 0;
                  RE <= '1';
                  IF (tx_bins = NBtot) THEN
                    tx_active <= '0';
                    current_tx <= TX_IDLE;
                  ELSE
                    tx_bins <= tx_bins + 1;
                  END IF;
                END IF;
                IF (tx_ctr_bits_nxt = 0) THEN
                  tx_ctr_bits_nxt := CTR_WIDTH;
                END IF;
                tx_bits <= tx_bits_nxt;
                tx_ctr_bits <= tx_ctr_bits_nxt;
                IF (NWremaining /= 0) THEN
                  NWremaining <= NWremaining - 1;
                END IF;
              WHEN TX_ERR =>
                DData <= (others => '0');
              WHEN OTHERS =>
                DData <= (others => '0');
                current_tx <= TX_IDLE;
              END CASE;
            ELSE
              DData <= (others => '0');
              -- Invalid address
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

