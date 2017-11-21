--
-- VHDL Architecture BCtr_lib.BCtr2_cfg.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:41:41 01/10/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
-- NOTES:
--   NBtot is actually the sum of NB parameters minus 1 for convenience in
--   the looping structures
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr2_cfg IS
  GENERIC( 
    FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
  );
  PORT( 
    CfgAddr   : IN     unsigned (3 DOWNTO 0);
    ExpReset  : IN     std_logic;
    WData     : IN     std_logic_vector (15 DOWNTO 0);
    clk       : IN     std_logic;
    CData     : OUT    std_logic_vector (15 DOWNTO 0);
    En        : OUT    std_logic;
    NA        : OUT    unsigned (15 DOWNTO 0);
    NBtot     : OUT    unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
    rst       : OUT    std_logic;
    WrEn      : IN     std_logic;
    RdEn      : IN     std_logic;
    NArd      : IN     std_logic;
    TrigArm   : IN     std_logic;
    CfgStatus : OUT    std_logic_vector (5 DOWNTO 0)
  );

-- Declarations

END ENTITY BCtr2_cfg ;

--
ARCHITECTURE beh OF BCtr2_cfg IS
  TYPE State_t IS (
    S_INIT, S_CHK_NAB, S_CHK_NAB2,
    S_RESET, S_RESET2,
    S_EN
  );
  SIGNAL current_state : State_t;
  TYPE NA_t IS ARRAY (3 DOWNTO 0) OF UNSIGNED(15 DOWNTO 0);
  TYPE NB_t IS ARRAY (3 DOWNTO 0) OF UNSIGNED(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NAv : NA_t;
  SIGNAL NBv : NB_t;
  SIGNAL NA_in : UNSIGNED(15 DOWNTO 0);
  SIGNAL NA_int : UNSIGNED(15 DOWNTO 0);
  SIGNAL NB_in : UNSIGNED(15 DOWNTO 0);
  SIGNAL NB_in1 : UNSIGNED(15 DOWNTO 0);
  SIGNAL NBtotal : UNSIGNED(FIFO_ADDR_WIDTH DOWNTO 0);
  SIGNAL NBcnt   : UNSIGNED(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL IntReset : std_logic;
  SIGNAL N_NAB : integer range 4 DOWNTO 0;
  SIGNAL NAB : integer range 4 DOWNTO 0;
  SIGNAL Ready : std_logic;
  SIGNAL En_int : std_logic;
  SIGNAL config_err_nab : std_logic;
  SIGNAL config_err_ovf : std_logic;
  SIGNAL config_reg_addr : std_logic;
  SIGNAL nab_regs_addr : std_logic;
  SIGNAL offset : unsigned(3 DOWNTO 0);
    SIGNAL tr_index : integer range 3 downto 0;
    SIGNAL tr_index4 : integer range 4 downto 0;
BEGIN
  PROCESS (clk) IS
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (ExpReset = '1' OR IntReset = '1') THEN
        rst <= '1';
      ELSE
        rst <= '0';
      END IF;
    END IF;
  END PROCESS;
  
  PROCESS (clk) IS
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (CfgAddr = "0000") THEN
        config_reg_addr <= '1';
      ELSE
        config_reg_addr <= '0';
      END IF;
      
      CASE CfgAddr IS
      WHEN "0011" =>
        nab_regs_addr <= '1';
      WHEN "0100" =>
        nab_regs_addr <= '1';
      WHEN "0101" =>
        nab_regs_addr <= '1';
      WHEN "0110" =>
        nab_regs_addr <= '1';
      WHEN "0111" =>
        nab_regs_addr <= '1';
      WHEN "1000" =>
        nab_regs_addr <= '1';
      WHEN "1001" =>
        nab_regs_addr <= '1';
      WHEN "1010" =>
        nab_regs_addr <= '1';
      WHEN OTHERS =>
        nab_regs_addr <= '0';
      END CASE;

      offset <= CfgAddr - 3;
    END IF;
  END PROCESS;
  
  PROCESS (clk) IS
    PROCEDURE ResetRegs IS
    BEGIN
      for i in 3 downto 0 loop
        NAv(i) <= (others => '0');
        NBv(i) <= (others => '0');
      end loop;
      NA_int <= (others => '0');
      NA_in <= (others => '0');
      NB_in <= (others => '0');
      NBtotal <= (others => '0');
      NBtot <= (others => '0');
      En_int <= '0';
      N_NAB <= 0;
      NAB <= 0;
      Ready <= '0';
      config_err_nab <= '0';
      config_err_ovf <= '0';
      return;
    END PROCEDURE ResetRegs;
    
    VARIABLE index : integer range 3 downto 0;
    VARIABLE index4 : integer range 4 downto 0;
    VARIABLE NBtotal1 : unsigned(FIFO_ADDR_WIDTH DOWNTO 0);
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (ExpReset = '1') THEN
        IntReset <= '0';
        ResetRegs;
        current_state <= S_INIT;
      ELSE
        
        IF (config_reg_addr = '1' AND WrEn = '1') THEN
          IntReset <= WData(15);
          En_int <= WData(0);
        END IF;
        
        CASE current_state IS
        WHEN S_INIT =>
          En <= '0';
          IF (IntReset = '1') THEN
            current_state <= S_RESET;
          ELSIF (En_int = '1' AND Ready = '1') THEN
            current_state <= S_EN;
          ELSE
            current_state <= S_INIT;
          END IF;
          IF (nab_regs_addr = '1') THEN
            index := to_integer(offset(2 downto 1));
            index4 := to_integer(to_unsigned(index,3));
            tr_index <= index;
            tr_index4 <= index4;
            IF (WrEn = '1') THEN
              IF (index4 = N_NAB) THEN
                IF (offset(0) = '0') THEN -- NA
                  NA_in <= unsigned(WData);
                ELSE
                  NB_in <= unsigned(WData);
                END IF;
                current_state <= S_CHK_NAB;
              ELSE
                config_err_nab <= '1';
                current_state <= S_INIT;
              END IF;
            ELSIF (RdEn = '1') THEN
              IF (offset(0) = '0') THEN -- NA
                CData <= std_logic_vector(NAv(index));
              ELSE -- NB
                CData(FIFO_ADDR_WIDTH-1 DOWNTO 0) <= std_logic_vector(NBv(index));
                CData(15 DOWNTO FIFO_ADDR_WIDTH) <= (others => '0');
              END IF;
              current_state <= S_INIT;
            END IF;
          END IF;
        WHEN S_CHK_NAB =>
          -- Check for legality
          index := to_integer(to_unsigned(N_NAB,2));
          IF (N_NAB < 4 AND
              NA_in /= 0 AND
              NB_in /= 0 AND
              NB_in(15 DOWNTO FIFO_ADDR_WIDTH+1) = 0 AND
              config_err_ovf = '0') THEN
            NBtotal <= NBtotal + resize(NB_in,FIFO_ADDR_WIDTH+1);
            NB_in1 <= NB_in - 1;
            current_state <= S_CHK_NAB2;
          ELSE
            current_state <= S_INIT;
          END IF;
        WHEN S_CHK_NAB2 =>
          IF (NBtotal <= 2**FIFO_ADDR_WIDTH) THEN
            index := to_integer(to_unsigned(N_NAB,2));
            NAv(index) <= NA_in-1;
            NBv(index) <= NB_in1(FIFO_ADDR_WIDTH-1 DOWNTO 0);
            N_NAB <= N_NAB+1;
            NBtotal1 := NBtotal-1;
            NBtot <= NBtotal1(FIFO_ADDR_WIDTH-1 DOWNTO 0);
            NA_in <= (others => '0');
            NB_in <= (others => '0');
            Ready <= '1';
          ELSE
            config_err_ovf <= '1';
            Ready <= '0';
          END IF;
          current_state <= S_INIT;
        WHEN S_EN =>
          En <= '1';
          IF (IntReset = '1') THEN
            current_state <= S_RESET;
          ELSIF (En_int = '0') THEN
            current_state <= S_INIT;
          ELSE
            current_state <= S_EN;
          END IF;
          
          IF (TrigArm = '1') THEN
            NAB <= 1;
            NA_int <= NAv(0);
            NBcnt <= NBv(0);
          ELSIF (NArd = '1') THEN
            IF (NBcnt = 0) THEN
              IF (NAB = N_NAB OR NAB >= 4) THEN
                NA_int <= (others => '0');
              ELSE
                index := to_integer(to_unsigned(NAB,2));
                NA_int <= NAv(index);
                NBcnt <= NBv(index);
                NAB <= NAB+1;
              END IF;
            ELSE
              NBcnt <= NBcnt - 1;
            END IF;
          END IF;
        WHEN S_RESET =>
          En <= '0';
          En_int <= '0';
          ResetRegs;
          current_state <= S_RESET2;
        WHEN S_RESET2 =>
          IntReset <= '0';
          current_state <= S_INIT;
        WHEN OTHERS =>
          current_state <= S_RESET;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
  
  -- This process seems to duplicate some of the computations above, but
  -- it is necessary to get the NA value out while NArd is asserted.
  PROCESS (current_state, TrigArm, NAv, NAB, N_NAB, NArd, NA_int, NBcnt) IS
    VARIABLE index : integer range 3 downto 0;
  BEGIN
    CASE current_state IS
    WHEN S_EN =>
      IF (TrigArm = '1') THEN
        NA <= NAv(0);
      ELSIF (NArd = '1' AND NBcnt = 0) THEN
        IF (NAB = N_NAB OR NAB >= 4) THEN
          NA <= (others => '0');
        ELSE
          index := to_integer(to_unsigned(NAB,2));
          NA <= NAv(index);
        END IF;
      ELSE
        NA <= NA_int;
      END IF;
    WHEN others =>
      NA <= (others => '0');
    END CASE;
  END PROCESS;
  
  CfgStatus <= std_logic_vector(to_unsigned(N_NAB,3)) & Ready & config_err_nab & config_err_ovf;
END ARCHITECTURE beh;

