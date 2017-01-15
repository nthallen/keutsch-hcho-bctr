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

  PROCESS (PMT, CLR)
  BEGIN
    IF CLR = '1' THEN
      FDQ <= '0';
    ELSE
      IF PMT = '1' AND PMT'event THEN
        IF PMT_EN = '1' THEN
          FDQ <= '1';
        END IF;
      END IF;
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

