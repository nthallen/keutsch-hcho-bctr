--
-- VHDL Architecture BCtr_lib.BitClk.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 19:27:04 10/ 7/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY BitClk IS
  PORT ( PMT, PMT_EN, OE, CLR: IN std_logic;
         Q: OUT std_logic );
END BitClk ;

--
ARCHITECTURE beh OF BitClk IS
  SIGNAL FDQ : std_logic;
BEGIN

  PROCESS (PMT, PMT_EN, CLR)
  BEGIN
    FDQ <= '0';
    
    IF CLR = '1' THEN
      FDQ <= '0';
    ELSIF PMT_EN = '1' AND PMT = '1' AND PMT'event THEN
      FDQ <= '1';
    ELSE
      FDQ <= FDQ;
    END IF;
  END PROCESS;

  PROCESS (FDQ, OE)
  BEGIN
    IF OE = '1' THEN
      Q <= FDQ;
    ELSE
      Q <= '0';
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

