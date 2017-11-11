--
-- VHDL Architecture BCtr_lib.ips_sbbd_tester.rtl
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 08:55:27 11/10/2017
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ips_sbbd_tester IS
  GENERIC( 
    ADDR_WIDTH : integer range 16 downto 8 := 8
  );
  PORT( 
    ExpAck   : IN     std_logic;
    ExpAck1  : IN     std_logic;
    IPS      : IN     std_logic;
    RData    : IN     std_logic_vector (15 DOWNTO 0);
    ExpAddr  : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : OUT    std_logic;
    ExpReset : OUT    std_logic;
    ExpWr    : OUT    std_logic;
    WData    : OUT    std_logic_vector (15 DOWNTO 0);
    clk      : OUT    std_logic;
    PPS      : IN     std_logic
  );

-- Declarations

END ENTITY ips_sbbd_tester ;

--
ARCHITECTURE rtl OF ips_sbbd_tester IS
  SIGNAL SimDone       : std_logic;
  SIGNAL ReadData      : std_logic_vector(15 downto 0);
BEGIN

  f100m_clk : Process is
  Begin
    clk <= '0';
    -- pragma synthesis_off
    wait for 20 ns;
    while SimDone = '0' loop
      clk <= '1';
      wait for 5 ns;
      clk <= '0';
      wait for 5 ns;
    end loop;
    wait;
    -- pragma synthesis_on
  End Process;
  
  test_proc: Process is
    procedure sbwr(
        addr : IN std_logic_vector(15 DOWNTO 0);
        data : IN std_logic_vector(15 DOWNTO 0);
        AckExpected : std_logic ) is
    begin
      ExpAddr <= addr(ADDR_WIDTH-1 DOWNTO 0);
      WData <= data;
      -- pragma synthesis_off
      wait until clk'EVENT AND clk = '1';
      ExpWr <= '1';
      for i in 1 to 8 loop
        wait until clk'EVENT AND clk = '1';
      end loop;
      if AckExpected = '1' then
        assert ExpAck = '1' or ExpAck1 = '1'
         report "Expected Ack on write" severity error;
      else
        assert ExpAck = '0' and ExpAck1 = '0'
         report "Expected no Ack" severity error;
      end if;
      ExpWr <= '0';
      wait until clk'EVENT AND clk = '1';
      -- pragma synthesis_on
      return;
    end procedure sbwr;

    procedure sbrd(
        addr : IN std_logic_vector(15 DOWNTO 0) ) is
    begin
      ExpAddr <= addr(ADDR_WIDTH-1 DOWNTO 0);
      -- pragma synthesis_off
      wait until clk'EVENT AND clk = '1';
      ExpRd <= '1';
      for i in 1 to 8 loop
        wait until clk'EVENT AND clk = '1';
      end loop;
      assert ExpAck = '1' or ExpAck1 = '1'
       report "Expected Ack on sbrd" severity error;
      ReadData <= RData;
      ExpRd <= '0';
      wait until clk'EVENT AND clk = '1';
      -- pragma synthesis_on
      return;
    end procedure sbrd;
    
    variable adjust : unsigned(31 downto 0);
  Begin
    SimDone <= '0';
    ReadData <= (others => '0');
    ExpReset <= '1';
    ExpAddr <= (others => '0');
    WData <= (others => '0');
    ExpRd <= '0';
    ExpWr <= '0';
    -- pragma synthesis_off
    -- might need to reset the circuit here...
    wait until clk'Event and clk = '1';
    wait until clk'Event and clk = '1';
    ExpReset <= '0';
    wait until clk'Event and clk = '1';
    
    wait for 10 ms;
    --sbwr(x"0073", x"0100",'1');
    sbwr(x"0061", std_logic_vector(to_unsigned(300,16)),'1');
    wait for 3100 ms;
    
    adjust := to_unsigned((10**8)/2, adjust'length);
    sbwr(x"0064", std_logic_vector(adjust(15 downto 0)),'1');
    sbwr(x"0065", std_logic_vector(adjust(31 downto 16)),'1');
    
    wait until PPS = '1';
    wait for 1100 ms;

    SimDone <= '1';
    wait;
   -- pragma synthesis_on
  END PROCESS;


END ARCHITECTURE rtl;

