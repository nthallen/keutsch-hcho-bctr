--
-- VHDL Architecture BCtr_lib.BCtr2_Addr.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 11:06:57 11/19/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BCtr2_Addr IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned(15 DOWNTO 0)     := X"0010"
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    BdEn     : OUT    std_logic;
    BdWrEn   : OUT    std_logic;
    C_Dbar   : OUT    std_logic;
    CfgAddr  : OUT    unsigned (3 DOWNTO 0);
    DataAddr : OUT    std_logic_vector (1 DOWNTO 0)
  );

-- Declarations

END ENTITY BCtr2_Addr ;

--
ARCHITECTURE beh OF BCtr2_Addr IS
BEGIN
  PROCESS (ExpAddr) IS
    VARIABLE offset : unsigned(ADDR_WIDTH-1 DOWNTO 0);
  BEGIN
    IF (resize(unsigned(ExpAddr),16) < BASE_ADDR OR
        resize(unsigned(ExpAddr),16) > BASE_ADDR+10) THEN
      BdEn <= '0';
      BdWrEn <= '0';
      C_Dbar <= '0';
      CfgAddr <= (others => '0');
      DataAddr <= (others => '0');
    ELSE
      BdEn <= '1';
      offset := unsigned(ExpAddr) - resize(BASE_ADDR,ADDR_WIDTH);
      CfgAddr <= offset(3 DOWNTO 0);
      DataAddr <= std_logic_vector(offset(1 DOWNTO 0));
      IF (offset < 3) THEN
        C_Dbar <= '0';
      ELSE
        C_Dbar <= '1';
      END IF;
      IF offset = 1 OR offset = 2 THEN
        BdWrEn <= '0';
      ELSE
        BdWrEn <= '1';
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

