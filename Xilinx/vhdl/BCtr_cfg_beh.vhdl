--
-- VHDL Architecture BCtr_lib.BCtr_cfg.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:41:41 01/10/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_cfg IS
   GENERIC( 
      FIFO_ADDR_WIDTH : integer range 10 downto 4 := 9
   );
   PORT( 
      CfgAddr  : IN     unsigned (3 DOWNTO 0);
      ExpReset : IN     std_logic;
      NArd     : IN     std_logic;
      RdEn     : IN     std_logic;
      TrigArm  : IN     std_logic;
      WData    : IN     std_logic_vector (15 DOWNTO 0);
      WrEn     : IN     std_logic;
      clk      : IN     std_logic;
      CData    : OUT    std_logic_vector (15 DOWNTO 0);
      En       : OUT    std_logic;
      NA       : OUT    unsigned (15 DOWNTO 0);
      NBtot    : OUT    unsigned (FIFO_ADDR_WIDTH-1 DOWNTO 0);
      NC       : OUT    unsigned (23 DOWNTO 0);
      rst      : OUT    std_logic;
      Status   : OUT    std_logic_vector (2 DOWNTO 0)
   );

-- Declarations

END BCtr_cfg ;

--
ARCHITECTURE beh OF BCtr_cfg IS
  TYPE State_t IS (
    S_INIT, S_CHK_NAB, S_CHK_NAB2, S_CHK_NC,
    S_RESET, S_RESET2,
    S_EN
  );
  SIGNAL current_state : State_t;
  TYPE NA_t IS ARRAY (3 DOWNTO 0) OF UNSIGNED(15 DOWNTO 0);
  TYPE NB_t IS ARRAY (3 DOWNTO 0) OF UNSIGNED(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NAv : NA_t;
  SIGNAL NBv : NB_t;
  SIGNAL NBtotal : UNSIGNED(FIFO_ADDR_WIDTH DOWNTO 0);
  SIGNAL NBcnt   : UNSIGNED(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL NC_int : unsigned(23 DOWNTO 0);
  SIGNAL NC_out : unsigned(23 DOWNTO 0);
  SIGNAL IntReset : std_logic;
  SIGNAL N_NAB : integer range 4 DOWNTO 0;
  SIGNAL NAB : integer range 4 DOWNTO 0;
  SIGNAL Ready : std_logic;
  SIGNAL En_int : std_logic;
  SIGNAL config_err_nab : std_logic;
  SIGNAL config_err_ovf : std_logic;
    SIGNAL tr_offset : unsigned(3 DOWNTO 0);
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
    PROCEDURE ResetRegs IS
    BEGIN
      for i in 3 downto 0 loop
        NAv(i) <= (others => '0');
        NBv(i) <= (others => '0');
      end loop;
      NA <= (others => '0');
      NBtotal <= (others => '0');
      NBtot <= (others => '0');
      NC_int <= (others => '0');
      En_int <= '0';
      N_NAB <= 0;
      NAB <= 0;
      Ready <= '0';
      config_err_nab <= '0';
      config_err_ovf <= '0';
      return;
    END PROCEDURE ResetRegs;
    
    VARIABLE offset : unsigned(3 DOWNTO 0);
    VARIABLE index : integer range 3 downto 0;
    VARIABLE index4 : integer range 4 downto 0;
    VARIABLE NBtotal1 : unsigned(FIFO_ADDR_WIDTH DOWNTO 0);
    VARIABLE N_NABv : integer range 4 DOWNTO 0;
  BEGIN
    IF (clk'event AND clk = '1') THEN
      IF (ExpReset = '1') THEN
        IntReset <= '0';
        ResetRegs;
        current_state <= S_INIT;
      ELSE
        CASE current_state IS
        WHEN S_INIT =>
          IntReset <= '0';
          En_int <= '0';
          IF (CfgAddr = "0000") THEN
            IF (WrEn = '1') THEN
              IF (WData(15) = '1') THEN
                current_state <= S_RESET;
              ELSIF (WData(0) = '1' AND Ready = '1') THEN
                current_state <= S_EN;
              ELSE
                current_state <= S_INIT;
              END IF;
            ELSE
              current_state <= S_INIT;
            END IF;
          ELSIF (CfgAddr >= 3 AND CfgAddr <= 10) THEN
            offset := CfgAddr - 3;
            index := to_integer(offset(2 downto 1));
            index4 := to_integer(to_unsigned(index,3));
            tr_offset <= offset;
            tr_index <= index;
            tr_index4 <= index4;
            IF (WrEn = '1') THEN
              IF (index4 = N_NAB) THEN
                IF (offset(0) = '0') THEN -- NA
                  NAv(index) <= unsigned(WData);
                ELSE -- NB
                  NBv(index) <= unsigned(WData(FIFO_ADDR_WIDTH-1 DOWNTO 0));
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
          ELSIF (CfgAddr = 11) THEN
            IF (WrEn = '1') THEN
              NC_int(15 DOWNTO 0) <= unsigned(WData);
              current_state <= S_CHK_NC;
            ELSIF (RdEn = '1') THEN
              CData <= std_logic_vector(NC_int(15 DOWNTO 0));
              current_state <= S_INIT;
            END IF;
          ELSIF (CfgAddr = 12) THEN
            IF (WrEn = '1') THEN
              NC_int(23 DOWNTO 16) <= unsigned(WData(23-16 DOWNTO 0));
              current_state <= S_CHK_NC;
            ELSIF (RdEn = '1') THEN
              CData(15 DOWNTO 24-16) <= (others => '0');
              CData(23-16 DOWNTO 0) <= std_logic_vector(NC_int(23 DOWNTO 16));
              current_state <= S_INIT;
            END IF;
          END IF;
        WHEN S_CHK_NAB =>
          -- Check for legality
          IF (NAB < 4) THEN
            index := to_integer(to_unsigned(NAB,2));
            IF (N_NAB < 4 AND config_err_ovf = '0' AND
                NAv(index) /= 0 AND NBv(index) /= 0) THEN
              NBtotal <= NBtotal + resize(NBv(index),FIFO_ADDR_WIDTH+1);
              current_state <= S_CHK_NAB2;
            ELSE
              current_state <= S_INIT;
            END IF;
          ELSE
            current_state <= S_INIT;
          END IF;
        WHEN S_CHK_NAB2 =>
          IF (NBtotal <= 2**FIFO_ADDR_WIDTH) THEN
            N_NABv := NAB+1;
            N_NAB <= N_NABv;
            IF (N_NABv < 4) THEN
              NAB <= N_NABv;
            END IF;
            NBtotal1 := NBtotal-1;
            NBtot <= NBtotal1(FIFO_ADDR_WIDTH-1 DOWNTO 0);
            IF (NC_int > 0) THEN
              Ready <= '0';
            ELSE
              Ready <= '1';
            END IF;
          ELSE
            config_err_ovf <= '1';
            Ready <= '0';
          END IF;
          current_state <= S_INIT;
        WHEN S_CHK_NC =>
          IF (NC_int > 0 AND NBtotal > 0 AND config_err_ovf = '0') THEN
            NC_out <= NC_int-1;
            Ready <= '1';
          ELSE
            Ready <= '0';
          END IF;
          current_state <= S_INIT;
        WHEN S_EN =>
          En_int <= '1';
          IF (WrEn = '1' AND CfgAddr = "0000" AND
              WData(15) = '1') THEN
            current_state <= S_RESET;
          ELSIF (WrEn = '1' AND CfgAddr = "0000" AND
              WData(15) = '0' AND WData(0) = '0') THEN
            current_state <= S_INIT;
          ELSE
            current_state <= S_EN;
          END IF;
          
          IF (TrigArm = '1') THEN
            NAB <= 1;
            NA <= NAv(0)-1;
            NBcnt <= NBv(0)-1;
          ELSIF (NArd = '1') THEN
            IF (NBcnt = 0) THEN
              IF (NAB = N_NAB OR NAB >= 4) THEN
                NA <= (others => '0');
              ELSE
                index := to_integer(to_unsigned(NAB,2));
                NA <= NAv(index)-1;
                NBcnt <= NBv(index)-1;
                NAB <= NAB+1;
              END IF;
            ELSE
              NBcnt <= NBcnt - 1;
            END IF;
          END IF;
        WHEN S_RESET =>
          IntReset <= '1';
          ResetRegs;
          current_state <= S_RESET2;
        WHEN S_RESET2 =>
          current_state <= S_INIT;
        WHEN OTHERS =>
          current_state <= S_RESET;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
  
  En <= En_int;
  NC <= NC_out;
  Status <= Ready & config_err_nab & config_err_ovf;
END ARCHITECTURE beh;

