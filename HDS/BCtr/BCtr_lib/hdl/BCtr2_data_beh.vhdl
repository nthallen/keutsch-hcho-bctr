--
-- VHDL Architecture BCtr_lib.BCtr2_data.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 12:26:27 11/20/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr2_data IS
  GENERIC( 
    N_CHANNELS      : integer range 4 downto 1   := 2;
    CTR_WIDTH       : integer range 32 downto 16 := 24;
    FIFO_ADDR_WIDTH : integer range 10 downto 4  := 9;
    FIFO_WIDTH      : integer range 128 downto 1 := 48
  );
  PORT( 
    CfgStatus  : IN     std_logic_vector (5 DOWNTO 0);
    DRdy       : IN     std_logic;
    DataAddr   : IN     std_logic_vector (1 DOWNTO 0);
    En         : IN     std_logic;
    Expired    : IN     std_logic;
    IPnumOut   : IN     std_logic_vector (5 DOWNTO 0);
    LaserVOut  : IN     std_logic_vector (15 DOWNTO 0);
    NBtot      : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    NTriggered : IN     std_logic_vector (31 DOWNTO 0);
    NoData     : IN     std_logic;
    RdEn       : IN     std_logic;
    RptData    : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    ScanStat   : IN     std_logic_vector (4 DOWNTO 0);
    clk        : IN     std_logic;
    rst        : IN     std_logic;
    DData      : OUT    std_logic_vector (15 DOWNTO 0);
    RptRE      : OUT    std_logic;
    txing      : OUT    std_logic
  );

-- Declarations

END ENTITY BCtr2_data ;

