-- VHDL Entity BCtr_lib.PMT_Input.symbol
--
-- Created:
--          by - nort.Domain Users (NORT-XPS14)
--          at - 15:49:43 10/19/16
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY PMT_Input IS
   PORT( 
      PMT : IN     std_logic;
      clk : IN     std_logic;
      rst : IN     std_logic;
      SIG : OUT    std_logic
   );

-- Declarations

END PMT_Input ;

--
-- VHDL Architecture BCtr_lib.PMT_Input.struct
--
-- Created:
--          by - nort.Domain Users (NORT-XPS14)
--          at - 15:49:43 10/19/16
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2013.1b (Build 2)
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

LIBRARY BCtr_lib;

ARCHITECTURE struct OF PMT_Input IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL EN1 : std_logic;
   SIGNAL EN2 : std_logic;
   SIGNAL EN3 : std_logic;
   SIGNAL Q1  : std_logic;
   SIGNAL Q2  : std_logic;
   SIGNAL Q3  : std_logic;


   -- Component Declarations
   COMPONENT BitClk
   PORT (
      CLR    : IN     std_logic;
      OE     : IN     std_logic;
      PMT    : IN     std_logic;
      PMT_EN : IN     std_logic;
      Q      : OUT    std_logic
   );
   END COMPONENT;
   COMPONENT BitOR
   PORT (
      Q1  : IN     std_logic ;
      Q2  : IN     std_logic ;
      Q3  : IN     std_logic ;
      SIG : OUT    std_logic 
   );
   END COMPONENT;
   COMPONENT TriEn
   PORT (
      clk : IN     std_logic ;
      EN1 : OUT    std_logic ;
      EN2 : OUT    std_logic ;
      EN3 : OUT    std_logic ;
      rst : IN     std_logic 
   );
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : BitClk USE ENTITY BCtr_lib.BitClk;
   FOR ALL : BitOR USE ENTITY BCtr_lib.BitOR;
   FOR ALL : TriEn USE ENTITY BCtr_lib.TriEn;
   -- pragma synthesis_on


BEGIN

   -- Instance port mappings.
   U_1 : BitClk
      PORT MAP (
         PMT    => PMT,
         PMT_EN => EN1,
         OE     => EN2,
         CLR    => EN3,
         Q      => Q1
      );
   U_2 : BitClk
      PORT MAP (
         PMT    => PMT,
         PMT_EN => EN2,
         OE     => EN3,
         CLR    => EN1,
         Q      => Q2
      );
   U_3 : BitClk
      PORT MAP (
         PMT    => PMT,
         PMT_EN => EN3,
         OE     => EN1,
         CLR    => EN2,
         Q      => Q3
      );
   U_4 : BitOR
      PORT MAP (
         Q1  => Q1,
         Q2  => Q2,
         Q3  => Q3,
         SIG => SIG
      );
   U_0 : TriEn
      PORT MAP (
         clk => clk,
         EN1 => EN1,
         EN2 => EN2,
         EN3 => EN3,
         rst => rst
      );

END struct;
