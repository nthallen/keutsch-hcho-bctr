--
-- VHDL Architecture BCtr_lib.temp_tap.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 19:28:47 01/24/2018
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY temp_tap IS
  GENERIC(
    BRD_SEL : integer range 1 to 6 := 2
  );
  PORT( 
    brd_num   : IN     std_logic_vector (2 DOWNTO 0);
    clk       : IN     std_logic;
    rd_data_o : IN     std_logic_vector (31 DOWNTO 0);
    rdy       : IN     std_logic;
    rst       : IN     std_logic;
    tap_ack   : IN     std_logic;
    tap_data  : OUT    std_logic_vector (31 DOWNTO 0);
    tap_rdy   : OUT    std_logic
  );

-- Declarations

END ENTITY temp_tap ;

--
ARCHITECTURE beh OF temp_tap IS
BEGIN
  tap_proc: process (clk) is
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        tap_data <= (others => '0');
        tap_rdy <= '0';
      elsif rdy = '1' and to_integer(unsigned(brd_num)) = BRD_SEL 
          and rd_data_o(31 downto 29) /= "001"
          and rd_data_o(31 downto 29) /= "110" then
        tap_data(31) <= rd_data_o(30);
        tap_data(30 downto 0) <= rd_data_o(30 downto 0);
        tap_rdy <= '1';
      elsif tap_ack = '1' then
        tap_rdy <= '0';
      end if;
    end if;
  end process;
END ARCHITECTURE beh;

