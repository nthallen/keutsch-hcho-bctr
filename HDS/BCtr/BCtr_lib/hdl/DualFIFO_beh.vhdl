--
-- VHDL Architecture BCtr_lib.DualFIFO.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 14:29:27 10/13/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
LIBRARY BCtr_lib;
USE BCtr_lib.ALL;

ENTITY DualFIFO IS
   GENERIC( 
      FIFO_WIDTH  : integer range 256 downto 1  := 1;
      FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
   );
  PORT( 
    CtrData1 : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    EnA      : IN     std_logic;
    FBRE     : IN     std_logic;
    RptRE    : IN     std_logic;
    WE       : IN     std_logic;
    clk      : IN     std_logic;
    rst      : IN     std_logic;
    CtrData0 : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    FBEmpty  : OUT    std_logic;
    Full     : OUT    std_logic;
    RData    : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
    RptEmpty : OUT    std_logic
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
  FOR ALL : FIFO USE ENTITY BCtr_lib.FIFO;
BEGIN
  FIFO_A : FIFO
    GENERIC MAP (
      FIFO_WIDTH      => FIFO_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    PORT MAP (
      WData => WData,
      WE    => WEA,
      RE    => REA,
      Clk   => clk,
      Rst   => rst,
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
      WData => WData,
      WE    => WEB,
      RE    => REB,
      Clk   => clk,
      Rst   => rst,
      RData => RDataB,
      Empty => EmptyB,
      Full  => FullB
    );
    
  Mux : PROCESS (ENA,WE,FBRE,RptRE,RDataA,RDataB,EmptyA,EmptyB,FullA,FullB) IS
  BEGIN
    IF ENA = '1' THEN
      WEA <= WE;
      WEB <= '0';
      REA <= FBRE;
      REB <= RptRE;
      CtrData0 <= RDataA;
      RData <= RDataB;
      FBEmpty <= EmptyA;
      RptEmpty <= EmptyB;
      Full <= FullA;
    ELSE
      WEA <= '0';
      WEB <= WE;
      REA <= RptRE;
      REB <= FBRE;
      CtrData0 <= RDataB;
      RData <= RDataA;
      FBEmpty <= EmptyB;
      RptEmpty <= EmptyA;
      Full <= FullB;
    END IF;
  END PROCESS;
    
END ARCHITECTURE beh;

