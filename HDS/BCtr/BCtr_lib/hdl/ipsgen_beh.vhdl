--
-- VHDL Architecture BCtr_lib.ips.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 20:23:36 11/ 9/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ipsgen IS
  GENERIC( 
    ADDR_WIDTH   : integer range 16 downto 8 := 8;
    BASE_ADDR    : unsigned(15 DOWNTO 0)     := x"0070";
    Nbps_default : integer range 63 downto 1 := 10;
    NC0_default  : integer                   := 10**7
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    RdEn     : IN     std_logic;
    WData    : IN     std_logic_vector (15 DOWNTO 0);
    WrEn     : IN     std_logic;
    BdEn     : OUT    std_logic;
    BdWrEn   : OUT    std_logic;
    IPS      : OUT    std_logic;
    RData    : OUT    std_logic_vector (15 DOWNTO 0);
    IPnum    : OUT    std_logic_vector (5 DOWNTO 0);
    clk      : IN     std_logic;
    ExpReset : IN     std_logic;
    PPS      : IN     std_logic
  );

-- Declarations

END ENTITY ipsgen;

--
ARCHITECTURE beh OF ipsgen IS
  SIGNAL Nbps_en : std_logic;
  SIGNAL NC0lsb_en : std_logic;
  SIGNAL NC0msb_en : std_logic;
  SIGNAL NCcorr_en : std_logic;
  SIGNAL NCerr_en : std_logic;
  SIGNAL Status_en : std_logic;
  SIGNAL Nbps : unsigned(5 downto 0);
  SIGNAL IPctr : unsigned(5 downto 0);
  SIGNAL IPnum_int : unsigned(5 downto 0);
  SIGNAL NC0 : unsigned(27 downto 0);
  SIGNAL NC1 : unsigned(27 downto 0); -- NC0+NCcorr-1
  SIGNAL NCcorr : signed(15 downto 0);
  SIGNAL NCerr : signed(15 downto 0);
  SIGNAL NCctr : signed(28 downto 0);
  SIGNAL NCerr_povf : std_logic;
  SIGNAL NCerr_novf : std_logic;
  SIGNAL startup : std_logic;
  SIGNAL update_NC1 : std_logic;
BEGIN
  addr : PROCESS (ExpAddr) IS
    VARIABLE offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    BdEn <= '1';
    BdWrEn <= '0';
    Nbps_en <= '0';
    NC0lsb_en <= '0';
    NC0msb_en <= '0';
    NCcorr_en <= '0';
    NCerr_en <= '0';
    Status_en <= '0';
    offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
    case to_integer(offset) is
      when 0 => Nbps_en <= '1'; BdWrEn <= '1';
      when 1 => NC0lsb_en <= '1'; BdWrEn <= '1';
      when 2 => NC0msb_en <= '1'; BdWrEn <= '1';
      when 3 => NCcorr_en <= '1'; BdWrEn <= '1';
      when 4 => NCerr_en <= '1';
      when 5 => Status_en <= '1';
      when others => BdEn <= '0';
    end case;
  END PROCESS;
  
  rw_proc : PROCESS (clk) is
    variable all_ones : std_logic;
    variable all_zeros : std_logic;
  BEGIN
    if clk'event AND clk = '1' then
      if ExpReset = '1' then
        Nbps <= to_unsigned(Nbps_default,Nbps'length);
        NC0 <= to_unsigned(NC0_default,NC0'length);
        NC1 <= to_unsigned(NC0_default-1,NC1'length);
        NCcorr <= (others => '0');
        NCerr <= (others => '0');
        NCctr <= (others => '0');
        RData <= (others => '0');
        IPctr <= (others => '0');
        IPnum_int <= (others => '0');
        NCerr_povf <= '0';
        NCerr_novf <= '0';
        IPS <= '0';
        startup <= '1';
        update_NC1 <= '1';
      else
        if PPS = '1' then
          startup <= '0';
          NCerr <= NCctr(15 downto 0);
          all_ones := '1';
          all_zeros := '1';
          for i in NCctr'length-1 downto 15 loop
            if NCctr(i) = '1' then
              all_zeros := '0';
            else
              all_ones := '0';
            end if;
          end loop;
          if all_ones = '1' or all_zeros = '1' then
            NCerr_povf <= '0';
            NCerr_novf <= '0';
          elsif NCctr(NCctr'length-1) = '1' then
            NCerr_novf <= '1';
            NCerr_povf <= '0';
          else
            NCerr_novf <= '0';
            NCerr_povf <= '1';
          end if;
          NCctr <= signed(resize(NC1,NCctr'length));
          IPctr <= Nbps-1;
          IPnum_int <= (others => '0');
          IPS <= '1';
        elsif startup = '0' AND IPctr > 0 AND NCctr = 0 then
          IPS <= '1';
          NCctr <= signed(resize(NC1,NCctr'length));
          IPctr <= IPctr-1;
          IPnum_int <= IPnum_int+1;
        else
          IPS <= '0';
          if startup = '0' then
            NCctr <= NCctr-1;
          end if;
        end if;
        
        if RdEn = '1' then
          if Nbps_en = '1' then
            RData <= std_logic_vector(resize(Nbps,16));
          elsif NC0lsb_en = '1' then
            RData <= std_logic_vector(NC0(15 downto 0));
          elsif NC0msb_en = '1' then
            RData <= std_logic_vector(resize(NC0(NC0'length-1 downto 16),16));
          elsif NCcorr_en = '1' then
            RData <= std_logic_vector(NCcorr);
          elsif NCerr_en = '1' then
            RData <= std_logic_vector(NCerr);
          elsif Status_en = '1' then
            RData <= (0 => NCerr_povf,
              1 => NCerr_novf,
              others => '0');
          end if;
        elsif WrEn = '1' then
          if Nbps_en = '1' then
            Nbps <= unsigned(WData(Nbps'length-1 downto 0));
          elsif NC0lsb_en = '1' then
            NC0(15 downto 0) <= unsigned(WData);
            update_NC1 <= '1';
          elsif NC0msb_en = '1' then
            NC0(NC0'length-1 downto 16) <=
              unsigned(WData(NC0'length-17 downto 0));
            update_NC1 <= '1';
          elsif NCcorr_en = '1' then
            NCcorr <= signed(WData);
            update_NC1 <= '1';
          end if;
        end if;
        
        if update_NC1 = '1' then
          update_NC1 <= '0';
          NC1 <= NC0 + unsigned(resize(NCcorr,NC0'length)) - 1;
        end if;
      end if;
    end if;
  END PROCESS;
  
  IPnum <= IPnum_int;
  
END ARCHITECTURE beh;

