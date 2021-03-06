-- VHDL Entity BCtr_lib.temp_i2c_mid.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 11:09:43 02/ 4/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY temp_i2c_mid IS
  GENERIC( 
    I2C_CLK_PRESCALE : std_logic_vector(15 DOWNTO 0) := X"00BC"
  );
  PORT( 
    adc_addr  : IN     std_logic_vector (6 DOWNTO 0);
    clk       : IN     std_logic;
    rd_cmd    : IN     std_logic;
    rst       : IN     std_logic;
    wb_ack_o  : IN     std_logic;
    wb_dat_o  : IN     std_logic_vector (7 DOWNTO 0);
    wb_inta_o : IN     std_logic;
    wr_cmd    : IN     std_logic;
    wr_data   : IN     std_logic_vector (7 DOWNTO 0);
    arst_i    : OUT    std_logic;
    done      : OUT    std_logic;
    err       : OUT    std_logic;
    rd_data   : OUT    std_logic_vector (31 DOWNTO 0);
    wb_adr_i  : OUT    std_logic_vector (2 DOWNTO 0);
    wb_cyc_i  : OUT    std_logic;
    wb_dat_i  : OUT    std_logic_vector (7 DOWNTO 0);
    wb_stb_i  : OUT    std_logic;
    wb_we_i   : OUT    std_logic
  );

-- Declarations

END ENTITY temp_i2c_mid ;

--
-- VHDL Architecture BCtr_lib.temp_i2c_mid.fsm
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 13:31:31 02/ 8/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
--  Machine             :  "csm", synchronous
--  Encoding            :  none
--  Style               :  case, 3 processes
--  Clock               :  "clk", rising 
--  Synchronous Reset   :  "rst", synchronous, active high
--  State variable type :  [auto]
--  Default state assignment disabled
--  State actions registered on current state
--  
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
 
ARCHITECTURE fsm OF temp_i2c_mid IS

  -- Architecture Declarations
  SIGNAL TimedOut : std_logic;  
  SIGNAL WrStop_int : std_logic;  

  TYPE STATE_TYPE IS (
    i2cim_0,
    i2c_wait,
    i2cim_1,
    i2cim_2,
    i2cim_3,
    i2cim_4,
    i2cim_5,
    i2cim_6,
    i2cim_7,
    i2cim_8,
    i2cim_9,
    i2c_cmd,
    i2c_wr0,
    i2c_err,
    i2c_r1,
    i2c_wrz,
    i2c_wr1,
    i2c_wr2,
    i2c_wr3,
    i2c_wr4,
    i2c_wr5,
    i2c_wr8,
    i2c_wr18,
    i2c_wr19,
    i2c_wr20,
    i2c_wr21,
    i2c_wr7,
    i2c_wr9,
    i2c_wr10,
    i2c_wr11,
    i2c_wr12,
    i2c_wr13,
    i2c_wr14,
    i2c_wr15,
    i2c_wr16,
    i2c_r2,
    i2c_r3,
    i2c_r4,
    i2c_r5,
    i2c_r6,
    i2c_r7,
    i2c_r8,
    i2c_r9,
    i2c_r10,
    i2c_r11,
    i2c_r12,
    i2c_r13,
    i2c_r14,
    i2c_r15,
    i2c_r16,
    i2c_r17,
    i2c_r18,
    i2c_r19,
    i2c_r20,
    i2c_r21,
    i2c_r22,
    i2c_r23,
    i2c_r24,
    i2c_r25,
    i2c_r26,
    i2c_r27,
    i2c_r28,
    i2c_to1,
    i2c_to2,
    i2c_to3,
    i2c_to4,
    s0,
    i2cim_0a
  );
 
  -- Declare current and next state signals
  SIGNAL current_state : STATE_TYPE;
  SIGNAL next_state : STATE_TYPE;

  -- Declare Wait State internal signals
  SIGNAL csm_timer : std_logic_vector(14 DOWNTO 0);
  SIGNAL csm_next_timer : std_logic_vector(14 DOWNTO 0);
  SIGNAL csm_timeout : std_logic;
  SIGNAL csm_to_i2c_wr4 : std_logic;
  SIGNAL csm_to_i2c_wr21 : std_logic;
  SIGNAL csm_to_i2c_wr14 : std_logic;
  SIGNAL csm_to_i2c_r5 : std_logic;
  SIGNAL csm_to_i2c_r11 : std_logic;
  SIGNAL csm_to_i2c_r16 : std_logic;
  SIGNAL csm_to_i2c_r21 : std_logic;
  SIGNAL csm_to_i2c_r26 : std_logic;
  SIGNAL csm_to_i2c_to4 : std_logic;

  -- Declare any pre-registered internal signals
  SIGNAL arst_i_cld : std_logic ;
  SIGNAL done_cld : std_logic ;
  SIGNAL err_cld : std_logic ;
  SIGNAL rd_data_cld : std_logic_vector (31 DOWNTO 0);
  SIGNAL wb_adr_i_cld : std_logic_vector (2 DOWNTO 0);
  SIGNAL wb_cyc_i_cld : std_logic ;
  SIGNAL wb_dat_i_cld : std_logic_vector (7 DOWNTO 0);
  SIGNAL wb_stb_i_cld : std_logic ;
  SIGNAL wb_we_i_cld : std_logic ;

