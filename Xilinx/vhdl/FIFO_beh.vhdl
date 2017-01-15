--
-- VHDL Architecture idx_fpga_lib.FIFO.beh
--
-- Created:
--          by - nort (NORT-NBX200T)
--          at - 13:31:18 08/21/2012
--
-- using Mentor Graphics HDL Designer(TM) 2012.1 (Build 6)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY FIFO IS
   GENERIC( 
      FIFO_WIDTH  : integer range 256 downto 1  := 1;
      FIFO_ADDR_WIDTH : integer range 10 downto 1 := 8
   );
   PORT( 
      WData : IN     std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
      WE    : IN     std_logic;
      RE    : IN     std_logic;
      Clk   : IN     std_ulogic;
      Rst   : IN     std_logic;
      RData : OUT    std_logic_vector (FIFO_WIDTH-1 DOWNTO 0);
      Empty : OUT    std_logic;
      Full  : OUT    std_logic
   );

END FIFO ;

-- Normal FIFO logic:
--   Head is where next write will go
--   Tail is where next read comes from
--   Head == Tail => Empty or Full
--   Cannot write when full
--   Cannot read when empty
--
ARCHITECTURE beh OF FIFO IS
  type FIFO_t is array (2**FIFO_ADDR_WIDTH-1 DOWNTO 0)
      of std_logic_vector(FIFO_WIDTH-1 DOWNTO 0);
  subtype FIFO_idx is std_logic_vector(FIFO_ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL FIFOdata : FIFO_t;
  SIGNAL Head, Tail : FIFO_idx;
  SIGNAL Full_int : std_logic;
  SIGNAL Empty_int : std_logic;
BEGIN
  action : Process (Clk) IS
    VARIABLE waddr : integer range 2**FIFO_ADDR_WIDTH-1 DOWNTO 0;
  BEGIN
    if Clk'Event AND Clk = '1' then
      if Rst = '1' then
        Full_int <= '0';
        Empty_int <= '1';
        Head <= (others => '0');
        Tail <= (others => '0');
        -- This is a little overkill:
        for i in 0 TO 2**FIFO_ADDR_WIDTH-1 loop
          FIFOdata(i) <= (others => '0');
        end loop;
      else
        if RE = '1' AND Empty_int = '0' then
          if Tail+1 = Head AND ( WE /= '1' OR Full_int = '1' ) then
            Empty_int <= '1';
          end if;
          if WE /= '1' OR Full_int = '1' then
            Full_int <= '0';
          end if;
          Tail <= Tail+1;
        end if;
        if WE = '1' AND Full_int = '0' then
          waddr := conv_integer(Head);
          FIFOdata(waddr) <= WData;
          if Head+1 = Tail AND (RE /= '1') then
            Full_int <= '1';
          end if;
          Empty_int <= '0';
          Head <= Head+1;
        end if;
      end if;
    end if;
  End Process;
  
  RData_proc: Process (FIFOdata, Tail) IS
    VARIABLE raddr : integer range 2**FIFO_ADDR_WIDTH-1 DOWNTO 0;
  Begin
    raddr := conv_integer(Tail);
    RData <= FIFOdata(raddr);
End Process;
  
  Full <= Full_int;
  Empty <= Empty_int;
      
END ARCHITECTURE beh;

