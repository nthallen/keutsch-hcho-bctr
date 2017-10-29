--
-- VHDL Architecture BCtr_lib.ppsgen.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:35:46 10/26/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ppsgen IS
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0) := x"0060";
    CLK_FREQ : unsigned(31 DOWNTO 0) := to_unsigned(100000000,32);
    MSW_SHIFT : integer range 16 downto 0 := 11
  );
  PORT (
    clk      : IN std_logic;
    pps      : OUT std_logic;
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    RdEn     : IN     std_logic;
    WrEn     : IN     std_logic;
    BdEn     : OUT    std_logic;
    BdWrEn   : OUT    std_logic;
    ExpReset : IN     std_logic
  );
END ENTITY ppsgen;

--
ARCHITECTURE beh OF ppsgen IS
  SIGNAL ToffsetMSW_en : std_logic;
  SIGNAL PPSfineAdjust_en : std_logic;
  SIGNAL PPSperiodLSB_en : std_logic;
  SIGNAL PPSperiodMSB_en : std_logic;
  SIGNAL ToffsetLSB_en : std_logic;
  SIGNAL ToffsetMSB_en : std_logic;
  SIGNAL PPS_cnt : unsigned(31 downto 0);
  SIGNAL PPS_period : unsigned(31 downto 0);
  SIGNAL PPS_period_adj : unsigned(31 downto 0);
  SIGNAL PPSfineAdjust : unsigned(31 downto 0);
  SIGNAL MSB_held : std_logic;
  SIGNAL Toffset_MSB_hold : std_logic_vector(15 downto 0);
  SIGNAL ToffsetAdj : signed(31 downto 0);
  SIGNAL UpdateTime : std_logic;
  SIGNAL UpdatePeriod : std_logic;
BEGIN
  addr : PROCESS (ExpAddr) IS
    VARIABLE offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    BdEn <= '1';
    BdWrEn <= '0';
    ToffsetMSW_en <= '0';
    PPSfineAdjust_en <= '0';
    PPSperiodLSB_en <= '0';
    PPSperiodMSB_en <= '0';
    ToffsetLSB_en <= '0';
    ToffsetMSB_en <= '0';
    offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
    case to_integer(offset) is
      when 0 => ToffsetMSW_en <= '1';
      when 1 => PPSfineAdjust_en <= '1';
      when 2 => PPSperiodLSB_en <= '1'; BdWrEn <= '1';
      when 3 => PPSperiodMSB_en <= '1'; BdWrEn <= '1';
      when 4 => ToffsetLSB_en <= '1'; BdWrEn <= '1';
      when 5 => ToffsetMSB_en <= '1'; BdWrEn <= '1';
      when others => BdEn <= '0';
    end case;
  END PROCESS;
  
  pps_count : PROCESS (clk) is
  BEGIN
    if clk'event AND clk = '1' then
      if ExpReset = '1' then
        PPS_cnt <= PPS_period_adj;
        PPS <= '0';
      elsif PPS_cnt >= PPS_period_adj then
        PPS <= '1';
        PPS_cnt <= to_unsigned(0,32);
      else
        PPS <= '0';
        PPS_cnt <= PPS_cnt + 1;
      end if;
    end if;
  END PROCESS;
  
  rw_proc : PROCESS (clk) is
    Variable Offset32 : signed(31 downto 0);
  BEGIN
    if clk'event AND clk = '1' then
      if ExpReset = '1' then
        PPS_period <= CLK_FREQ;
        PPS_period_adj <= CLK_FREQ-1;
        PPSfineAdjust <= (others => '0');
        MSB_held <= '0';
        UpdateTime <= '0';
        UpdatePeriod <= '0';
        PPS_cnt <= PPS_period_adj;
        PPS <= '0';
      else
        if PPS_cnt >= PPS_period_adj then
          PPS <= '1';
          PPS_cnt <= PPS_cnt - PPS_period_adj;
        elsif UpdateTime = '1' then
          PPS_cnt <= PPS_cnt + unsigned(ToffsetAdj) + 1;
          UpdateTime <= '0';
        else
          PPS <= '0';
          PPS_cnt <= PPS_cnt + 1;
        end if;

        if RdEn = '1' then
          if ToffsetMSW_en = '1' then
            RData <= std_logic_vector(PPS_cnt(15+MSW_SHIFT downto MSW_SHIFT));
          elsif PPSfineAdjust_en = '1' then
            RData <= std_logic_vector(PPSfineAdjust(15 downto 0));
          elsif PPSperiodLSB_en = '1' then
            RData <= std_logic_vector(PPS_period(15 downto 0));
          elsif PPSperiodMSB_en = '1' then
            RData <= std_logic_vector(PPS_period(31 downto 0));
          elsif ToffsetLSB_en = '1' then
            RData <= std_logic_vector(PPS_cnt(15 downto 0));
            Toffset_MSB_hold <= std_logic_vector(PPS_cnt(31 downto 0));
            MSB_held <= '1';
          elsif ToffsetMSB_en = '1' then
            if MSB_held = '1' then
              RData <= Toffset_MSB_hold;
            else
              RData <= std_logic_vector(PPS_cnt(31 downto 0));
            end if;
            MSB_held <= '0';
          end if;
        elsif WrEn = '1' then
          if PPSfineAdjust_en = '1' then
            PPSfineAdjust <= unsigned(resize(signed(WData),32));
            UpdatePeriod <= '1';
          elsif PPSperiodLSB_en = '1' then
            PPS_period(15 downto 0) <= unsigned(WData);
          elsif PPSperiodMSB_en = '1' then
            PPS_period(31 downto 16) <= unsigned(WData);
          elsif ToffsetLSB_en = '1' then
            ToffsetAdj(15 downto 0) <= signed(WData);
          elsif ToffsetMSB_en = '1' then
            ToffsetAdj(31 downto 16) <= signed(WData);
            UpdateTime <= '1';
          end if;
        elsif UpdatePeriod = '1' then
          PPS_period_adj <= PPS_period + unsigned(PPSfineAdjust) - 1;
          UpdatePeriod <= '0';
        end if;
      end if;
    end if;
  END PROCESS;

END ARCHITECTURE beh;

