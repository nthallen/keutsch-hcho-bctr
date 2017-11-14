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
    BASE_ADDR  : unsigned(15 DOWNTO 0) := x"0080";
    STEP_RES   : integer range 8 downto 0 := 3
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
    LDAC     : OUT    std_logic -- Negative logic
  );

-- Declarations

END ENTITY dacscan ;

--
ARCHITECTURE beh OF dacscan IS
  SIGNAL StatusCmd_en : std_logic;
  SIGNAL SetPoint_en : std_logic;
  SIGNAL ScanStart_en : std_logic;
  SIGNAL ScanStop_en : std_logic;
  SIGNAL ScanStep_en : std_logic;
  SIGNAL OnlinePos_en : std_logic;
  SIGNAL OfflinePos_en : std_logic;
  SIGNAL Dither_en : std_logic;
  SIGNAL SetPoint : unsigned(15 downto 0);
  SIGNAL nextSetPoint : unsigned(15 downto 0);
  SIGNAL ScanStart : unsigned(15 downto 0);
  SIGNAL ScanStop : unsigned(15 downto 0);
  SIGNAL ScanStep : unsigned(15+STEP_RES downto 0);
  SIGNAL CurStep  : unsigned(15+STEP_RES downto 0);
  SIGNAL OnlinePos : unsigned(15 downto 0);
  SIGNAL OfflinePos : unsigned(15 downto 0);
  SIGNAL Dither : unsigned(15 downto 0);
  SIGNAL Scanning : std_logic;
  SIGNAL ScanningCmd : std_logic;
  SIGNAL next_Scanning : std_logic;
  SIGNAL Online : std_logic;
  SIGNAL next_Online : std_logic;
  SIGNAL Offline : std_logic;
  SIGNAL next_Offline : std_logic;
  TYPE state_t IS (st_idle, st_wrdac_0, st_wrdac_1, st_wrdac_2,
      st_scan_0, st_scan_end);
  SIGNAL current_state : state_t;
  SIGNAL start_write : std_logic;
  SIGNAL loop_count : unsigned(5 DOWNTO 0); -- 0 to 63
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
    OfflinePos_en <= '0';
    Dither_en <= '0';
    offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
    CASE to_integer(offset) IS
      WHEN 0 => StatusCmd_en <= '1';
      WHEN 1 => SetPoint_en <= '1';
      WHEN 2 => ScanStart_en <= '1';
      WHEN 3 => ScanStop_en <= '1';
      WHEN 4 => ScanStep_en <= '1';
      WHEN 5 => OnlinePos_en <= '1';
      WHEN 6 => OfflinePos_en <= '1';
      WHEN 7 => Dither_en <= '1';
      WHEN others => BdEn <= '0';
    END CASE;
  END PROCESS;
  
  rw_proc : PROCESS (clk) IS
  BEGIN
    IF clk'event AND clk = '1' THEN
      IF ExpReset = '1' THEN
        SetPoint   <= (others => '0');
        nextSetPoint <= (others => '0');
        ScanStart  <= (others => '0');
        ScanStop   <= (others => '0');
        ScanStep   <= (others => '0');
        CurStep    <= (others => '0');
        OnlinePos  <= (others => '0');
        OfflinePos <= (others => '0');
        Dither     <= (others => '0');
        Scanning   <= '0';
        ScanningCmd <= '0';
        Online     <= '0';
        Offline    <= '0';
        next_Scanning   <= '0';
        next_Online     <= '0';
        next_Offline    <= '0';
        RData      <= (others => '0');
        current_state <= st_idle;
        start_write <= '0';
        idxData <= (others => '0');
        idxWr <= '0';
        LDAC <= '1';
        loop_count <= (others => '0');
      ELSE
        IF RdEn = '1' THEN
          IF StatusCmd_en = '1' THEN
            RData <= (
              0 => Scanning,
              1 => Online,
              2 => Offline,
              others => '0');
          ELSIF SetPoint_en = '1' THEN
            RData <= std_logic_vector(SetPoint);
          ELSIF ScanStart_en = '1' THEN
            RData <= std_logic_vector(ScanStart);
          ELSIF ScanStop_en = '1' THEN
            RData <= std_logic_vector(ScanStop);
          ELSIF ScanStep_en = '1' THEN
            RData <= std_logic_vector(ScanStep(15 DOWNTO 0));
          ELSIF OnlinePos_en = '1' THEN
            RData <= std_logic_vector(OnlinePos);
          ELSIF OfflinePos_en = '1' THEN
            RData <= std_logic_vector(OfflinePos);
          ELSIF Dither_en = '1' THEN
            RData <= std_logic_vector(Dither);
          END IF;
        ELSIF WrEn = '1' AND current_state = st_idle THEN
          IF StatusCmd_en = '1' THEN
            CASE to_integer(unsigned(WData)) IS
            WHEN 0 => -- stop scan
              ScanningCmd <= '0';
            WHEN 1 => -- start scan
              CurStep(15+STEP_RES DOWNTO STEP_RES) <= ScanStart;
              CurStep(STEP_RES-1 DOWNTO 0) <= (others => '0');
              nextSetPoint <= ScanStart;
              ScanningCmd <= '1';
              next_Scanning <= '1';
              start_write <= '1';
            WHEN 2 => -- drive online
              nextSetPoint <= OnlinePos;
              next_Online <= '1';
              start_write <= '1';
            WHEN 3 => -- drive online+dither
              nextSetPoint <= OnlinePos + Dither;
              next_Online <= '1';
              start_write <= '1';
            WHEN 4 => -- drive online-dither
              nextSetPoint <= OnlinePos - Dither;
              next_Online <= '1';
              start_write <= '1';
            WHEN 5 => -- drive offline
              nextSetPoint <= OfflinePos;
              next_Offline <= '1';
              start_write <= '1';
            WHEN others =>
              NULL;
            END CASE;
          ELSIF SetPoint_en = '1' THEN
            nextSetPoint <= unsigned(WData);
            start_write <= '1';
          ELSIF ScanStart_en = '1' THEN
            ScanStart <= unsigned(WData);
          ELSIF ScanStop_en = '1' THEN
            ScanStop <= unsigned(WData);
          ELSIF ScanStep_en = '1' THEN
            ScanStep(15 DOWNTO 0) <= unsigned(WData);
            ScanStep(15+STEP_RES DOWNTO 16) <= (others => '0');
          ELSIF OnlinePos_en = '1' THEN
            OnlinePos <= unsigned(WData);
          ELSIF OfflinePos_en = '1' THEN
            OfflinePos <= unsigned(WData);
          ELSIF Dither_en = '1' THEN
            Dither <= unsigned(WData);
          END IF;
        END IF;
        
        CASE current_state IS
        WHEN st_idle =>
          IF start_write = '1' THEN
            current_state <= st_wrdac_0;
            start_write <= '0';
          ELSE
            current_state <= st_idle;
          END IF;
        WHEN st_wrdac_0 =>
          idxData <= std_logic_vector(nextSetPoint);
          idxWr <= '1';
          IF idxAck = '1' THEN
            current_state <= st_wrdac_1;
          ELSE
            current_state <= st_wrdac_0;
          END IF;
        WHEN st_wrdac_1 =>
          idxWr <= '0';
          IF IPS = '1' THEN
            LDAC <= '0'; -- negative logic
            SetPoint <= nextSetPoint;
            Scanning <= next_Scanning;
            Online <= next_Online;
            Offline <= next_Offline;
            next_Online <= '0';
            next_Offline <= '0';
            next_Scanning <= '0';
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
              current_state <= st_scan_0;
            ELSE
              current_state <= st_idle;
            END IF;
          ELSE
            loop_count <= loop_count - 1;
            current_state <= st_wrdac_2;
          END IF;
        WHEN st_scan_0 =>
          IF ScanningCmd = '0' OR
              CurStep(15+STEP_RES DOWNTO STEP_RES) >= ScanStop THEN
            current_state <= st_scan_end;
          ELSE
            next_Scanning <= '1';
            nextSetPoint <= CurStep(15+STEP_RES DOWNTO STEP_RES);
            current_state <= st_wrdac_0;
          END IF;
        WHEN st_scan_end =>
          IF IPS = '1' THEN
            Scanning <= '0';
            next_Scanning <= '0';
            current_state <= st_idle;
          ELSE
            current_state <= st_scan_end;
          END IF;
        WHEN others =>
          current_state <= st_idle;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

