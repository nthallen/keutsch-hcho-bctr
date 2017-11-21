--
-- VHDL Architecture BCtr_lib.DualFIFO.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:29:27 10/13/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
-- DualFIFO is controlled by the 'EnA' input. When EnA is high,
-- FIFO 'A' is presented on the counter/feedback side, through the
--   Control pins: FBRE, WE
--   Status pins: FBEmpty, FBFull
--   Write data: FBWData
--   Read data:  FBRData
-- And FIFO 'B' is presented on the reporting side, through:
--   Control pin: RptRE (no writing on the report side)
--   Status pin:  RptEmpty
--   Read data:   RData (no write data)
-- When EnA is low, the roles are reversed

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY DualFIFO IS
  GENERIC( 
    FIFO_WIDTH      : integer range 256 downto 1 := 1;
    FIFO_ADDR_WIDTH : integer range 10 downto 1  := 8
  );
  PORT( 
    clk      : IN     std_logic;
    EnA      : IN     std_logic;
    rstA     : IN     std_logic;
    rstB     : IN     std_logic;
    FBEmpty  : OUT    std_logic;
    FBFull   : OUT    std_logic;
    FBRE     : IN     std_logic;
    FBWE     : IN     std_logic;
    FBWData  : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    FBRData  : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    RptRE    : IN     std_logic;
    RptEmpty : OUT    std_logic;
    RptData  : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0)
  );

-- Declarations

END ENTITY DualFIFO ;

--
ARCHITECTURE beh OF DualFIFO IS
  SIGNAL WEA    : std_logic;
  SIGNAL REA    : std_logic;
  SIGNAL RDataA : std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
  SIGNAL EmptyA : std_logic;
  SIGNAL FullA  : std_logic;
  SIGNAL WEB    : std_logic;
  SIGNAL REB    : std_logic;
  SIGNAL RDataB : std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
  SIGNAL EmptyB : std_logic;
  SIGNAL FullB  : std_logic;
  
  COMPONENT FIFO
    GENERIC (
      FIFO_WIDTH      : integer range 256 downto 1 := 1;
      FIFO_ADDR_WIDTH : integer range 10 downto 1  := 8
    );
    PORT (
      WData : IN     std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
      WE    : IN     std_logic;
      RE    : IN     std_logic;
      Clk   : IN     std_ulogic;
      Rst   : IN     std_logic;
      RData : OUT    std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
      Empty : OUT    std_logic;
      Full  : OUT    std_logic
    );
  END COMPONENT FIFO;
BEGIN
  FIFO_A : FIFO
    GENERIC MAP (
      FIFO_WIDTH      => FIFO_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      WData => FBWData,
      WE    => WEA,
      RE    => REA,
      Clk   => clk,
      Rst   => rstA,
      RData => RDataA,
      Empty => EmptyA,
      Full  => FullA
    );

  FIFO_B : FIFO
    GENERIC MAP (
      FIFO_WIDTH      => FIFO_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      WData => FBWData,
      WE    => WEB,
      RE    => REB,
      Clk   => clk,
      Rst   => rstB,
      RData => RDataB,
      Empty => EmptyB,
      Full  => FullB
    );
    
  Mux : PROCESS (ENA,FBWE,FBRE,RptRE,RDataA,RDataB,EmptyA,EmptyB,FullA,FullB) IS
  BEGIN
    IF ENA = '1' THEN
      WEA <= FBWE;
      WEB <= '0';
      REA <= FBRE;
      REB <= RptRE;
      FBRData <= RDataA;
      RptData <= RDataB;
      FBEmpty <= EmptyA;
      RptEmpty <= EmptyB;
      FBFull <= FullA;
    ELSE
      WEA <= '0';
      WEB <= FBWE;
      REA <= RptRE;
      REB <= FBRE;
      FBRData <= RDataB;
      RptData <= RDataA;
      FBEmpty <= EmptyB;
      FBFull <= FullB;
      RptEmpty <= EmptyA;
    END IF;
  END PROCESS;
    
END ARCHITECTURE beh;

