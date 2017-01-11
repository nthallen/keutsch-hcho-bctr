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

ENTITY BCtrCtrl IS
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
  );
  PORT( 
    Empty1    : IN     std_logic;
    Empty2    : IN     std_logic;
    En        : IN     std_logic;
    Full1     : IN     std_logic;
    NA        : IN     unsigned (15 DOWNTO 0);
    NC        : IN     unsigned (23 DOWNTO 0);
    NB        : IN     unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    TrigSeen  : IN     std_logic;
    clk       : IN     std_logic;
    rst       : IN     std_logic;
    CntEn     : OUT    std_logic;
    DRdy      : OUT    std_logic;
    RE1       : OUT    std_logic;
    TrigArm   : OUT    std_logic;
    NArd      : OUT    std_logic;
    TrigClr   : OUT    std_logic;
    TrigOE    : OUT    std_logic;
    WE1       : OUT    std_logic;
    WE2       : OUT    std_logic;
    first_col : OUT    std_logic;
    first_row : OUT    std_logic;
    NSkipped  : OUT    unsigned (15 DOWNTO 0)
);

-- Declarations

END BCtrCtrl ;

--
ARCHITECTURE fsm OF BCtrCtrl IS

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
   SIGNAL NCcnt : unsigned (23 DOWNTO 0);
   SIGNAL NAcnt : unsigned (15 DOWNTO 0);

   -- Declare any pre-registered internal signals
   SIGNAL first_row_cld : std_logic;
   SIGNAL first_col_cld : std_logic;
   SIGNAL CntEn_cld : std_logic;
   SIGNAL WE1_cld : std_logic;
   SIGNAL WE2_cld : std_logic;
   SIGNAL RE1_cld : std_logic;
   SIGNAL DRdy_cld : std_logic;
   SIGNAL TrigClr_cld : std_logic;
   SIGNAL TrigOE_cld : std_logic;
   SIGNAL TrigArm_cld : std_logic;
   SIGNAL Skipping : std_logic;
   SIGNAL NSkip : unsigned (15 DOWNTO 0);
