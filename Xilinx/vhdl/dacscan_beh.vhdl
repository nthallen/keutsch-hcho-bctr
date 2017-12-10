--
-- VHDL Architecture BCtr_lib.dacscan.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 15:06:07 11/11/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY dacscan IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := x"0080";
    STEP_RES   : integer range 8 downto 0  := 4
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpReset : IN     std_logic;
    IPS      : IN     std_logic;
    RdEn     : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    WrEn     : IN     std_logic;
    clk      : IN     std_logic;
    idxAck   : IN     std_logic;
    BdEn     : OUT    std_logic;
    BdWrEn   : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    idxData  : OUT    std_logic_vector (15 DOWNTO 0);
    idxWr    : OUT    std_logic;
    LDAC     : OUT    std_logic;
    SetPoint : OUT    std_logic_vector (15 DOWNTO 0);
    ScanStat : OUT    std_logic_vector (4 DOWNTO 0)
  );

-- Declarations

END ENTITY dacscan ;

Library BCtr_lib;

ARCHITECTURE beh OF dacscan IS
  SIGNAL StatusCmd_en : std_logic;
  SIGNAL SetPoint_en : std_logic;
  SIGNAL ScanStart_en : std_logic;
  SIGNAL ScanStop_en : std_logic;
  SIGNAL ScanStep_en : std_logic;
  SIGNAL OnlinePos_en : std_logic;
  SIGNAL OfflineDelta_en : std_logic;
  SIGNAL Dither_en : std_logic;
  SIGNAL SetPoint_int : unsigned(15 downto 0);
  SIGNAL nextSetPoint : signed(16 downto 0);
  SIGNAL ScanStart : signed(16 downto 0);
  SIGNAL ScanStop : signed(16 downto 0);
  SIGNAL ScanStep : signed(16+STEP_RES downto 0);
  SIGNAL CurStep  : signed(16+STEP_RES downto 0);
  SIGNAL OnlinePos : signed(16 downto 0);
  SIGNAL OfflineDelta : signed(16 downto 0);
  SIGNAL Dither : signed(16 downto 0);
  SIGNAL Scanning : std_logic;
  SIGNAL next_Scanning : std_logic;
  SIGNAL Chopping : std_logic;
  SIGNAL next_Chopping : std_logic;
  SIGNAL Online : std_logic;
  SIGNAL next_Online : std_logic;
  SIGNAL Offline : std_logic;
  SIGNAL next_Offline : std_logic;
  TYPE state_t IS (st_idle, st_wrdac_0, st_wrdac_1, st_wrdac_2,
      st_scan_init, st_scan_step, st_scan_end,
      st_chop_check, st_chop_wait, st_abort);
  SIGNAL current_state : state_t;
  SIGNAL start_write : std_logic;
  SIGNAL loop_count : unsigned(5 DOWNTO 0); -- 0 to 63
  SIGNAL cmd_abort : std_logic;
  SIGNAL cmd_start_scan : std_logic;
  SIGNAL cmd_online : std_logic;
  SIGNAL cmd_offline : std_logic;
  SIGNAL cmd_chop_init : std_logic;
  SIGNAL cmd_chop_exit : std_logic;
  SIGNAL NPtsOnline : unsigned(15 DOWNTO 0);
  SIGNAL NPtsOnline_en : std_logic;
  SIGNAL NPtsOffline : unsigned(15 DOWNTO 0);
  SIGNAL NPtsOffline_en : std_logic;
  SIGNAL NPtsChop : unsigned(15 DOWNTO 0);
  SIGNAL PosOVF : std_logic;
