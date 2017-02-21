--
-- VHDL Architecture PTR3_HVPS_lib.HVPS_acq.fsm
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 16:12:58 11/14/2016
--
-- HVPS_acq provides a state machine (or machines) to control
-- the HVPS interfaces. It must:
--   -Initialize and poll the HVPS ADCs and DACs, manipulating the
--    I2C Muxes as necessary.
--   -Write collected data, including communication status, to the
--    dpram so it is accessible to the host computer.
--   -Respond to DAC output commands

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY aio_acq IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 16
  );
  PORT( 
    ChanAddr2 : IN     std_logic;
    Done      : IN     std_logic;
    Err       : IN     std_logic;
    WrEn2     : IN     std_logic;
    WrRdy1    : IN     std_logic;
    clk       : IN     std_logic;
    i2c_rdata : IN     std_logic_vector (7 DOWNTO 0);
    rst       : IN     std_logic;
    wData2    : IN     std_logic_vector (15 DOWNTO 0);
    Rd        : OUT    std_logic;
    Start     : OUT    std_logic;
    Stop      : OUT    std_logic;
    Wr        : OUT    std_logic;
    WrAck2    : OUT    std_logic;
    WrAddr1   : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WrEn1     : OUT    std_logic;
    i2c_wdata : OUT    std_logic_vector (7 DOWNTO 0);
    wData1    : OUT    std_logic_vector (15 DOWNTO 0);
    RdStat    : IN     std_logic;
    Timeout   : IN     std_logic
  );

-- Declarations

END ENTITY aio_acq ;

