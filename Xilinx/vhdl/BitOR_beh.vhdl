--
-- VHDL Architecture BCtr_lib.BitOR.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 22:04:38 10/ 7/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY BitOR IS
  PORT( 
    Q1  : IN     std_logic;
    Q2  : IN     std_logic;
    Q3  : IN     std_logic;
    SIG : OUT    std_logic
  );

-- Declarations

END ENTITY BitOR ;

--
ARCHITECTURE beh OF BitOR IS
BEGIN
  PROCESS (Q1, Q2, Q3)
  BEGIN
    if (Q1 = '1' OR Q2 = '1' OR Q3 = '1') THEN
      SIG <= '1';
    ELSE
      SIG <= '0';
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

