--
-- VHDL Architecture idx_fpga_lib.temp_addr.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:05:19 05/ 7/2015
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
-- Acknowledge 6*3 addresses, but require sequential reading
-- within a specific sensor.
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY temp_addr IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8;
    BASE_ADDR  : unsigned (15 DOWNTO 0)    := X"0000"
  );
  PORT( 
    Addr   : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd  : IN     std_logic;
    rst    : IN     std_logic;
    BdEn   : OUT    std_logic;
    Sensor : OUT    std_logic_vector (2 DOWNTO 0);
    Word   : OUT    std_logic_vector (1 DOWNTO 0);
    clk    : IN     std_logic
  );

-- Declarations

END ENTITY temp_addr ;

--
ARCHITECTURE beh OF temp_addr IS
  SIGNAL Cur_Sensor : std_logic_vector(2 DOWNTO 0);
  SIGNAL Pos_Sensor : std_logic_vector(2 DOWNTO 0);
  SIGNAL Pos_Word : std_logic_vector(1 DOWNTO 0);
  SIGNAL BdEn_int : std_logic;
  CONSTANT BASE_ADDR_U : unsigned(ADDR_WIDTH-1 DOWNTO 0) := BASE_ADDR(ADDR_WIDTH-1 DOWNTO 0);
BEGIN
  BE : Process (Addr,Cur_Sensor) BEGIN
    BdEn_int <= '0';
    Pos_Sensor <= "111"; -- not a valid sensor
    Pos_Word <= "11"; -- not a valid word
    IF unsigned(Addr) >= BASE_ADDR_U THEN
      for i in 0 to 5 loop
        if unsigned(Addr) = BASE_ADDR_U + i*3 THEN
          BdEn_int <= '1';
          Pos_Sensor <= std_logic_vector(to_unsigned(i,3));
          Pos_Word <= "00";
        elsif unsigned(Addr) = BASE_ADDR_U + i*3 + 1 AND
             Cur_Sensor = std_logic_vector(to_unsigned(i,3)) THEN
          BdEn_int <= '1';
          Pos_Sensor <= std_logic_vector(to_unsigned(i,3));
          Pos_Word <= "01";
        elsif unsigned(Addr) = BASE_ADDR_U + i*3 + 2 AND
             Cur_Sensor = std_logic_vector(to_unsigned(i,3)) THEN
          BdEn_int <= '1';
          Pos_Sensor <= std_logic_vector(to_unsigned(i,3));
          Pos_Word <= "10";
        end if;
      end loop;
    END IF;
  END Process;
  
  CS : Process (clk) BEGIN
    IF clk'event AND clk = '1' THEN
      IF rst = '1' THEN
        Cur_Sensor <= "111"; -- not a valid sensor
        Word <= "11"; -- not a valid word
      ELSIF ExpRd = '1' AND BdEn_int = '1' THEN
        Cur_Sensor <= Pos_Sensor;
        Word <= Pos_Word;
      END IF;
    END IF;
  END Process;
  
  BdEn <= BdEn_int;
  Sensor <= Cur_Sensor;
END ARCHITECTURE beh;