--
ARCHITECTURE fsm OF aio_acq IS
  TYPE State_t IS (
    S_INIT, S_INIT_1,
    S_DAC1_INIT, S_DAC1_UPDATE, S_DAC1_SET,
    S_ADC1_READ, S_ADC2_CFG,
    S_DAC2_INIT, S_DAC2_UPDATE, S_DAC2_SET,
    S_ADC2_READ, S_ADC1_CFG,
    S_DAC_INIT, S_DAC_INIT_2, S_DAC_INIT_3, S_DAC_INIT_4,
    S_TXN, S_TXN_1, S_TXN_ERR,
    S_RAM,
    S_DAC_WR, S_DAC_WR_1, S_DAC_WR_2, S_DAC_WR_3,
    S_DAC_RD, S_DAC_RD_1, S_DAC_RD_2, S_DAC_RD_3,
    S_DAC_RD_4, S_DAC_RD_5, S_DAC_RD_6,
    S_ADC_RD, S_ADC_RD_0, S_ADC_RD_1, S_ADC_RD_2,
    S_ADC_RD_3, S_ADC_RD_4, S_ADC_RD_4A, S_ADC_RD_5,
    S_ADC_RD_6, S_ADC_RD_7, S_ADC_RD_8, S_ADC_RD_9,
    S_ADC_RD_10, S_ADC_RD_11, S_ADC_RD_12, S_ADC_RD_13,
    S_ADC_WR, S_ADC_WR_1, S_ADC_WR_2, S_ADC_WR_3,
    S_ADC_WR_4
  );
  SIGNAL crnt_state : State_t;
  SIGNAL err_recovery_nxt : State_t;
  SIGNAL txn_nxt : State_t;
  SIGNAL adc_nxt : State_t;
  SIGNAL dac_nxt : State_t;
  SIGNAL ram_nxt : State_t;

  SIGNAL Status : std_logic_vector(15 DOWNTO 0);
  constant ADC_ACK_BIT : integer := 0;
  constant ADC_NACK_BIT : integer := 1;
  constant ADC1_FRESH_BIT : integer := 2;
  constant ADC2_FRESH_BIT : integer := 3;
  constant DAC1_INIT_BIT : integer := 4;
  -- constant DAC1_ACK_BIT : integer := 5;
  constant DAC1_NACK_BIT : integer := 6;
  constant DAC1_FRESH_BIT : integer := 7;
  constant DAC2_INIT_BIT : integer := 8;
  -- constant DAC2_ACK_BIT : integer := 9;
  constant DAC2_NACK_BIT : integer := 10;
  constant DAC2_FRESH_BIT : integer := 11;
  SIGNAL nack_bit : integer range 11 downto 0; -- On NACK, set this bit
  
  SIGNAL RData : std_logic_vector(15 DOWNTO 0);
  SIGNAL adc_cfgd : std_logic;
  SIGNAL adc_wr_ptr : std_logic_vector(7 DOWNTO 0);
  SIGNAL adc_wr_data : std_logic_vector(15 DOWNTO 0);
  SIGNAL adc_ram_addr : integer range 6 DOWNTO 0;
  SIGNAL adc_fresh_bit : integer range 11 downto 0;
  SIGNAL dac_init_bit : integer range 11 downto 0;
  SIGNAL dac_fresh_bit : integer range 11 downto 0;
  SIGNAL dac_i2c_addr : std_logic_vector(7 DOWNTO 0);
  SIGNAL dac_ram_addr : integer range 6 DOWNTO 0; -- use for both setpoint and readback
  SIGNAL dac_reg_data : std_logic_vector(7 DOWNTO 0);
  SIGNAL dac_wr_data : std_logic_vector(15 DOWNTO 0);
  constant ADC_I2C_ADDR : std_logic_vector(7 DOWNTO 0) := "10010000";
  constant DAC1_I2C_ADDR : std_logic_vector(7 DOWNTO 0) := "10011000";
  constant DAC2_I2C_ADDR : std_logic_vector(7 DOWNTO 0) := "10011000"; -- FIX THIS
  constant DAC_WR_IO : std_logic_vector(7 DOWNTO 0) := "00110000";
  constant DAC_WR_CTRL : std_logic_vector(7 DOWNTO 0) := "01000000";
  -- constant LO_THRESH_PTR : std_logic_vector(7 DOWNTO 0) := "00000010";
  -- constant HI_THRESH_PTR : std_logic_vector(7 DOWNTO 0) := "00000011";
  constant ADC_CNV_PTR : std_logic_vector(7 DOWNTO 0) := "00000000";
  constant ADC_CFG_PTR : std_logic_vector(7 DOWNTO 0) := "00000001";
  constant ADC1_MUX : std_logic_vector(2 DOWNTO 0) := "001";
  constant ADC2_MUX : std_logic_vector(2 DOWNTO 0) := "011";
  -- constant ADC_VOLTAGE_CFG : std_logic_vector(15 DOWNTO 4) := X"914";
    	-- OS = 1: begin single conversion
    	-- MUX = 001 (AIN0/AIN3) or 000 (AIN0/AIN1)
    	-- PGA = 000 +/-6.144V
    	-- Mode = 1: power-down single-shot mode
    	-- DR = 010 : 32 SPS (fast enough to convert two channels within 0.1 sec)
    	-- COMP_MODE : 0 (traditional with hysteresis)
 	-- constant ADC_CURRENT_CFG : std_logic_vector(15 DOWNTO 4) := X"B14";
    	-- MUX = 011 (AIN2/AIN3)
  -- constant ADC_LED_ON : std_logic_vector(3 DOWNTO 0) := "1011";
  constant ADC_LED_OFF : std_logic_vector(3 DOWNTO 0) := "0011";
    	-- COMP_POL : 0 (active low output) 1 (active high output)
    	-- COMP_LAT : 0 (not latching)
    	-- COMP_QUE : 00 (assert after one) 11 (disabled)

  constant STATUS_RAM_ADDR : integer := 0;
  constant DAC1_SETPOINT_RAM_ADDR : integer := 1;
  constant DAC1_READBACK_RAM_ADDR : integer := 2;
  constant DAC2_SETPOINT_RAM_ADDR : integer := 3;
  constant DAC2_READBACK_RAM_ADDR : integer := 4;
  constant ADC1_RAM_ADDR : integer := 5;
  constant ADC2_RAM_ADDR : integer := 6;
  