BEGIN

  -----------------------------------------------------------------
  clocked_proc : PROCESS (clk)
  -----------------------------------------------------------------
  BEGIN
    IF (clk'EVENT AND clk = '1') THEN
      IF (rst = '1') THEN
        current_state <= Startup;
        -- Default Reset Values
        first_row_cld <= '1';
        first_col_cld <= '1';
        CntEn_cld <= '0';
        WE1_cld <= '0';
        WE2_cld <= '0';
        RE1_cld <= '0';
        DRdy_cld <= '0';
        TrigClr_cld <= '0';
        TrigOE_cld <= '1';
        TrigArm_cld <= '0';
        NAcnt <= (others => '0');
        NBcnt <= (others => '0');
        NCcnt <= (others => '0');
        NArd <= '0';
        Skipping <= '0';
        NSkip <= (others => '0');
        NSkipped <= (others => '0');
      ELSE
        current_state <= next_state;

        -- Combined Actions
        CASE current_state IS -- Disabled.
          WHEN Startup => 
            first_row_cld <= '1';
            first_col_cld <= '1';
            CntEn_cld <= '0';
            WE1_cld <= '0';
            WE2_cld <= '0';
            RE1_cld <= '1';
            TrigClr_cld <= '1';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
            Skipping <= '0';
            NArd <= '0';
          WHEN ReportArmed => 
            first_row_cld <= '1';
            CntEn_cld <= '0';
            WE1_cld <= '0';
            WE2_cld <= '0';
            RE1_cld <= '0';
            NCcnt <= (others => '0');
            TrigClr_cld <= '1';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
            NArd <= '0';
            NSkip <= (others => '0');
            if Empty2 = '1' then
              DRdy_cld <= '0';
            end if;
          WHEN TriggerArmed =>
            first_col_cld <= '1';
            CntEn_cld <= '0';
            WE1_cld <= '0';
            WE2_cld <= '0';
            RE1_cld <= '0';
            TrigClr_cld <= '0';
            TrigArm_cld <= '1';
            NArd <= '0';
            IF En = '1' AND TrigSeen = '1' THEN
              IF ( NC = 0 OR NCcnt = 1 ) AND Empty2 = '0' THEN
                Skipping <= '1';
              ELSE
                Skipping <= '0';
                IF NCcnt = 0 THEN
                  NCcnt <= NC;
                ELSE
                  NCcnt <= NCcnt - 1;
                END IF;
              END IF;
            END IF;
          WHEN Triggered =>
            IF Skipping = '1' THEN
              NSkip <= NSkip + 1;
            ELSE
              CntEn_cld <= '1';
              if first_row_cld = '0' then
                RE1_cld <= '1';
              end if;
              if NA = 0 AND NB = 0 then
                if NCcnt = 0 then
                  WE2_cld <= '1';
                else
                  WE1_cld <= '1';
                end if;
              end if;
            END IF;
            NBcnt <= NB;
            NAcnt <= NA;
            NArd <= '1';
          WHEN Scanning =>
            TrigClr_cld <= '1';
            TrigArm_cld <= '0';
            NArd <= '0';
            if Empty2 = '1' then
              DRdy_cld <= '0';
            end if;
            if NAcnt = 0 then -- last sample in a bin
              NAcnt <= NA;
              NArd <= '1';
              first_col_cld <= '1';
              if Skipping = '0' then
                if first_row_cld = '0' then
                  RE1_cld <= '1';
                end if;
                if NCcnt = 0 then
                  WE2_cld <= '1';
                else
                  WE1_cld <= '1';
                end if;
              end if;
              if NBcnt = 0 then -- last sample in a trigger
                NBcnt <= NB;
                CntEn_cld <= '0';
                RE1_cld <= '0';
                if NCcnt = 0 AND Skipping = '0' then -- last sample in a report
                  -- NCcnt <= NC;
                  DRdy_cld <= '1';
                  NSkipped <= NSkip;
                  first_row_cld <= '1';
                else
                  if Skipping = '0' then
                    first_row_cld <= '0';
                  end if;
                end if;
              else
                NBcnt <= NBcnt - 1;
              end if;
            else
              NAcnt <= NAcnt - 1;
              first_col_cld <= '0';
              WE1_cld <= '0';
              WE2_cld <= '0';
              RE1_cld <= '0';
            end if;
          WHEN OTHERS =>
            NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS clocked_proc;

  -----------------------------------------------------------------
   nextstate_proc : PROCESS ( 
      En,
      TrigSeen, Empty1,
      NAcnt, NBcnt, NCcnt,
      current_state, Skipping
   )
   -----------------------------------------------------------------
  BEGIN
    CASE current_state IS
      WHEN Startup => 
        IF (En = '1' AND Empty1 = '1') THEN 
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
        if En /= '1' then
          next_state <= Startup;
        elsif NAcnt = 0 AND NBcnt = 0 then
          IF NCcnt = 0 AND Skipping = '0' THEN
            next_state <= ReportArmed;
--          ELSIF NCcnt = 1 AND Empty2 = '0' THEN
--            next_state <= TriggerDelayed;
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
  
  DRdy_qual : PROCESS (clk) IS
  BEGIN
    IF clk'Event AND clk = '1' THEN
      IF DRdy_cld = '1' AND Empty2 = '0' THEN
        DRdy <= '1';
      ELSE
        DRdy <= '0';
      END IF;
    END IF;
  END PROCESS DRdy_qual;
 
  -- Concurrent Statements
  -- Clocked output assignments
  first_row <= first_row_cld;
  first_col <= first_col_cld;
  CntEn <= CntEn_cld;
  WE1 <= WE1_cld;
  WE2 <= WE2_cld;
  RE1 <= RE1_cld;
  TrigClr <= TrigClr_cld;
  TrigOE <= TrigOE_cld;
  TrigArm <= TrigArm_cld;
END ARCHITECTURE fsm;

