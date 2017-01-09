--
-- VHDL Architecture BCtr_lib.BCtrSum.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:51:38 10/19/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY BCtrSum IS
   GENERIC( 
      CTR_WIDTH : integer range 32 downto 1 := 16
   );
   PORT( 
      CData0    : IN     std_logic_vector (CTR_WIDTH-1 DOWNTO 0);
      CntEn     : IN     std_logic;
      SIG       : IN     std_logic;
      clk       : IN     std_logic;
      first_col : IN     std_logic;
      first_row : IN     std_logic;
      rst       : IN     std_logic;
      CData1    : OUT    std_logic_vector (CTR_WIDTH-1 DOWNTO 0)
   );

-- Declarations

END BCtrSum ;

--
ARCHITECTURE beh OF BCtrSum IS
  SIGNAL CurSum : std_logic_vector(CTR_WIDTH-1 DOWNTO 0);
BEGIN
  Sum : PROCESS (clk)
    variable Addend : std_logic_vector(CTR_WIDTH-1 DOWNTO 0);
    variable Inc : std_logic;
  BEGIN
    if clk'Event AND clk = '1' then
      if rst = '1' then
        CurSum <= (others => '0');
      else
        if CntEn = '1' AND SIG = '1' then
          Inc := '1';
        else
          Inc := '0';
        end if;
        if first_col = '1' then
          if first_row = '1' then
            Addend := (others => '0');
          else
            Addend := CData0;
          end if;
        else
          Addend := CurSum;
        end if;
        CurSum <= Addend + Inc;
      end if;
    end if;
  END PROCESS Sum;
  
  CData1 <= CurSum;
END ARCHITECTURE beh;