BEGIN
  FSM : PROCESS (clk) IS
 
    PROCEDURE start_txn(W,R,Sta,Sto : IN std_logic;
      wD : IN std_logic_vector(7 DOWNTO 0);
      cur : IN State_t;
      nxt : IN State_t ) IS
    BEGIN
      IF Done = '1' OR Err = '1' THEN
        Wr <= W;
        Rd <= R;
        Start <= Sta;
        Stop <= Sto;
        i2c_wdata <= wD;
        txn_nxt <= nxt;
        crnt_state <= S_TXN;
      ELSE
        crnt_state <= cur;
      END IF;
      return;
    END PROCEDURE start_txn;
    
    PROCEDURE clear_txn(nxt : IN State_t ) IS
    BEGIN
      Wr <= '0';
      Rd <= '0';
      Start <= '0';
      Stop <= '0';
      crnt_state <= nxt;
      return;
    END PROCEDURE clear_txn;
    
    PROCEDURE start_ram(
      Addr : IN integer;
      wData : IN std_logic_vector(15 DOWNTO 0);
      nxt : IN State_t ) IS
    BEGIN
      WrEn1 <= '1';
      WrAddr1 <= std_logic_vector(to_unsigned(Addr,ADDR_WIDTH));
      wData1 <= wData;
      ram_nxt <= nxt;
      crnt_state <= S_RAM;
      return;
    END PROCEDURE start_ram;
    
    PROCEDURE dac_init(init_bit : integer; ram_addr : integer; nxt : State_t ) IS
    BEGIN
      dac_init_bit <= init_bit;
      dac_ram_addr <= ram_addr;
      dac_nxt <= nxt;
      crnt_state <= S_DAC_INIT;
      return;
    END PROCEDURE dac_init;

    PROCEDURE start_dac_wr(
      reg : IN std_logic_vector(7 DOWNTO 0);
      data : IN std_logic_vector(15 DOWNTO 0);
      nxt : IN State_t ) IS
    BEGIN
      dac_reg_data <= reg;
      dac_wr_data <= data;
      dac_nxt <= nxt;
      crnt_state <= S_DAC_WR;
      return;
    END PROCEDURE start_dac_wr;
    
    PROCEDURE start_dac_rd(ram_addr : integer; fresh_bit : integer; nxt : State_t ) IS
    BEGIN
      dac_ram_addr <= ram_addr;
      dac_fresh_bit <= fresh_bit;
      dac_nxt <= nxt;
      crnt_state <= S_DAC_RD;
      return;
    END PROCEDURE start_dac_rd;
    
    PROCEDURE start_adc_rd(ram_addr : integer; fresh_bit : integer; nxt : State_t ) IS
    BEGIN
      adc_ram_addr <= ram_addr;
      adc_fresh_bit <= fresh_bit;
      adc_nxt <= nxt;
      crnt_state <= S_ADC_RD;
      return;
    END PROCEDURE start_adc_rd;
    
    PROCEDURE start_adc_cfg(mux_bits : std_logic_vector(2 DOWNTO 0); nxt : State_t ) IS
    BEGIN
      adc_cfgd <= '0';
      adc_wr_ptr <= ADC_CFG_PTR;
      adc_wr_data <= '1' & mux_bits & X"14" & ADC_LED_OFF;
        	-- OS = 1: begin single conversion
        	-- MUX = 001 (AIN0/AIN3) or 000 (AIN0/AIN1)
        	-- PGA = 000 +/-6.144V
        	-- Mode = 1: power-down single-shot mode
        	-- DR = 010 : 32 SPS (fast enough to convert two channels within 0.1 sec)
        	-- COMP_MODE : 0 (traditional with hysteresis)
   	  adc_nxt <= nxt;
   	  crnt_state <= S_ADC_WR;
   	  return;
    END PROCEDURE start_adc_cfg;

  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF rst = '1' THEN
        WrEn1 <= '0';
        WrAddr1 <= (others => '0');
        wData1 <= (others => '0');
        WrAck2 <= '0';
        Rd <= '0';
        Wr <= '0';
        Start <= '0';
        Stop <= '0';
        i2c_wdata <= X"00";
        crnt_state <= S_INIT;
        nack_bit <= 0;
        adc_cfgd <= '0';
      ELSE
        IF RdStat = '1' THEN
          Status <= (DAC1_INIT_BIT => Status(DAC1_INIT_BIT),
            DAC2_INIT_BIT => Status(DAC2_INIT_BIT),
            others => '0');
        END IF;
        CASE crnt_state IS
          WHEN S_INIT =>
            -- reinitialize most outputs
            Status <= (others => '0');
            WrEn1 <= '0';
            WrAck2 <= '0';
            clear_txn(S_INIT_1);
          WHEN S_INIT_1 =>
            start_ram(STATUS_RAM_ADDR,Status,S_DAC1_INIT);
          WHEN S_DAC1_INIT =>
            nack_bit <= DAC1_NACK_BIT;
            dac_i2c_addr <= DAC1_I2C_ADDR;
            err_recovery_nxt <= S_ADC1_READ;
            IF Status(DAC1_INIT_BIT) = '1' THEN
              crnt_state <= S_DAC1_UPDATE;
            ELSE
              dac_init(DAC1_INIT_BIT, DAC1_SETPOINT_RAM_ADDR, S_DAC1_UPDATE);
            END IF;
          WHEN S_DAC1_UPDATE =>
            IF WrEn2 = '1' AND ChanAddr2 = '0' THEN
              start_dac_wr(DAC_WR_IO, wData2, S_DAC1_SET);
            ELSE
              start_dac_rd(DAC1_READBACK_RAM_ADDR, DAC1_FRESH_BIT, S_ADC1_READ);
            END IF;
          WHEN S_DAC1_SET =>
            start_ram(DAC1_SETPOINT_RAM_ADDR, dac_wr_data, S_ADC1_READ);
          WHEN S_ADC1_READ =>
            nack_bit <= ADC_NACK_BIT;
            err_recovery_nxt <= S_ADC2_CFG;
            IF adc_cfgd = '1' THEN
              start_adc_rd(ADC1_RAM_ADDR, ADC1_FRESH_BIT, S_ADC2_CFG);
            ELSE
              crnt_state <= S_ADC2_CFG;
            END IF;
          WHEN S_ADC2_CFG =>
            adc_cfgd <= '0';
            start_adc_cfg(ADC2_MUX, S_DAC2_INIT);

          WHEN S_DAC2_INIT =>
            nack_bit <= DAC2_NACK_BIT;
            dac_i2c_addr <= DAC2_I2C_ADDR;
            err_recovery_nxt <= S_ADC2_READ;
            IF Status(DAC2_INIT_BIT) = '1' THEN
              crnt_state <= S_DAC2_UPDATE;
            ELSE
              dac_init(DAC2_INIT_BIT, DAC2_SETPOINT_RAM_ADDR, S_DAC2_UPDATE);
            END IF;
          WHEN S_DAC2_UPDATE =>
            IF WrEn2 = '1' AND ChanAddr2 = '1' THEN
              start_dac_wr(DAC_WR_IO, wData2, S_DAC2_SET);
            ELSE
              start_dac_rd(DAC2_READBACK_RAM_ADDR, DAC2_FRESH_BIT, S_ADC2_READ);
            END IF;
          WHEN S_DAC2_SET =>
            start_ram(DAC2_SETPOINT_RAM_ADDR, dac_wr_data, S_ADC2_READ);
          WHEN S_ADC2_READ =>
            nack_bit <= ADC_NACK_BIT;
            err_recovery_nxt <= S_ADC1_CFG;
            IF adc_cfgd = '1' THEN
              start_adc_rd(ADC2_RAM_ADDR, ADC2_FRESH_BIT, S_ADC1_CFG);
            ELSE
              crnt_state <= S_ADC1_CFG;
            END IF;
          WHEN S_ADC1_CFG =>
            adc_cfgd <= '0';
            start_adc_cfg(ADC1_MUX, S_DAC1_INIT);
            
            
          WHEN S_DAC_INIT =>
            IF Status(dac_init_bit) = '1' THEN
              crnt_state <= dac_nxt;
            ELSE
              start_dac_wr(DAC_WR_CTRL,X"0800",S_DAC_INIT_2);
            END IF;
          WHEN S_DAC_INIT_2 =>
            start_dac_wr(DAC_WR_IO,X"0000",S_DAC_INIT_3);
          WHEN S_DAC_INIT_3 =>
            Status(dac_init_bit) <= '1';
            start_ram(dac_ram_addr,X"0000",S_DAC_INIT_4);
          WHEN S_DAC_INIT_4 =>
            start_ram(STATUS_RAM_ADDR,Status,dac_nxt);

          -- start_txn(): byte-level interface to HVPS_txn
          WHEN S_TXN =>
            IF Done = '0' AND Err = '0' THEN
              clear_txn(S_TXN_1);
            ELSE
              crnt_state <= S_TXN;
            END IF;
          WHEN S_TXN_1 =>
            IF Err = '1' THEN
              Status(nack_bit) <= '1';
              crnt_state <= S_TXN_ERR;
            ELSIF Done = '1' THEN
              crnt_state <= txn_nxt;
            ELSIF Timeout = '1' THEN
              crnt_state <= S_INIT;
            ELSE
              crnt_state <= S_TXN_1;
            END IF;
          -- Handle errors from start_txn
          -- Write Status word to RAM
          -- Go to err_recovery_nxt
          WHEN S_TXN_ERR =>
            start_ram(STATUS_RAM_ADDR,Status,err_recovery_nxt);

          -- start_ram(): Writes to dpram
          WHEN S_RAM =>
            IF WrRdy1 = '1' THEN
              WrEn1 <= '0';
              crnt_state <= ram_nxt;
            ELSE
              crnt_state <= S_RAM;
            END IF;

          -- subroutine to write to DAC: chan_loop_iterate()
          WHEN S_DAC_WR =>
            start_txn('1','0','1','0',dac_i2c_addr,S_DAC_WR,S_DAC_WR_1);
          WHEN S_DAC_WR_1 =>
            start_txn('1','0','0','0',dac_reg_data,S_DAC_WR_1,S_DAC_WR_2);
          WHEN S_DAC_WR_2 =>
            start_txn('1','0','0','0',dac_wr_data(15 DOWNTO 8),
              S_DAC_WR_2,S_DAC_WR_3);
          WHEN S_DAC_WR_3 =>
            start_txn('1','0','0','1',dac_wr_data(7 DOWNTO 0),
              S_DAC_WR_3,dac_nxt);
              
          -- start_dac_rd():
          WHEN S_DAC_RD =>
            start_txn('0','1','1','0',dac_i2c_addr,S_DAC_RD,S_DAC_RD_1);
          WHEN S_DAC_RD_1 =>
            start_txn('0','1','0','0',X"00",S_DAC_RD_1,S_DAC_RD_2);
          WHEN S_DAC_RD_2 =>
            RData(15 DOWNTO 8) <= i2c_rdata;
            start_txn('0','1','0','1',X"00",S_DAC_RD_2,S_DAC_RD_3);
          WHEN S_DAC_RD_3 =>
            RData(7 DOWNTO 0) <= i2c_rdata;
            crnt_state <= S_DAC_RD_4;
          WHEN S_DAC_RD_4 =>
            start_ram(dac_ram_addr, RData, S_DAC_RD_5);
          WHEN S_DAC_RD_5 =>
            IF Status(dac_fresh_bit) = '1' THEN
              crnt_state <= dac_nxt;
            ELSE
              Status(dac_fresh_bit) <= '1';
              crnt_state <= S_DAC_RD_6;
            END IF;
          WHEN S_DAC_RD_6 =>
            start_ram(STATUS_RAM_ADDR, Status, dac_nxt);

          -- start_adc_rd(): reads the last conversion value
          WHEN S_ADC_RD => -- Reads config, then reads data when ready
            start_txn('1','0','1','0',ADC_I2C_ADDR,S_ADC_RD,S_ADC_RD_0);
          WHEN S_ADC_RD_0 =>
            start_txn('1','0','0','0',ADC_CFG_PTR,S_ADC_RD_0,S_ADC_RD_1);
          WHEN S_ADC_RD_1 =>
            start_txn('0','1','1','0',ADC_I2C_ADDR,S_ADC_RD_1,S_ADC_RD_2);
          WHEN S_ADC_RD_2 =>
            start_txn('0','1','0','0',X"00",S_ADC_RD_2,S_ADC_RD_3);
          WHEN S_ADC_RD_3 =>
            RData(15 DOWNTO 8) <= i2c_rdata;
            start_txn('0','1','0','1',X"00",S_ADC_RD_3,S_ADC_RD_4);
          WHEN S_ADC_RD_4 =>
            RData(7 DOWNTO 0) <= i2c_rdata;
            IF RData(15) = '1' THEN
              crnt_state <= S_ADC_RD_5;
            ELSIF Status(ADC_ACK_BIT) = '0' THEN
              Status(ADC_ACK_BIT) <= '1';
              crnt_state <= S_ADC_RD_4A;
            ELSE
              crnt_state <= S_ADC_RD_1;
            END IF;
          WHEN S_ADC_RD_4A => -- Update status
            start_ram(STATUS_RAM_ADDR, Status, S_ADC_RD_1);
          WHEN S_ADC_RD_5 => -- Conversion is complete, now read channel
            start_txn('1','0','1','0',ADC_I2C_ADDR,S_ADC_RD_5,S_ADC_RD_6);
          WHEN S_ADC_RD_6 =>
            start_txn('1','0','0','0',ADC_CNV_PTR,S_ADC_RD_6,S_ADC_RD_7);
          WHEN S_ADC_RD_7 =>
            start_txn('0','1','1','0',ADC_I2C_ADDR,S_ADC_RD_7,S_ADC_RD_8);
          WHEN S_ADC_RD_8 =>
            start_txn('0','1','0','0',X"00",S_ADC_RD_8,S_ADC_RD_9);
          WHEN S_ADC_RD_9 =>
            RData(15 DOWNTO 8) <= i2c_rdata;
            start_txn('0','1','0','1',X"00",S_ADC_RD_9,S_ADC_RD_10);
          WHEN S_ADC_RD_10 =>
            RData(7 DOWNTO 0) <= i2c_rdata;
            crnt_state <= S_ADC_RD_11;
          WHEN S_ADC_RD_11 =>
            start_ram(adc_ram_addr, RData, S_ADC_RD_12);
          WHEN S_ADC_RD_12 =>
            IF Status(adc_fresh_bit) = '0' THEN
              Status(adc_fresh_bit) <= '1';
              crnt_state <= S_ADC_RD_13;
            ELSE
              crnt_state <= adc_nxt;
            END IF;
          WHEN S_ADC_RD_13 =>
            start_ram(STATUS_RAM_ADDR,Status,adc_nxt);

          -- subroutine to write to ADC, started via start_adc_wr()
          WHEN S_ADC_WR =>
            start_txn('1','0','1','0', ADC_I2C_ADDR,S_ADC_WR,S_ADC_WR_1);
          WHEN S_ADC_WR_1 =>
            start_txn('1','0','0','0',adc_wr_ptr,S_ADC_WR_1,S_ADC_WR_2);
          WHEN S_ADC_WR_2 =>
            start_txn('1','0','0','0',adc_wr_data(15 DOWNTO 8),
              S_ADC_WR_2,S_ADC_WR_3);
          WHEN S_ADC_WR_3 =>
            start_txn('1','0','0','0',adc_wr_data(7 DOWNTO 0),
              S_ADC_WR_3,S_ADC_WR_4);
          WHEN S_ADC_WR_4 =>
            adc_cfgd <= '1';
            crnt_state <= adc_nxt;

          WHEN OTHERS =>
            crnt_state <= S_INIT;
        END CASE;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE fsm;

