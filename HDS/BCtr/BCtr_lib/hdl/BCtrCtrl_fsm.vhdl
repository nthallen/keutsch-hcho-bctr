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
USE ieee.std_logic_unsigned.all;

ENTITY BCtrCtrl IS
  GENERIC (
    FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
  );
  PORT( 
    Empty1    : IN     std_logic;
    Empty2    : IN     std_logic;
    En        : IN     std_logic;
    Full1     : IN     std_logic;
    NA        : IN     std_logic_vector (15 DOWNTO 0);
    NC        : IN     std_logic_vector (15 DOWNTO 0);
    NB        : IN     std_logic_vector (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    TrigSeen  : IN     std_logic;
    clk       : IN     std_logic;
    rst       : IN     std_logic;
    CntEn     : OUT    std_logic;
    DRdy      : OUT    std_logic;
    PMT_clr   : OUT    std_logic;
    RE1       : OUT    std_logic;
    TrigArm   : OUT    std_logic;
    TrigClr   : OUT    std_logic;
    TrigOE    : OUT    std_logic;
    WE1       : OUT    std_logic;
    WE2       : OUT    std_logic;
    first_col : OUT    std_logic;
    first_row : OUT    std_logic
);

-- Declarations

END BCtrCtrl ;

--
ARCHITECTURE fsm OF BCtrCtrl IS

   TYPE STATE_TYPE IS (
      Startup,
      ReportArmed,
      TriggerArmed,
      Scanning
   );
 
   -- Declare current and next state signals
   SIGNAL current_state : STATE_TYPE;
   SIGNAL next_state : STATE_TYPE;

   SIGNAL NBcnt : std_logic_vector (FIFO_ADDR_WIDTH-1 DOWNTO 0);
   SIGNAL NCcnt : std_logic_vector (15 DOWNTO 0);
   SIGNAL NAcnt : std_logic_vector (15 DOWNTO 0);

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
        PMT_clr <= '1';
        RE1_cld <= '0';
        DRdy_cld <= '0';
        TrigClr_cld <= '0';
        TrigOE_cld <= '1';
        TrigArm_cld <= '0';
        NAcnt <= (others => '0');
        NBcnt <= (others => '0');
        NCcnt <= (others => '0');
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
            PMT_clr <= '1';
            RE1_cld <= '0';
            TrigClr_cld <= '1';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
          WHEN ReportArmed => 
            first_row_cld <= '1';
            CntEn_cld <= '0';
            WE1_cld <= '0';
            WE2_cld <= '0';
            RE1_cld <= '0';
            NCcnt <= NC;
            TrigClr_cld <= '0';
            TrigOE_cld <= '1';
            TrigArm_cld <= '0';
          WHEN TriggerArmed =>
            first_col_cld <= '1';
            CntEn_cld <= '0';
            WE1_cld <= '0';
            WE2_cld <= '0';
            RE1_cld <= '0';
            PMT_clr <= '1';
            TrigClr_cld <= '0';
            TrigArm_cld <= '1';
            if En = '1' AND TrigSeen = '1' then
              PMT_clr <= '0';
              CntEn_cld <= '1';
              NBcnt <= NB;
              NAcnt <= NA;
              if NA = 0 AND NB = 0 then
                if NCcnt = 0 then
                  WE2_cld <= '1';
                else
                  WE1_cld <= '1';
                end if;
              end if;
            end if;
          WHEN Scanning =>
            TrigClr_cld <= '1';
            TrigArm_cld <= '0';
            if NAcnt = 0 then -- last sample in a bin
              NAcnt <= NA;
              first_col_cld <= '1';
              if NCcnt = 0 then
                WE2_cld <= '1';
              else
                WE1_cld <= '1';
              end if;
              if NBcnt = 0 then -- last sample in a trigger
                NBcnt <= NB;
                if NCcnt = 0 then -- last sample in a report
                  NCcnt <= NC;
                  DRdy_cld <= '1';
                  first_row_cld <= '1';
                  CntEn_cld <= '0';
                else
                  NCcnt <= NCcnt - 1;
                  first_row_cld <= '0';
                end if;
              else
                NBcnt <= NBcnt - 1;
              end if;
            else
              NAcnt <= NAcnt - 1;
              first_col_cld <= '0';
              WE1_cld <= '0';
              WE2_cld <= '0';
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
      TrigSeen,
      NAcnt, NBcnt, NCcnt,
      current_state
   )
   -----------------------------------------------------------------
  BEGIN
    CASE current_state IS
      WHEN Startup => 
        IF (En = '1') THEN 
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
          next_state <= Scanning;
        ELSE
          next_state <= TriggerArmed;
        END IF;
      WHEN Scanning =>
        if En /= '1' then
          next_state <= Startup;
        elsif NAcnt = 0 AND NBcnt = 0 then
          if NCcnt = 0 then
            next_state <= ReportArmed;
          else
            next_state <= TriggerArmed;
          end if;
        else
          next_state <= Scanning;
        end if;
      WHEN OTHERS =>
        next_state <= Startup;
    END CASE;
  END PROCESS nextstate_proc;
 
  -- Concurrent Statements
  -- Clocked output assignments
  first_row <= first_row_cld;
  first_col <= first_col_cld;
  CntEn <= CntEn_cld;
  WE1 <= WE1_cld;
  WE2 <= WE2_cld;
  RE1 <= RE1_cld;
  DRdy <= DRdy_cld;
  TrigClr <= TrigClr_cld;
  TrigOE <= TrigOE_cld;
  TrigArm <= TrigArm_cld;
END ARCHITECTURE fsm;