BEGIN
  addr : PROCESS (ExpAddr, current_state) IS
    VARIABLE offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    IF current_state = st_idle THEN
      BdWrEn <= '1';
    ELSE
      BdWrEn <= '0';
    END IF;
    BdEn <= '1';
    StatusCmd_en <= '0';
    SetPoint_en <= '0';
    ScanStart_en <= '0';
    ScanStop_en <= '0';
    ScanStep_en <= '0';
    OnlinePos_en <= '0';
    OfflineDelta_en <= '0';
    Dither_en <= '0';
    NPtsOnline_en <= '0';
    NPtsOffline_en <= '0';
    offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
    CASE to_integer(offset) IS
      WHEN 0 => StatusCmd_en <= '1'; BdWrEn <= '1';
      WHEN 1 => SetPoint_en <= '1';
      WHEN 2 => ScanStart_en <= '1';
      WHEN 3 => ScanStop_en <= '1';
      WHEN 4 => ScanStep_en <= '1';
      WHEN 5 => OnlinePos_en <= '1';
      WHEN 6 => OfflineDelta_en <= '1';
      WHEN 7 => Dither_en <= '1';
      WHEN 8 => NPtsOnline_en <= '1';
      WHEN 9 => NPtsOffline_en <= '1';
      WHEN others => BdEn <= '0';
    END CASE;
  END PROCESS;
  
  rw_proc : PROCESS (clk) IS
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF ExpReset = '1' THEN
        SetPoint_int   <= (others => '0');
        nextSetPoint <= (others => '0');
        ScanStart  <= (others => '0');
        ScanStop   <= (others => '0');
        ScanStep   <= (others => '0');
        CurStep    <= (others => '0');
        OnlinePos  <= (others => '0');
        Dither     <= (others => '0');
        OfflineDelta <= (others => '0');
        NPtsOnline <= (others => '0');
        NPtsOffline <= (others => '0');
        NPtsChop <= (others => '0');
        Scanning   <= '0';
        Chopping   <= '0';
        Online     <= '0';
        Offline    <= '0';
        PosOVF     <= '0';
        next_Scanning   <= '0';
        next_Chopping   <= '0';
        next_Online     <= '0';
        next_Offline    <= '0';
        RData      <= (others => '0');
        current_state <= st_idle;
        start_write <= '0';
        idxData <= (others => '0');
        idxWr <= '0';
        LDAC <= '1';
        loop_count <= (others => '0');
        cmd_abort <= '0';
        cmd_start_scan <= '0';
        cmd_online <= '0';
        cmd_offline <= '0';
        cmd_chop_init <= '0';
        cmd_chop_exit <= '0';
      ELSE
        IF RdEn = '1' THEN
          IF StatusCmd_en = '1' THEN
            RData <= (
              0 => Scanning,
              1 => Online,
              2 => Offline,
              3 => Chopping,
              4 => PosOVF,
              others => '0');
          ELSIF SetPoint_en = '1' THEN
            RData <= std_logic_vector(SetPoint_int);
          ELSIF ScanStart_en = '1' THEN
            RData <= std_logic_vector(ScanStart(15 DOWNTO 0));
          ELSIF ScanStop_en = '1' THEN
            RData <= std_logic_vector(ScanStop(15 DOWNTO 0));
          ELSIF ScanStep_en = '1' THEN
            RData <= std_logic_vector(ScanStep(15 DOWNTO 0));
          ELSIF OnlinePos_en = '1' THEN
            RData <= std_logic_vector(OnlinePos(15 DOWNTO 0));
          ELSIF OfflineDelta_en = '1' THEN
            RData <= std_logic_vector(OfflineDelta(15 DOWNTO 0));
          ELSIF Dither_en = '1' THEN
            RData <= std_logic_vector(Dither(15 DOWNTO 0));
          ELSIF NPtsOnline_en = '1' THEN
            RData <= std_logic_vector(NPtsOnline);
          ELSIF NPtsOffline_en = '1' THEN
            RData <= std_logic_vector(NPtsOffline);
          END IF;
        ELSIF WrEn = '1' THEN
          IF StatusCmd_en = '1' THEN
            CASE to_integer(unsigned(WData)) IS
            WHEN 0 => -- abort scan or chopping
              cmd_abort <= '1';
            WHEN 1 => -- start scan
              cmd_start_scan <= '1';
            WHEN 2 => -- drive online
              cmd_online <= '1';
            WHEN 3 => -- move online+dither
              OnlinePos <= OnlinePos + Dither;
            WHEN 4 => -- move online-dither
              OnlinePos <= OnlinePos - Dither;
            WHEN 5 => -- drive offline
              cmd_offline <= '1';
            WHEN 6 => -- Enter Chop Mode (online)
              cmd_chop_init <= '1';
            WHEN 7 => -- Exit Chop Mode after offline
              cmd_chop_exit <= '1';
            WHEN others =>
              NULL;
            END CASE;
          ELSIF current_state = st_idle THEN
            IF SetPoint_en = '1' THEN
              nextSetPoint <=
                signed(resize(unsigned(WData),nextSetPoint'length));
              start_write <= '1';
            ELSIF ScanStart_en = '1' THEN
              ScanStart <=
                signed(resize(unsigned(WData),ScanStart'length));
            ELSIF ScanStop_en = '1' THEN
              ScanStop <=
                signed(resize(unsigned(WData),ScanStart'length));
            ELSIF ScanStep_en = '1' THEN
              ScanStep(15 DOWNTO 0) <= signed(WData);
              ScanStep(16+STEP_RES DOWNTO 16) <= (others => '0');
            ELSIF OnlinePos_en = '1' THEN
              OnlinePos <=
                signed(resize(unsigned(WData),OnlinePos'length));
            ELSIF OfflineDelta_en = '1' THEN
              OfflineDelta <= resize(signed(WData),OfflineDelta'length);
            ELSIF Dither_en = '1' THEN
              Dither <= signed(resize(unsigned(WData),Dither'length));
            ELSIF NPtsOnline_en = '1' THEN
              NPtsOnline <= unsigned(WData);
            ELSIF NPtsOffline_en = '1' THEN
              NPtsOffline <= unsigned(WData);
            END IF;
          END IF;
        END IF;
        
        CASE current_state IS
        WHEN st_idle =>
          IF cmd_start_scan = '1' THEN
            current_state <= st_scan_init;
          ELSIF cmd_online = '1' THEN
            cmd_online <= '0';
            nextSetPoint <= OnlinePos;
            next_Scanning <= '0';
            next_Online <= '1';
            next_Offline <= '0';
            current_state <= st_wrdac_0;
          ELSIF cmd_offline = '1' THEN
            nextSetPoint <= OnlinePos+OfflineDelta;
            next_Scanning <= '0';
            next_Online <= '0';
            next_Offline <= '1';
            cmd_offline <= '0';
            current_state <= st_wrdac_0;
          ELSIF cmd_chop_init = '1' THEN
            next_Scanning <= '0';
            next_Online <= '1';
            next_Offline <= '0';
            next_Chopping <= '1';
            nextSetPoint <= OnlinePos;
            current_state <= st_wrdac_0;
          ELSIF cmd_chop_exit = '1' THEN
            cmd_chop_exit <= '0';
            current_state <= st_idle;
          ELSIF start_write = '1' THEN
            start_write <= '0';
            current_state <= st_wrdac_0;
          ELSIF cmd_abort = '1' THEN
            current_state <= st_abort;
          ELSE
            current_state <= st_idle;
          END IF;
        WHEN st_wrdac_0 =>
          IF nextSetPoint(16) = '0' THEN
            idxData <= std_logic_vector(nextSetPoint(15 DOWNTO 0));
            idxWr <= '1';
            PosOVF <= '0';
            IF idxAck = '1' THEN
              current_state <= st_wrdac_1;
            ELSE
              current_state <= st_wrdac_0;
            END IF;
          ELSE
            PosOVF <= '1';
            current_state <= st_abort;
          END IF;
        WHEN st_wrdac_1 =>
          idxWr <= '0';
          IF cmd_abort = '1' THEN
            current_state <= st_abort;
          ELSIF IPS = '1' THEN
            LDAC <= '0'; -- negative logic
            SetPoint_int <= unsigned(nextSetPoint(15 DOWNTO 0));
            Scanning <= next_Scanning;
            Chopping <= next_Chopping;
            Online <= next_Online;
            Offline <= next_Offline;
            next_Online <= '0';
            next_Offline <= '0';
            next_Scanning <= '0';
            next_Chopping <= '0';
            loop_count <= to_unsigned(50,loop_count'length);
            current_state <= st_wrdac_2;
          ELSE
            current_state <= st_wrdac_1;
          END IF;
        WHEN st_wrdac_2 =>
          IF to_integer(loop_count) = 0 THEN
            LDAC <= '1';
            IF Scanning = '1' THEN
              CurStep <= CurStep + ScanStep;
              current_state <= st_scan_step;
            ELSIF Chopping = '1' THEN
              IF Online = '1' THEN
                NPtsChop <= NPtsOnline;
              ELSE
                NPtsChop <= NPtsOffline;
              END IF;
              current_state <= st_chop_check;
            ELSE
              current_state <= st_idle;
            END IF;
          ELSE
            loop_count <= loop_count - 1;
            current_state <= st_wrdac_2;
          END IF;
        WHEN st_scan_init =>
          CurStep(16+STEP_RES DOWNTO STEP_RES) <= ScanStart;
          CurStep(STEP_RES-1 DOWNTO 0) <= (others => '0');
          nextSetPoint <= ScanStart;
          next_Scanning <= '1';
          next_Chopping <= '0';
          next_Online <= '0';
          next_Offline <= '0';
          cmd_start_scan <= '0';
          current_state <= st_wrdac_0;
        WHEN st_scan_step =>
          IF cmd_abort = '1' THEN
            current_state <= st_abort;
          ELSIF CurStep(16+STEP_RES DOWNTO STEP_RES) >= ScanStop THEN
            current_state <= st_scan_end;
          ELSE
            next_Scanning <= '1';
            nextSetPoint <= CurStep(16+STEP_RES DOWNTO STEP_RES);
            current_state <= st_wrdac_0;
          END IF;
        WHEN st_scan_end =>
          IF cmd_abort = '1' THEN
            current_state <= st_abort;
          ELSIF IPS = '1' THEN
            Scanning <= '0';
            next_Scanning <= '0';
            current_state <= st_idle;
          ELSE
            current_state <= st_scan_end;
          END IF;
        WHEN st_chop_check =>
          IF NPtsChop < 2 THEN
            IF Online = '1' THEN
              nextSetPoint <= OnlinePos + OfflineDelta;
              next_Scanning <= '0';
              next_Chopping <= '1';
              next_Online <= '0';
              next_Offline <= '1';
              current_state <= st_wrdac_0;
            ELSIF cmd_chop_exit = '1' THEN
              next_Chopping <= '0';
              cmd_chop_exit <= '0';
              current_state <= st_chop_wait;
            ELSE
              nextSetPoint <= OnlinePos;
              next_Scanning <= '0';
              next_Chopping <= '1';
              next_Online <= '1';
              next_Offline <= '0';
              current_state <= st_wrdac_0;
            END IF;
          ELSE
            NPtsChop <= NPtsChop - 1;
            current_state <= st_chop_wait;
          END IF;
        WHEN st_chop_wait =>
          IF IPS = '1' THEN
            IF next_Chopping = '0' THEN
              Chopping <= '0';
              current_state <= st_idle;
            ELSE
              current_state <= st_chop_check;
            END IF;
          END IF;
        WHEN st_abort =>
          Scanning <= '0';
          next_Scanning <= '0';
          Chopping <= '0';
          next_Chopping <= '0';
          Online <= '0';
          next_Online <= '0';
          Offline <= '0';
          next_Offline <= '0';
          current_state <= st_idle;
          cmd_abort <= '0';
        WHEN others =>
          current_state <= st_idle;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
  
  SetPoint <= std_logic_vector(SetPoint_int);
  ScanStat <= (
    0 => Scanning,
    1 => Online,
    2 => Offline,
    3 => Chopping,
    4 => PosOVF);
END ARCHITECTURE beh;

