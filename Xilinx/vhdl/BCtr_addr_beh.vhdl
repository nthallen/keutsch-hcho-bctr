--
-- VHDL Architecture BCtr_lib.BCtr_addr.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 09:32:56 01/10/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr_addr IS
   GENERIC( 
      ADDR_WIDTH : integer range 16 downto 8 := 8;
      BASE_ADDR  : unsigned(15 DOWNTO 0)     := X"0010"
   );
   PORT( 
      ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
      BdEn     : OUT    std_logic;
      C_Dbar   : OUT    std_logic;
      CfgAddr  : OUT    unsigned (3 DOWNTO 0);
      DataAddr : OUT    unsigned (1 DOWNTO 0);
      BdWrEn   : OUT    std_logic
   );

-- Declarations

END BCtr_addr ;

--
ARCHITECTURE beh OF BCtr_addr IS
BEGIN
  PROCESS (ExpAddr) IS
    VARIABLE offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    IF (resize(unsigned(ExpAddr),16) < BASE_ADDR OR
        resize(unsigned(ExpAddr),16) > BASE_ADDR+12) THEN
      BdEn <= '0';
      C_Dbar <= '0';
      CfgAddr <= (others => '0');
      DataAddr <= (others => '0');
    ELSE
      BdEn <= '1';
      offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
      CfgAddr <= offset(3 DOWNTO 0);
      DataAddr <= unsigned(offset(1 DOWNTO 0));
      IF (offset < 3) THEN
        C_Dbar <= '0';
      ELSE
        C_Dbar <= '1';
      END IF;
    END IF;
  END PROCESS;

  BdWrEn <= '0';
END ARCHITECTURE beh;

