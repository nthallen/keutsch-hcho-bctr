--
-- VHDL Architecture BCtr_lib.BCtr2Ctrl.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:02:55 10/13/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
--
-- VHDL Architecture BCtr_lib.BCtrCtrl.fsm
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:56:33 10/17/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;

ENTITY BCtr2Ctrl IS
  GENERIC( 
    FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
  );
  PORT( 
    En          : IN     std_logic;
    NA          : IN     unsigned (15 DOWNTO 0);
    TrigSeen    : IN     std_logic;
    clk         : IN     std_logic;
    rst         : IN     std_logic;
    CntEn       : OUT    std_logic;
    DRdy        : OUT    std_logic;
    TrigArm     : OUT    std_logic;
    NArd        : OUT    std_logic;
    TrigClr     : OUT    std_logic;
    TrigOE      : OUT    std_logic;
    first_col   : OUT    std_logic;
    first_row   : OUT    std_logic;
    FBRE        : OUT    std_logic;
    EnA         : OUT    std_logic;
    NTriggered  : OUT    std_logic_vector (31 DOWNTO 0);
    LaserVOut   : OUT    std_logic_vector (15 DOWNTO 0);
    NBtot       : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    IPnumOut    : OUT    std_logic_vector (5 DOWNTO 0);
    LaserV      : IN     std_logic_vector (15 DOWNTO 0);
    IPnum       : IN     std_logic_vector (5 DOWNTO 0);
    IPS         : IN     std_logic;
    FBEmpty     : IN     std_logic;
    RptEmpty    : IN     std_logic;
    rstA        : OUT    std_logic;
    rstB        : OUT    std_logic;
    FBFull      : IN     std_logic;
    FBWE        : OUT    std_logic;
    Expired     : OUT    std_logic;
    NoData      : OUT    std_logic;
    txing       : IN     std_logic;
    ScanStat    : IN     std_logic_vector (4 DOWNTO 0);
    ScanStatOut : OUT    std_logic_vector (4 DOWNTO 0)
  );

-- Declarations

END ENTITY BCtr2Ctrl ;

--
ARCHITECTURE fsm OF BCtr2Ctrl IS

   TYPE STATE_TYPE IS (
      Startup,
      ReportArmed,
      TriggerArmed,
      Triggered,
      Scanning
   );
 
   -- Declare current and next state signals
   SIGNAL current_state : STATE_TYPE;
   SIGNAL next_state : STATE_TYPE;

   SIGNAL NBcnt : unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
   SIGNAL Ntrig_cnt : unsigned (23 DOWNTO 0);
   SIGNAL exp_Ntrig : unsigned (23 DOWNTO 0);
   SIGNAL NAcnt : unsigned (15 DOWNTO 0);

   -- Declare any pre-registered internal signals
   SIGNAL first_row_cld : std_logic;
   SIGNAL first_col_cld : std_logic;
   SIGNAL CntEn_cld : std_logic;
   SIGNAL WE_cld : std_logic;
   SIGNAL RE_cld : std_logic;
   SIGNAL DRdy_cld : std_logic;
   SIGNAL TrigClr_cld : std_logic;
   SIGNAL TrigOE_cld : std_logic;
   SIGNAL TrigArm_cld : std_logic;
   SIGNAL cur_LaserV : std_logic_vector(15 DOWNTO 0);
   SIGNAL cur_IPnum : std_logic_vector(5 DOWNTO 0);
   SIGNAL cur_ScanStat : std_logic_vector(4 DOWNTO 0);
   SIGNAL exp_LaserV : std_logic_vector(15 DOWNTO 0);
   SIGNAL exp_IPnum : std_logic_vector(5 DOWNTO 0);
   SIGNAL exp_ScanStat : std_logic_vector(4 DOWNTO 0);
   SIGNAL expired_2 : std_logic; -- expired while reading
   SIGNAL expired_3 : std_logic; -- expired while expired: give up
   SIGNAL IPSseen : std_logic;
   SIGNAL NoData_cld : std_logic;