ARCHITECTURE beh OF BCtr2_data IS
  TYPE State_t IS (
    S_INIT, S_RD
  );
  SIGNAL current_state : State_t;
  TYPE TX_t IS (
    TX_IPNUM, TX_NTLSB, TX_NTMSB, TX_LASERV, TX_DATA
  );
  SIGNAL current_tx : TX_t;
  TYPE setup_t IS (
    SU_IDLE, SU_LATCH, SU_WAIT
  );
  SIGNAL setup_state : setup_t;
  SIGNAL tx_active : std_logic;
  SIGNAL NWremaining : unsigned(15 DOWNTO 0);
  SIGNAL IData : std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
  CONSTANT CTR_WORDS : integer := (CTR_WIDTH+15)/16;
  CONSTANT CTR_LAST_WIDTH : integer := CTR_WIDTH-((CTR_WORDS-1)*16);
  SIGNAL DRdy_int : std_logic;
  SIGNAL word_cnt : integer range CTR_WORDS-1 DOWNTO 0;
  SIGNAL chan_cnt : integer range N_CHANNELS-1 DOWNTO 0;
  SIGNAL bin_cnt : unsigned(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL tx_err_ovf : std_logic;
  SIGNAL IPnum_int  : std_logic_vector (5 DOWNTO 0);
  SIGNAL ScanStat_int : std_logic_vector(4 DOWNTO 0);
  SIGNAL LaserV_int  : std_logic_vector (15 DOWNTO 0);
  SIGNAL NTrig_int : std_logic_vector (31 DOWNTO 0);
  SIGNAL Expired_int : std_logic;
  SIGNAL NoData_int : std_logic;
BEGIN
  PROCESS (clk) IS
    VARIABLE NW : unsigned(15 DOWNTO 0);
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (rst = '1') THEN
        RptRE <= '0';
        tx_active <= '0';
        tx_err_ovf <= '0';
        DData <= (others => '0');
        current_state <= S_INIT;
        current_tx <= TX_IPNUM;
        setup_state <= SU_IDLE;
        NWremaining <= to_unsigned(0,16);
        IPnum_int <= (others => '0');
        LaserV_int <= (others => '0');
        NTrig_int <= (others => '0');
        IData <= (others => '0');
        DRdy_int <= '0';
        word_cnt <= 0;
        chan_cnt <= 0;
        bin_cnt <= (others => '0');
        Expired_int <= '0';
        NoData_int <= '0';
      ELSE
        IF DRdy = '1' OR NWremaining > 0 THEN
          DRdy_int <= '1';
        ELSE
          DRdy_int <= '0';
        END IF;
        CASE current_state IS
        WHEN S_INIT =>
          IF (RdEn = '1') THEN
            IF (DataAddr = "00") THEN -- Reading Status
              DData(10 DOWNTO 0) <=
                Expired & tx_err_ovf & CfgStatus & tx_active & DRdy_int & En;
              DData(15 DOWNTO 11) <= (others => '0');
              current_state <= S_RD;
            ELSIF DataAddr = "01" THEN -- Reading NWremaining
              IF current_tx = TX_IPNUM THEN
                IF tx_active = '1' THEN
                  IF Expired_int = '1' OR NoData_int = '1' THEN
                    NW := to_unsigned(4,NW'length);
                    NWremaining <= NW;
                    DData <= std_logic_vector(NW);
                    -- Expired_int <= Expired;
                    -- setup_state <= SU_LATCH;
                  ELSIF DRdy = '1' THEN
                    NW := resize(N_CHANNELS * CTR_WORDS * (NBtot+1) + 4,16);
                    NWremaining <= NW;
                    DData <= std_logic_vector(NW);
                    bin_cnt <= NBtot;
                    chan_cnt <= N_CHANNELS-1;
                    word_cnt <= CTR_WORDS-1;
                    Expired_int <= '0';
                    IData <= RptData;
                    RptRE <= '1';
                    -- setup_state <= SU_LATCH;
                  ELSE -- should not actually get here
                    NWremaining <= to_unsigned(0,16);
                    DData <= X"0000";
                    tx_active <= '0';
                    -- setup_state <= SU_IDLE;
                  END IF;
                  current_state <= S_RD;
                ELSIF DRdy = '1' OR Expired = '1' THEN
                  tx_active <= '1';
                  Expired_int <= Expired;
                  NoData_int <= NoData;
                  current_state <= S_INIT;
                ELSE
                  DData <= (others => '0');
                  current_state <= S_RD;
                END IF;
              ELSE
                DData <= std_logic_vector(NWremaining);
                current_state <= S_RD;
              END IF;
            ELSIF (DataAddr = "10") THEN
              CASE current_tx IS
              WHEN TX_IPNUM =>
                IF tx_active = '1' AND
                    ( Expired_int = '1' OR NoData_int = '1' OR DRdy_int = '1') THEN
                  DData(15) <= Expired_int;
                  DData(14 downto 10) <= ScanStat_int;
                  DData(9 downto 6) <= (others => '0');
                  DData(5 downto 0) <= IPnum_int;
                  NWremaining <= NWremaining - 1;
                  current_tx <= TX_NTLSB;
                ELSE
                  DData <= X"0000";
                  current_tx <= TX_IPNUM;
                END IF;
              WHEN TX_NTLSB =>
                DData <= NTrig_int(15 DOWNTO 0);
                NWremaining <= NWremaining - 1;
                current_tx <= TX_NTMSB;
              WHEN TX_NTMSB =>
                DData <= NTrig_int(31 DOWNTO 16);
                NWremaining <= NWremaining - 1;
                current_tx <= TX_LASERV;
              WHEN TX_LASERV =>
                DData <= LaserV_int;
                NWremaining <= NWremaining - 1;
                IF Expired_int = '1' OR NoData_int = '1' THEN
                  tx_active <= '0';
                  NoData_int <= '0';
                  Expired_int <= '0';
                  current_tx <= TX_IPNUM;
                ELSE
                  current_tx <= TX_DATA;
                END IF;
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
                      current_tx <= TX_IPNUM;
                    ELSE
                      bin_cnt <= bin_cnt-1;
                      chan_cnt <= N_CHANNELS-1;
                      IData <= RptData;
                      RptRE <= '1';
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
                current_tx <= TX_IPNUM;
              END CASE;
              current_state <= S_RD;
            ELSE -- Invalid address
              DData <= (others => '0');
              current_state <= S_RD;
            END IF;
          ELSE -- RdEn /= '1'
            current_state <= S_INIT;
          END IF;
        WHEN S_RD =>
          RptRE <= '0';
          IF (RdEn = '0') THEN
            current_state <= S_INIT;
          ELSE
            current_state <= S_RD;
          END IF;
        WHEN OTHERS =>
          current_state <= S_INIT;
        END CASE;
        
        -- This state machine is required to ensure
        -- txing is asserted before the first read.
        -- This is to avoid having the FIFO expired
        -- while we are reading it.
        CASE setup_state IS
        WHEN SU_IDLE =>
          IF tx_active = '1' THEN
            setup_state <= SU_LATCH;
          ELSE
            setup_state <= SU_IDLE;
          END IF;
        WHEN SU_LATCH =>
          RptRE <= '0';
          IPnum_int <= IPnumOut;
          ScanStat_int <= ScanStat;
          LaserV_int <= LaserVOut;
          NTrig_int <= NTriggered;
          setup_state <= SU_WAIT;
        WHEN SU_WAIT =>
          IF tx_active = '0' THEN
            setup_state <= SU_IDLE;
          ELSE
            setup_state <= SU_WAIT;
          END IF;
        WHEN others =>
          setup_state <= SU_IDLE;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
  
  txing <= tx_active;
END ARCHITECTURE beh;

