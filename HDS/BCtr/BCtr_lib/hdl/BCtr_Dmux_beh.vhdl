--
-- VHDL Architecture BCtr_lib.BCtr_Dmux.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:05:03 01/11/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_Dmux IS
   PORT( 
      CData  : IN     std_logic_vector (15 DOWNTO 0);
      C_Dbar : IN     std_logic;
      DData  : IN     std_logic_vector (15 DOWNTO 0);
      RData  : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END BCtr_Dmux ;

--
ARCHITECTURE beh OF BCtr_Dmux IS
BEGIN
  PROCESS (C_Dbar, CData, DData) IS
  BEGIN
    IF (C_Dbar = '1') THEN
      RData <= CData;
    ELSE
      RData <= DData;
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