BEGIN

  -----------------------------------------------------------------
  clocked_proc : PROCESS ( 
    clk
  )
  -----------------------------------------------------------------
  BEGIN
    IF (clk'EVENT AND clk = '1') THEN
      IF (rst = '1') THEN
        current_state <= i2cim_0;
        csm_timer <= (OTHERS => '0');
        -- Default Reset Values
        arst_i_cld <= '1';
        done_cld <= '0';
        err_cld <= '0';
        rd_data_cld <= (others => '0');
        wb_adr_i_cld <= (others => '0');
        wb_cyc_i_cld <= '0';
        wb_dat_i_cld <= (others => '0');
        wb_stb_i_cld <= '0';
        wb_we_i_cld <= '0';
        TimedOut <= '0';
        WrStop_int <= '0';
      ELSE
        current_state <= next_state;
        csm_timer <= csm_next_timer;

        -- Combined Actions
        CASE current_state IS
          WHEN i2cim_0 => 
            done_cld <= '0';
            err_cld <= '0';
            TimedOut <= '0';
            arst_i_cld <= '1';
          WHEN i2cim_1 => 
            wb_adr_i_cld <= "000";
            wb_dat_i_cld <= 
              I2C_CLK_PRESCALE(7 DOWNTO 0);
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2cim_2 => 
            IF (wb_ack_o = '1') THEN 
              wb_cyc_i_cld <= '0';
              wb_stb_i_cld <= '0';
            END IF;
          WHEN i2cim_4 => 
            wb_adr_i_cld <= "001";
            wb_dat_i_cld <= 
              I2C_CLK_PRESCALE(15 DOWNTO 8);
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2cim_5 => 
            IF (wb_ack_o = '1') THEN 
              wb_cyc_i_cld <= '0';
              wb_stb_i_cld <= '0';
            END IF;
          WHEN i2cim_7 => 
            wb_adr_i_cld <= "010";
            wb_dat_i_cld <= X"C0";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2cim_8 => 
            IF (wb_ack_o = '1') THEN 
              wb_cyc_i_cld <= '0';
              wb_stb_i_cld <= '0';
            END IF;
          WHEN i2c_cmd => 
            err_cld <= '0';
            done_cld <= '0';
          WHEN i2c_wr0 => 
            wb_adr_i_cld <= "011";
            wb_dat_i_cld <= adc_addr & '0';
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_err => 
            err_cld <= '1';
          WHEN i2c_r1 => 
            wb_adr_i_cld <= "011";
            wb_dat_i_cld <= adc_addr & '1';
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wrz => 
            done_cld <= '1';
          WHEN i2c_wr1 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr2 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= "10010001";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_Stb_i_cld <= '1';
          WHEN i2c_wr3 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr5 => 
            wb_adr_i_cld <= "100";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wr8 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld  <= '0';
          WHEN i2c_wr18 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr19 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= "01000001";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wr20 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr7 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            err_cld <= '1';
          WHEN i2c_wr9 => 
            wb_adr_i_cld <= "011";
            wb_dat_i_cld <= wr_data;
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wr10 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr11 => 
            WrStop_int <= '1';
          WHEN i2c_wr12 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= '0'
            & WrStop_int
            & "010001";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wr13 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_wr15 => 
            wb_adr_i_cld <= "100";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_wr16 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r2 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r3 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= X"91";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r4 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r6 => 
            wb_adr_i_cld <= "100";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r7 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            err_cld <= '1';
          WHEN i2c_r8 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r9 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= X"21";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r10 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r12 => 
            wb_adr_i_cld <= "011";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <='1';
          WHEN i2c_r13 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            rd_data_cld(31 DOWNTO 24)
            <= wb_dat_o;
          WHEN i2c_r14 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= X"21";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r15 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r17 => 
            wb_adr_i_cld <= "011";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <='1';
          WHEN i2c_r18 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            rd_data_cld(23 DOWNTO 16)
            <= wb_dat_o;
          WHEN i2c_r19 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= X"21";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r20 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r22 => 
            wb_adr_i_cld <= "011";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <='1';
          WHEN i2c_r23 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            rd_data_cld(15 DOWNTO 8)
            <= wb_dat_o;
          WHEN i2c_r24 => 
            wb_adr_i_cld <= "100";
            wb_dat_i_cld <= X"69";
            wb_we_i_cld <= '1';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <= '1';
          WHEN i2c_r25 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
          WHEN i2c_r27 => 
            wb_adr_i_cld <= "011";
            wb_we_i_cld <= '0';
            wb_cyc_i_cld <= '1';
            wb_stb_i_cld <='1';
          WHEN i2c_r28 => 
            wb_cyc_i_cld <= '0';
            wb_stb_i_cld <= '0';
            rd_data_cld(7 DOWNTO 0)
            <= wb_dat_o;
          WHEN i2c_to1 => 
            err_cld <='1';
          WHEN i2c_to2 => 
            err_cld <= '0';
            done_cld <= '0';
          WHEN i2c_to3 => 
            TimedOut <= '0';
          WHEN i2cim_0a => 
            arst_i_cld <= '0';
          WHEN OTHERS =>
            NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS clocked_proc;
 
  -----------------------------------------------------------------
  nextstate_proc : PROCESS ( 
    TimedOut,
    csm_timeout,
    current_state,
    err_cld,
    rd_cmd,
    wb_ack_o,
    wb_dat_o,
    wb_inta_o,
    wr_cmd
  )
  -----------------------------------------------------------------
  BEGIN
    -- Default assignments to Wait State entry flags
    csm_to_i2c_wr4 <= '0';
    csm_to_i2c_wr21 <= '0';
    csm_to_i2c_wr14 <= '0';
    csm_to_i2c_r5 <= '0';
    csm_to_i2c_r11 <= '0';
    csm_to_i2c_r16 <= '0';
    csm_to_i2c_r21 <= '0';
    csm_to_i2c_r26 <= '0';
    csm_to_i2c_to4 <= '0';
    CASE current_state IS
      WHEN i2cim_0 => 
        next_state <= i2cim_0a;
      WHEN i2c_wait => 
        IF (wr_cmd = '0' AND rd_cmd = '0') THEN 
          next_state <= i2c_cmd;
        ELSE
          next_state <= i2c_wait;
        END IF;
      WHEN i2cim_1 => 
        next_state <= i2cim_2;
      WHEN i2cim_2 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2cim_3;
        ELSE
          next_state <= i2cim_2;
        END IF;
      WHEN i2cim_3 => 
        next_state <= i2cim_4;
      WHEN i2cim_4 => 
        next_state <= i2cim_5;
      WHEN i2cim_5 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2cim_6;
        ELSE
          next_state <= i2cim_5;
        END IF;
      WHEN i2cim_6 => 
        next_state <= i2cim_7;
      WHEN i2cim_7 => 
        next_state <= i2cim_8;
      WHEN i2cim_8 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2cim_9;
        ELSE
          next_state <= i2cim_8;
        END IF;
      WHEN i2cim_9 => 
        next_state <= i2c_cmd;
      WHEN i2c_cmd => 
        IF (wr_cmd = '1' AND rd_cmd = '0') THEN 
          next_state <= i2c_wr0;
        ELSIF (wr_cmd = '0' AND rd_cmd = '0') THEN 
          next_state <= i2c_cmd;
        ELSIF (wr_cmd = '0' AND rd_cmd = '1') THEN 
          next_state <= i2c_r1;
        ELSE
          next_state <= i2c_err;
        END IF;
      WHEN i2c_wr0 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_wr1;
        ELSE
          next_state <= i2c_wr0;
        END IF;
      WHEN i2c_err => 
        next_state <= i2c_wait;
      WHEN i2c_r1 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r2;
        ELSE
          next_state <= i2c_r1;
        END IF;
      WHEN i2c_wrz => 
        next_state <= i2c_wait;
      WHEN i2c_wr1 => 
        IF (wb_ack_o = '0') THEN 
          next_state <= i2c_wr2;
        ELSE
          next_state <= i2c_wr1;
        END IF;
      WHEN i2c_wr2 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_wr3;
        ELSE
          next_state <= i2c_wr2;
        END IF;
      WHEN i2c_wr3 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_wr4;
          csm_to_i2c_wr4 <= '1';
        ELSE
          next_state <= i2c_wr3;
        END IF;
      WHEN i2c_wr4 => 
        IF (wb_inta_o = '1') THEN 
          next_state <= i2c_wr5;
        ELSIF (csm_timeout = '1') THEN 
          next_state <= i2c_wr7;
        ELSE
          next_state <= i2c_wr4;
        END IF;
      WHEN i2c_wr5 => 
        IF (wb_ack_o = '1'
            AND
            wb_dat_o(7) /= '0') THEN 
          next_state <= i2c_wr18;
        ELSIF (wb_ack_o = '1'
               AND
               wb_dat_o(7) = '0') THEN 
          next_state <= i2c_wr8;
        ELSE
          next_state <= i2c_wr5;
        END IF;
      WHEN i2c_wr8 => 
        IF (wb_ack_o =  '0') THEN 
          next_state <= i2c_wr9;
        ELSE
          next_state <= i2c_wr8;
        END IF;
      WHEN i2c_wr18 => 
        IF (wb_ack_o = '0') THEN 
          next_state <= i2c_wr19;
        ELSE
          next_state <= i2c_wr18;
        END IF;
      WHEN i2c_wr19 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_wr20;
        ELSE
          next_state <= i2c_wr19;
        END IF;
      WHEN i2c_wr20 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_wr21;
          csm_to_i2c_wr21 <= '1';
        ELSE
          next_state <= i2c_wr20;
        END IF;
      WHEN i2c_wr21 => 
        IF (wb_inta_o = '1') THEN 
          next_state <= i2c_wr7;
        ELSIF (csm_timeout = '1') THEN 
          next_state <= i2c_wr7;
        ELSE
          next_state <= i2c_wr21;
        END IF;
      WHEN i2c_wr7 => 
        IF (err_cld = '1'
            AND
            TimedOut = '1') THEN 
          next_state <= i2c_to1;
        ELSIF (err_cld = '1') THEN 
          next_state <= i2c_wait;
        ELSIF (wr_cmd = '1') THEN 
          next_state <= i2c_wrz;
        ELSE
          next_state <= i2c_err;
        END IF;
      WHEN i2c_wr9 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_wr10;
        ELSE
          next_state <= i2c_wr9;
        END IF;
      WHEN i2c_wr10 => 
        IF (wr_cmd = '1') THEN 
          next_state <= i2c_wr11;
        ELSE
          next_state <= i2c_wr10;
        END IF;
      WHEN i2c_wr11 => 
        next_state <= i2c_wr12;
      WHEN i2c_wr12 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_wr13;
        ELSE
          next_state <= i2c_wr12;
        END IF;
      WHEN i2c_wr13 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_wr14;
          csm_to_i2c_wr14 <= '1';
        ELSE
          next_state <= i2c_wr13;
        END IF;
      WHEN i2c_wr14 => 
        IF (wb_inta_o ='1') THEN 
          next_state <= i2c_wr15;
        ELSIF (csm_timeout = '1') THEN 
          next_state <= i2c_wr7;
        ELSE
          next_state <= i2c_wr14;
        END IF;
      WHEN i2c_wr15 => 
        IF (wb_ack_o = '1' 
            AND
            wb_dat_o(7) /= '0') THEN 
          next_state <= i2c_wr7;
        ELSIF (wb_ack_o = '1'
               AND
               wb_dat_o(7) = '0') THEN 
          next_state <= i2c_wr16;
        ELSE
          next_state <= i2c_wr15;
        END IF;
      WHEN i2c_wr16 => 
        IF (err_cld = '1'
            AND
            TimedOut = '1') THEN 
          next_state <= i2c_to1;
        ELSIF (err_cld = '1') THEN 
          next_state <= i2c_wait;
        ELSIF (wr_cmd = '1') THEN 
          next_state <= i2c_wrz;
        ELSE
          next_state <= i2c_err;
        END IF;
      WHEN i2c_r2 => 
        IF (wb_ack_o = '0') THEN 
          next_state <= i2c_r3;
        ELSE
          next_state <= i2c_r2;
        END IF;
      WHEN i2c_r3 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r4;
        ELSE
          next_state <= i2c_r3;
        END IF;
      WHEN i2c_r4 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o ='0') THEN 
          next_state <= i2c_r5;
          csm_to_i2c_r5 <= '1';
        ELSE
          next_state <= i2c_r4;
        END IF;
      WHEN i2c_r5 => 
        IF (wb_inta_o = '1') THEN 
          next_state <= i2c_r6;
        ELSIF (csm_timeout = '1') THEN 
          next_state <= i2c_r7;
        ELSE
          next_state <= i2c_r5;
        END IF;
      WHEN i2c_r6 => 
        IF (wb_ack_o ='1'
            AND
            wb_dat_o(7) /=  '0') THEN 
          next_state <= i2c_r7;
        ELSIF (wb_ack_o = '1'
               AND
               wb_dat_o(7) = '0') THEN 
          next_state <= i2c_r8;
        ELSE
          next_state <= i2c_r6;
        END IF;
      WHEN i2c_r7 => 
        next_state <= s0;
      WHEN i2c_r8 => 
        next_state <= i2c_r9;
      WHEN i2c_r9 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r10;
        ELSE
          next_state <= i2c_r9;
        END IF;
      WHEN i2c_r10 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_r11;
          csm_to_i2c_r11 <= '1';
        ELSE
          next_state <= i2c_r10;
        END IF;
      WHEN i2c_r11 => 
        IF (csm_timeout = '1') THEN 
          next_state <= i2c_r7;
        ELSIF (wb_inta_o = '1') THEN 
          next_state <= i2c_r12;
        ELSE
          next_state <= i2c_r11;
        END IF;
      WHEN i2c_r12 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r13;
        ELSE
          next_state <= i2c_r12;
        END IF;
      WHEN i2c_r13 => 
        next_state <= i2c_r14;
      WHEN i2c_r14 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r15;
        ELSE
          next_state <= i2c_r14;
        END IF;
      WHEN i2c_r15 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_r16;
          csm_to_i2c_r16 <= '1';
        ELSE
          next_state <= i2c_r15;
        END IF;
      WHEN i2c_r16 => 
        IF (csm_timeout = '1') THEN 
          next_state <= i2c_r7;
        ELSIF (wb_inta_o = '1') THEN 
          next_state <= i2c_r17;
        ELSE
          next_state <= i2c_r16;
        END IF;
      WHEN i2c_r17 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r18;
        ELSE
          next_state <= i2c_r17;
        END IF;
      WHEN i2c_r18 => 
        next_state <= i2c_r19;
      WHEN i2c_r19 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r20;
        ELSE
          next_state <= i2c_r19;
        END IF;
      WHEN i2c_r20 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_r21;
          csm_to_i2c_r21 <= '1';
        ELSE
          next_state <= i2c_r20;
        END IF;
      WHEN i2c_r21 => 
        IF (csm_timeout = '1') THEN 
          next_state <= i2c_r7;
        ELSIF (wb_inta_o = '1') THEN 
          next_state <= i2c_r22;
        ELSE
          next_state <= i2c_r21;
        END IF;
      WHEN i2c_r22 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r23;
        ELSE
          next_state <= i2c_r22;
        END IF;
      WHEN i2c_r23 => 
        next_state <= i2c_r24;
      WHEN i2c_r24 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r25;
        ELSE
          next_state <= i2c_r24;
        END IF;
      WHEN i2c_r25 => 
        IF (wb_inta_o = '0'
            AND
            wb_ack_o = '0') THEN 
          next_state <= i2c_r26;
          csm_to_i2c_r26 <= '1';
        ELSE
          next_state <= i2c_r25;
        END IF;
      WHEN i2c_r26 => 
        IF (csm_timeout = '1') THEN 
          next_state <= i2c_r7;
        ELSIF (wb_inta_o = '1') THEN 
          next_state <= i2c_r27;
        ELSE
          next_state <= i2c_r26;
        END IF;
      WHEN i2c_r27 => 
        IF (wb_ack_o = '1') THEN 
          next_state <= i2c_r28;
        ELSE
          next_state <= i2c_r27;
        END IF;
      WHEN i2c_r28 => 
        IF (err_cld = '1'
            AND
            TimedOut = '1') THEN 
          next_state <= i2c_to1;
        ELSIF (err_cld ='1') THEN 
          next_state <= i2c_wait;
        ELSE
          next_state <= i2c_wrz;
        END IF;
      WHEN i2c_to1 => 
        IF (wr_cmd = '0'
            AND 
            rd_cmd = '0') THEN 
          next_state <= i2c_to2;
        ELSE
          next_state <= i2c_to1;
        END IF;
      WHEN i2c_to2 => 
        IF (wb_inta_o = '1') THEN 
          next_state <= i2c_to3;
        ELSIF (rd_cmd = '1'
               OR
               wr_cmd = '1') THEN 
          next_state <= i2c_to4;
          csm_to_i2c_to4 <= '1';
        ELSE
          next_state <= i2c_to2;
        END IF;
      WHEN i2c_to3 => 
        next_state <= i2c_cmd;
      WHEN i2c_to4 => 
        IF (wb_inta_o = '1') THEN 
          next_state <= i2c_to3;
        ELSIF (csm_timeout = '1') THEN 
          next_state <= i2c_to1;
        ELSE
          next_state <= i2c_to4;
        END IF;
      WHEN s0 => 
        IF (err_cld = '1'
            AND
            TimedOut = '1') THEN 
          next_state <= i2c_to1;
        ELSIF (err_cld ='1') THEN 
          next_state <= i2c_wait;
        ELSE
          next_state <= i2c_wrz;
        END IF;
      WHEN i2cim_0a => 
        next_state <= i2cim_1;
      WHEN OTHERS =>
        next_state <= i2cim_0;
    END CASE;
  END PROCESS nextstate_proc;
 
  -----------------------------------------------------------------
  csm_wait_combo_proc: PROCESS (
    csm_timer,
    csm_to_i2c_wr4,
    csm_to_i2c_wr21,
    csm_to_i2c_wr14,
    csm_to_i2c_r5,
    csm_to_i2c_r11,
    csm_to_i2c_r16,
    csm_to_i2c_r21,
    csm_to_i2c_r26,
    csm_to_i2c_to4
  )
  -----------------------------------------------------------------
  VARIABLE csm_temp_timeout : std_logic;
  BEGIN
    IF (unsigned(csm_timer) = 0) THEN
      csm_temp_timeout := '1';
    ELSE
      csm_temp_timeout := '0';
    END IF;

    IF (csm_to_i2c_wr4 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_wr21 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_wr14 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_r5 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_r11 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_r16 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_r21 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_r26 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSIF (csm_to_i2c_to4 = '1') THEN
      csm_next_timer <= "100111000011111"; -- no cycles(20000)-1=19999
    ELSE
      IF (csm_temp_timeout = '1') THEN
        csm_next_timer <= (OTHERS=>'0');
      ELSE
        csm_next_timer <= unsigned(csm_timer) - '1';
      END IF;
    END IF;
    csm_timeout <= csm_temp_timeout;
  END PROCESS csm_wait_combo_proc;

  -- Concurrent Statements
  -- Clocked output assignments
  arst_i <= arst_i_cld;
  done <= done_cld;
  err <= err_cld;
  rd_data <= rd_data_cld;
  wb_adr_i <= wb_adr_i_cld;
  wb_cyc_i <= wb_cyc_i_cld;
  wb_dat_i <= wb_dat_i_cld;
  wb_stb_i <= wb_stb_i_cld;
  wb_we_i <= wb_we_i_cld;
END ARCHITECTURE fsm;