BEGIN

  -----------------------------------------------------------------
  clocked_proc : PROCESS (clk)
  -----------------------------------------------------------------
    variable nxtEnA : std_logic;
  BEGIN
    IF (clk'EVENT AND clk = '1') THEN
      IF (rst = '1') THEN
        current_state <= Startup;
        -- Default Reset Values
        first_row_cld <= '1';
        first_col_cld <= '1';
        CntEn_cld <= '0';
        WE_cld <= '0';
        RE_cld <= '0';
        DRdy_cld <= '0';
        TrigClr_cld <= '0';
        TrigOE_cld <= '1';
        TrigArm_cld <= '0';
        NAcnt <= (others => '0');
        NBcnt <= (others => '0');
        Ntrig_cnt <= (others => '0');
        NArd <= '0';
        expired_2 <= '0';
        expired_3 <= '0';
        Expired <= '0';
        rstA <= '1';
        rstB <= '1';
        EnA <= '1'; -- Start with A on Feedback
        IPSseen <= '0';
        NTriggered <= (others => '0');
        LaserVOut <= (others => '0');
        IPnumOut <= (others => '0');
        ScanStatOut <= (others => '0');
        cur_LaserV <= (others => '0');
        cur_IPnum <= (others => '0');
        cur_ScanStat <= (others => '0');
        exp_Ntrig <= (others => '0');
        exp_LaserV <= (others => '0');
        exp_IPnum <= (others => '0');
        exp_ScanStat <= (others => '0');
        NoData_cld <= '0';
        nxtEnA := '0';
      ELSE
        current_state <= next_state;

        -- Combined Actions
        CASE current_state IS
          WHEN Startup => 
            first_row_cld <= '1';
            first_col_cld <= '1';
            CntEn_cld <= '0';
            WE_cld <= '0';
            RE_cld <= '0';
            TrigClr_cld <= '1';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
            NArd <= '0';
            -- The following is to clear up any trailing data from the previous run
            IF En /= '1' AND txing = '0' AND FBEmpty = '0' AND IPS = '1' THEN
              nxtEnA := not(EnA);
              DRdy_cld <= '1';
              LaserVOut <= cur_LaserV;
              IPnumOut <= cur_IPnum;
              ScanStatOut <= cur_ScanStat;
              NTriggered <= std_logic_vector(
                resize(Ntrig_cnt,NTriggered'length));
              IF nxtEnA = '1' THEN
                rstA <= '1';
              ELSE
                rstB <= '1';
              END IF;
              EnA <= nxtEnA;
            END IF;
          WHEN ReportArmed => -- We are only here for one clock
            IPSseen <= '0';
            -- Reset the FIFO we're going to write to:
            first_row_cld <= '1';
            CntEn_cld <= '0';
            WE_cld <= '0';
            RE_cld <= '0';
            Ntrig_cnt <= (others => '0');
            TrigClr_cld <= '1';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
            NArd <= '0';
            IF (RptEmpty = '1' OR Expired = '1' OR expired_3 = '1') AND txing = '0' AND expired_2 = '0' THEN
              nxtEnA := not(EnA);
              LaserVOut <= cur_LaserV;
              IPnumOut <= cur_IPnum;
              ScanStatOut <= cur_ScanStat;
              NTriggered <= std_logic_vector(
                resize(Ntrig_cnt,NTriggered'length));
              IF Expired = '1' THEN
                expired_3 <= '1';
                Expired <= '0';
              END IF;
              -- DRdy_cld <= not(FBEmpty); -- Only declare DRdy if there is data
              -- Alternate strategy: Always report DRdy but provide
              -- another bit to indicate no counter data (NoData). That allows
              -- the data block to still report the other relevant data.
              DRdy_cld <= '1';
              NoData_cld <= FBEmpty;
            ELSIF txing = '0' AND DRdy_cld = '1' THEN
              -- DRdy_cld = '1' implies RptEmpty = '0' OR Expired = '1' OR NoData = '1'
              nxtEnA := not(EnA);
              Expired <= '1';
              exp_LaserV <= cur_LaserV;
              exp_IPnum <= cur_IPnum;
              exp_ScanStat <= cur_ScanStat;
              exp_Ntrig <= Ntrig_cnt;
            ELSIF txing = '1' THEN
              -- transmitting, so can't touch the rpt buffer
              -- (unless Expired = '1' or NoData = '1')
              nxtEnA := EnA;
              expired_2 <= '1';
              exp_LaserV <= cur_LaserV;
              exp_ScanStat <= cur_ScanStat;
              exp_IPnum <= cur_IPnum;
              exp_Ntrig <= Ntrig_cnt;
            END IF;
            IF nxtEnA = '1' THEN
              rstA <= '1';
            ELSE
              rstB <= '1';
            END IF;
            EnA <= nxtEnA;
          WHEN TriggerArmed =>
            rstA <= '0';
            rstB <= '0';
            first_col_cld <= '1';
            CntEn_cld <= '0';
            WE_cld <= '0';
            RE_cld <= '0';
            TrigClr_cld <= '0';
            TrigArm_cld <= '1';
            NArd <= '0';
          WHEN Triggered =>
            Ntrig_cnt <= Ntrig_cnt + 1;
            CntEn_cld <= '1';
            IF first_row_cld = '0' THEN
              RE_cld <= '1';
            END IF;
            IF NA = 0 AND NBtot = 0 THEN
              WE_cld <= '1';
            END IF;
            TrigArm_cld <= '0';
            NBcnt <= NBtot;
            NAcnt <= NA;
            NArd <= '1';
          WHEN Scanning =>
            TrigClr_cld <= '1';
            TrigArm_cld <= '0';
            NArd <= '0';
            if NAcnt = 0 then -- last sample in a bin
              NAcnt <= NA;
              NArd <= '1';
              first_col_cld <= '1';
              if first_row_cld = '0' then
                RE_cld <= '1';
              end if;
              WE_cld <= '1';
              if NBcnt = 0 then -- last sample in a trigger
                NBcnt <= NBtot;
                CntEn_cld <= '0';
                RE_cld <= '0';
                first_row_cld <= '0';
              else
                NBcnt <= NBcnt - 1;
              end if;
            else
              NAcnt <= NAcnt - 1;
              first_col_cld <= '0';
              WE_cld <= '0';
              RE_cld <= '0';
            end if;
          WHEN OTHERS =>
            NULL;
        END CASE;
        
        IF IPS = '1' THEN
          IPSseen <= '1';
          cur_LaserV <= LaserV;
          cur_IPnum <= IPnum;
          cur_ScanStat <= ScanStat;
        END IF;
        
        IF txing = '1' THEN
          DRdy_cld <= '0';
          NoData_cld <= '0';
          Expired <= '0';
        ELSIF DRdy_cld = '0' THEN
          IF RptEmpty = '0' OR expired_2 = '1' THEN
            DRdy_cld <= '1';
            IPnumOut <= exp_IPnum;
            LaserVOut <= exp_LaserV;
            NTriggered <= std_logic_vector(
                  resize(exp_Ntrig,NTriggered'length));
            IF expired_2 = '1' THEN
              Expired <= '1';
              expired_2 <= '0';
            ELSE
              Expired <= '0';
            END IF;
          ELSE
            expired_3 <= '0';
          END IF;
        END IF;
      END IF; -- not(rst)
    END IF; -- clk'event and clk = '1'
  END PROCESS clocked_proc;

  -----------------------------------------------------------------
   nextstate_proc : PROCESS ( 
      En, IPS, IPSseen,
      TrigSeen,
      NAcnt, NBcnt,
      current_state
   )
   -----------------------------------------------------------------
  BEGIN
    CASE current_state IS
      WHEN Startup => 
        IF (En = '1' AND IPS = '1') THEN 
          next_state <= ReportArmed;
        ELSE
          next_state <= Startup;
        END IF;
      WHEN ReportArmed => 
        if En = '1' then
          next_state <= TriggerArmed;
        else
          next_state <= Startup;
        end if;
      WHEN TriggerArmed =>
        IF En /= '1' THEN 
          next_state <= Startup;
        ELSIF IPS = '1' OR IPSseen = '1' THEN
          next_state <= ReportArmed;
        ELSIF TrigSeen = '1' THEN
          next_state <= Triggered;
        ELSE
          next_state <= TriggerArmed;
        END IF;
      WHEN Triggered =>
        IF En /= '1' THEN
          next_state <= Startup;
        ELSE
          next_state <= Scanning;
        END IF;
      WHEN Scanning =>
        if NAcnt = 0 AND NBcnt = 0 then
          IF IPS = '1' OR IPSseen = '1' THEN
            next_state <= ReportArmed;
          ELSIF En /= '1' THEN
            next_state <= Startup;
          ELSE
            next_state <= TriggerArmed;
          end if;
        else
          next_state <= Scanning;
        end if;
      WHEN OTHERS =>
        next_state <= Startup;
    END CASE;
  END PROCESS nextstate_proc;
  
  DRdy <= DRdy_cld;
  NoData <= NoData_cld;
 
  first_row <= first_row_cld;
  first_col <= first_col_cld;
  CntEn <= CntEn_cld;
  FBWE <= WE_cld;
  FBRE <= RE_cld;
  TrigClr <= TrigClr_cld;
  TrigOE <= TrigOE_cld;
  TrigArm <= TrigArm_cld;
END ARCHITECTURE fsm;

