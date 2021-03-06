--
-- VHDL Architecture PTR3_HVPS_lib.HVPS_addr.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 17:25:42 11/11/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY aio_addr IS
  GENERIC( 
    BASE_ADDR  : std_logic_vector(15 DOWNTO 0) := X"0050";
    ADDR_WIDTH : integer range 16 downto 8     := 8
  );
  PORT( 
    ExpAddr   : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    RdEn      : IN     std_logic;
    WrAck2    : IN     std_logic;
    WrEn      : IN     std_logic;
    clk       : IN     std_logic;
    wData     : IN     std_logic_vector (15 DOWNTO 0);
    ChanAddr2 : OUT    std_logic_vector (1 DOWNTO 0);
    RdAddr    : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WrEn2     : OUT    std_logic;
    dpRdEn    : OUT    std_logic;
    wData2    : OUT    std_logic_vector (15 DOWNTO 0);
    RdStat    : OUT    std_logic;
    rst       : IN     std_logic;
    BdEn      : OUT    std_logic;
    BdWrEn    : OUT    std_logic;
    idxData   : IN     std_logic_vector (15 DOWNTO 0);
    idxWr     : IN     std_logic;
    idxAck    : OUT    std_logic;
    IdxWrAck  : IN     std_logic
  );

-- Declarations

END ENTITY aio_addr ;

--
ARCHITECTURE beh OF aio_addr IS
  SIGNAL WrOK : std_logic;
  SIGNAL Read : std_logic;
  SIGNAL WrEn2_int : std_logic;
  SIGNAL IdxWrActive : std_logic;
BEGIN
  Addrs : PROCESS (ExpAddr, WrEn2_int) IS
    Variable Offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    IF unsigned(ExpAddr) >= unsigned(BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0)) AND
       unsigned(ExpAddr) < unsigned(BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0)) + 7 THEN
      BdEn <= '1';
      Offset := unsigned(ExpAddr) - unsigned(BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0));
      IF WrEn2_int = '0' AND
         (Offset = 0 OR Offset = 1 OR Offset = 3) THEN
        WrOK <= '1';
      ELSE
        WrOK <= '0';
      END IF;
    ELSE
      BdEn <= '0';
      WrOK <= '0';
    END IF;
  END PROCESS;
  
  Writing : PROCESS (clk) IS
    Variable Offset : unsigned(1 DOWNTO 0);
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF rst = '1' THEN
        WrEn2_int <= '0';
        idxAck <= '0';
        IdxWrActive <= '0';
        ChanAddr2 <= (others => '0');
        wData2 <= (others => '0');
      ELSE
        IF WrEn = '1' AND WrOK = '1' THEN
          Offset := unsigned(ExpAddr(1 downto 0)) - unsigned(BASE_ADDR(1 DOWNTO 0));
          ChanAddr2 <= std_logic_vector(Offset);
          wData2 <= wData;
          WrEn2_int <= '1';
        ELSIF idxWr = '1' THEN
          ChanAddr2 <= "10";
          WData2 <= idxData;
          WrEn2_int <= '1';
          IdxWrActive <= '1';
        END IF;
        IF WrAck2 = '1' THEN
          WrEn2_int <= '0';
        END IF;
        IF IdxWrActive = '1' AND IdxWrAck = '1' THEN
          idxAck <= '1';
          IdxWrActive <= '0';
        ELSE
          idxAck <= '0';
        END IF;
      END IF;
    END IF;
  END PROCESS;
  
  Reading : PROCESS (clk) IS
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      RdStat <= '0';
      IF RdEn = '1' AND Read = '0' THEN
        RdAddr <= std_logic_vector(
          unsigned(ExpAddr) - unsigned(BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0)));
        dpRdEn <= '1';
        Read <= '1';
        IF ExpAddr = BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0) THEN
          RdStat <= '1';
        END IF;
      ELSIF RdEn = '1' AND Read = '1' THEN
        dpRdEn <= '0';
      ELSE
        dpRdEn <= '0';
        Read <= '0';
      END IF;
    END IF;
  END PROCESS;

  BdWrEn <= WrOK;
  WrEn2 <= WrEn2_int;
END ARCHITECTURE beh;

