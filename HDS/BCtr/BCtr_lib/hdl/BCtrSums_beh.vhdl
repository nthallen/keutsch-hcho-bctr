--
-- VHDL Architecture BCtr_lib.BCtrSums.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 12:48:27 01/ 6/2017
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY BCtrSums IS
   GENERIC( 
      N_CHANNELS : integer range 4 DOWNTO 1  := 1;
      CTR_WIDTH  : integer range 32 DOWNTO 1 := 16
   );
   PORT( 
      CntEn     : IN     std_logic;
      CtrData0  : IN     std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0);
      PMTs      : IN     std_logic_vector (N_CHANNELS-1 DOWNTO 0);
      clk       : IN     std_logic;
      first_col : IN     std_logic;
      first_row : IN     std_logic;
      rst       : IN     std_logic;
      CtrData1  : OUT    std_logic_vector (N_CHANNELS*CTR_WIDTH-1 DOWNTO 0)
   );

-- Declarations

END BCtrSums ;

--
ARCHITECTURE beh OF BCtrSums IS
   SIGNAL SIG : std_logic_vector(N_CHANNELS-1 DOWNTO 0);

   COMPONENT PMT_Input
      PORT (
         PMT : IN     std_logic;
         clk : IN     std_logic;
         rst : IN     std_logic;
         SIG : OUT    std_logic
      );
   END COMPONENT PMT_Input;

   COMPONENT BCtrSum
      GENERIC (
         CTR_WIDTH : integer range 32 downto 1 := 16
      );
      PORT (
         CData0    : IN     std_logic_vector(CTR_WIDTH-1 DOWNTO 0);
         CntEn     : IN     std_logic;
         SIG       : IN     std_logic;
         clk       : IN     std_logic;
         first_col : IN     std_logic;
         first_row : IN     std_logic;
         rst       : IN     std_logic;
         CData1    : OUT    std_logic_vector(CTR_WIDTH-1 DOWNTO 0)
      );
   END COMPONENT BCtrSum;
BEGIN
  ctrs : for i in 0 TO N_CHANNELS-1 generate
    InstBCS : BCtrSum
      GENERIC MAP ( CTR_WIDTH => CTR_WIDTH )
      PORT MAP (
         CData0    => CtrData0(CTR_WIDTH*(i+1)-1 DOWNTO CTR_WIDTH*i),
         CntEn     => CntEn,
         SIG       => SIG(i),
         clk       => clk,
         first_col => first_col,
         first_row => first_row,
         rst       => rst,
         CData1    => CtrData1(CTR_WIDTH*(i+1)-1 DOWNTO CTR_WIDTH*i)
      );
   --  hds hds_inst
    InstPMT : PMT_Input
      PORT MAP (
         PMT => PMTs(i),
         clk => clk,
         rst => rst,
         SIG => SIG(i)
      );
  end generate;
END ARCHITECTURE beh;

