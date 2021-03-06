-- VHDL Entity BCtr_lib.i2c_aio.symbol
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:37:10 12/12/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY i2c_aio IS
  GENERIC( 
    BASE_ADDR  : std_logic_vector(15 DOWNTO 0) := X"0050";
    ADDR_WIDTH : integer                       := 16
  );
  PORT( 
    ExpAddr  : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    ExpRd    : IN     std_logic;
    ExpWr    : IN     std_logic;
    clk      : IN     std_logic;
    idxData  : IN     std_logic_vector (15 DOWNTO 0);
    idxWr    : IN     std_logic;
    rst      : IN     std_logic;
    scl_i    : IN     std_logic;
    sda_i    : IN     std_logic;
    wData    : IN     std_logic_vector (15 DOWNTO 0);
    ExpAck   : OUT    std_logic;
    htr1_cmd : OUT    std_logic;
    htr2_cmd : OUT    std_logic;
    idxAck   : OUT    std_logic;
    rData    : OUT    std_logic_vector (15 DOWNTO 0);
    scl_o    : OUT    std_logic;
    sda_o    : OUT    std_logic
  );

-- Declarations

END ENTITY i2c_aio ;

--
-- VHDL Architecture BCtr_lib.i2c_aio.struct
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 10:37:10 12/12/2017
--
-- Generated by Mentor Graphics' HDL Designer(TM) 2016.1 (Build 8)
--

-- Generation properties:
--   Component declarations : yes
--   Configurations         : embedded statements
--                          : add pragmas
--                          : exclude view name
--   
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- LIBRARY BCtr_lib;

ARCHITECTURE struct OF i2c_aio IS

  -- Architecture declarations

  -- Internal signal declarations
  SIGNAL BdEn      : std_logic;
  SIGNAL BdWrEn    : std_logic;
  SIGNAL ChanAddr2 : std_logic_vector(1 DOWNTO 0);
  SIGNAL Done      : std_logic;
  SIGNAL Err       : std_logic;
  SIGNAL IdxWrAck  : std_logic;
  SIGNAL Rd        : std_logic;
  SIGNAL RdAddr    : std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL RdEn      : std_logic;
  SIGNAL RdStat    : std_logic;
  SIGNAL Start     : std_logic;
  SIGNAL Stop      : std_logic;
  SIGNAL Timeout   : std_logic;
  SIGNAL Wr        : std_logic;
  SIGNAL WrAck2    : std_logic;
  SIGNAL WrAddr1   : std_logic_vector(ADDR_WIDTH-1 DOWNTO 0);
  SIGNAL WrEn      : std_logic;
  SIGNAL WrEn1     : std_logic;
  SIGNAL WrEn2     : std_logic;
  SIGNAL WrRdy1    : std_logic;
  SIGNAL dpRdEn    : std_logic;
  SIGNAL i2c_rdata : std_logic_vector(7 DOWNTO 0);
  SIGNAL i2c_wdata : std_logic_vector(7 DOWNTO 0);
  SIGNAL wData1    : std_logic_vector(15 DOWNTO 0);
  SIGNAL wData2    : std_logic_vector(15 DOWNTO 0);
  SIGNAL wb_ack_o  : std_logic;
  SIGNAL wb_adr_i  : std_logic_vector(2 DOWNTO 0);
  SIGNAL wb_cyc_i  : std_logic;
  SIGNAL wb_dat_i  : std_logic_vector(7 DOWNTO 0);
  SIGNAL wb_dat_o  : std_logic_vector(7 DOWNTO 0);
  SIGNAL wb_inta_o : std_logic;
  SIGNAL wb_stb_i  : std_logic;
  SIGNAL wb_we_i   : std_logic;


  -- Component Declarations
  COMPONENT aio_acq
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 16
  );
  PORT (
    ChanAddr2 : IN     std_logic_vector (1 DOWNTO 0);
    Done      : IN     std_logic ;
    Err       : IN     std_logic ;
    WrEn2     : IN     std_logic ;
    WrRdy1    : IN     std_logic ;
    clk       : IN     std_logic ;
    i2c_rdata : IN     std_logic_vector (7 DOWNTO 0);
    rst       : IN     std_logic ;
    wData2    : IN     std_logic_vector (15 DOWNTO 0);
    Rd        : OUT    std_logic ;
    Start     : OUT    std_logic ;
    Stop      : OUT    std_logic ;
    Wr        : OUT    std_logic ;
    WrAck2    : OUT    std_logic ;
    WrAddr1   : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WrEn1     : OUT    std_logic ;
    i2c_wdata : OUT    std_logic_vector (7 DOWNTO 0);
    wData1    : OUT    std_logic_vector (15 DOWNTO 0);
    htr1_cmd  : OUT    std_logic ;
    htr2_cmd  : OUT    std_logic ;
    RdStat    : IN     std_logic ;
    Timeout   : IN     std_logic ;
    IdxWrAck  : OUT    std_logic 
  );
  END COMPONENT aio_acq;
  COMPONENT aio_addr
  GENERIC (
    BASE_ADDR  : std_logic_vector(15 DOWNTO 0) := X"0050";
    ADDR_WIDTH : integer range 16 downto 8     := 8
  );
  PORT (
    ExpAddr   : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    RdEn      : IN     std_logic ;
    WrAck2    : IN     std_logic ;
    WrEn      : IN     std_logic ;
    clk       : IN     std_logic ;
    wData     : IN     std_logic_vector (15 DOWNTO 0);
    ChanAddr2 : OUT    std_logic_vector (1 DOWNTO 0);
    RdAddr    : OUT    std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WrEn2     : OUT    std_logic ;
    dpRdEn    : OUT    std_logic ;
    wData2    : OUT    std_logic_vector (15 DOWNTO 0);
    RdStat    : OUT    std_logic ;
    rst       : IN     std_logic ;
    BdEn      : OUT    std_logic ;
    BdWrEn    : OUT    std_logic ;
    idxData   : IN     std_logic_vector (15 DOWNTO 0);
    idxWr     : IN     std_logic ;
    idxAck    : OUT    std_logic ;
    IdxWrAck  : IN     std_logic 
  );
  END COMPONENT aio_addr;
  COMPONENT aio_dpram
  GENERIC (
    ADDR_WIDTH : integer range 16 downto 8 := 16;
    MEM_SIZE   : integer                   := 16;
    WORD_SIZE  : integer                   := 16
  );
  PORT (
    RdAddr : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    RdEn   : IN     std_logic ;
    WrAddr : IN     std_logic_vector (ADDR_WIDTH-1 DOWNTO 0);
    WrEn   : IN     std_logic ;
    clk    : IN     std_ulogic ;
    rst    : IN     std_ulogic ;
    wData  : IN     std_logic_vector (WORD_SIZE-1 DOWNTO 0);
    WrRdy  : OUT    std_logic ;
    rData  : OUT    std_logic_vector (WORD_SIZE-1 DOWNTO 0)
  );
  END COMPONENT aio_dpram;
  COMPONENT aio_i2c
  PORT (
    rst          : IN     std_ulogic ;
    wb_adr_i     : IN     std_logic_vector (2 DOWNTO 0);
    wb_cyc_i     : IN     std_logic ;
    wb_dat_i     : IN     std_logic_vector (7 DOWNTO 0);
    wb_stb_i     : IN     std_logic ;
    wb_we_i      : IN     std_logic ;
    scl_pad_i    : IN     std_logic ;
    scl_pad_o    : OUT    std_logic ;
    scl_padoen_o : OUT    std_logic ;
    sda_pad_i    : IN     std_logic ;
    sda_pad_o    : OUT    std_logic ;
    sda_padoen_o : OUT    std_logic ;
    wb_ack_o     : OUT    std_logic ;
    wb_dat_o     : OUT    std_logic_vector (7 DOWNTO 0);
    wb_inta_o    : OUT    std_logic ;
    clk          : IN     std_ulogic 
  );
  END COMPONENT aio_i2c;
  COMPONENT aio_txn
  GENERIC (
    I2C_CLK_PRESCALE : std_logic_vector (15 DOWNTO 0) := X"000E"
  );
  PORT (
    Rd        : IN     std_logic ;
    Start     : IN     std_logic ;
    Stop      : IN     std_logic ;
    Wr        : IN     std_logic ;
    clk       : IN     std_ulogic ;
    i2c_wdata : IN     std_logic_vector (7 DOWNTO 0);
    rst       : IN     std_ulogic ;
    wb_ack_o  : IN     std_logic ;
    wb_dat_o  : IN     std_logic_vector (7 DOWNTO 0);
    wb_inta_o : IN     std_logic ;
    Done      : OUT    std_logic ;
    Err       : OUT    std_logic ;
    Timeout   : OUT    std_logic ;
    i2c_rdata : OUT    std_logic_vector (7 DOWNTO 0);
    wb_adr_i  : OUT    std_logic_vector (2 DOWNTO 0);
    wb_cyc_i  : OUT    std_logic ;
    wb_dat_i  : OUT    std_logic_vector (7 DOWNTO 0);
    wb_stb_i  : OUT    std_logic ;
    wb_we_i   : OUT    std_logic 
  );
  END COMPONENT aio_txn;
  COMPONENT subbus_io
  GENERIC (
    USE_BD_WR_EN : std_logic := '0'
  );
  PORT (
    BdEn   : IN     std_logic;
    BdWrEn : IN     std_logic;
    ExpRd  : IN     std_logic;
    ExpWr  : IN     std_logic;
    F8M    : IN     std_logic;
    ExpAck : OUT    std_logic;
    RdEn   : OUT    std_logic;
    WrEn   : OUT    std_logic
  );
  END COMPONENT subbus_io;

  -- Optional embedded configurations
  -- pragma synthesis_off
-- FOR ALL : aio_acq USE ENTITY BCtr_lib.aio_acq;
-- FOR ALL : aio_addr USE ENTITY BCtr_lib.aio_addr;
-- FOR ALL : aio_dpram USE ENTITY BCtr_lib.aio_dpram;
-- FOR ALL : aio_i2c USE ENTITY BCtr_lib.aio_i2c;
-- FOR ALL : aio_txn USE ENTITY BCtr_lib.aio_txn;
-- FOR ALL : subbus_io USE ENTITY BCtr_lib.subbus_io;
  -- pragma synthesis_on


BEGIN

  -- Instance port mappings.
  acq : aio_acq
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH
    )
    PORT MAP (
      ChanAddr2 => ChanAddr2,
      Done      => Done,
      Err       => Err,
      WrEn2     => WrEn2,
      WrRdy1    => WrRdy1,
      clk       => clk,
      i2c_rdata => i2c_rdata,
      rst       => rst,
      wData2    => wData2,
      Rd        => Rd,
      Start     => Start,
      Stop      => Stop,
      Wr        => Wr,
      WrAck2    => WrAck2,
      WrAddr1   => WrAddr1,
      WrEn1     => WrEn1,
      i2c_wdata => i2c_wdata,
      wData1    => wData1,
      htr1_cmd  => htr1_cmd,
      htr2_cmd  => htr2_cmd,
      RdStat    => RdStat,
      Timeout   => Timeout,
      IdxWrAck  => IdxWrAck
    );
  addr : aio_addr
    GENERIC MAP (
      BASE_ADDR  => BASE_ADDR,
      ADDR_WIDTH => ADDR_WIDTH
    )
    PORT MAP (
      ExpAddr   => ExpAddr,
      RdEn      => RdEn,
      WrAck2    => WrAck2,
      WrEn      => WrEn,
      clk       => clk,
      wData     => wData,
      ChanAddr2 => ChanAddr2,
      RdAddr    => RdAddr,
      WrEn2     => WrEn2,
      dpRdEn    => dpRdEn,
      wData2    => wData2,
      RdStat    => RdStat,
      rst       => rst,
      BdEn      => BdEn,
      BdWrEn    => BdWrEn,
      idxData   => idxData,
      idxWr     => idxWr,
      idxAck    => idxAck,
      IdxWrAck  => IdxWrAck
    );
  dpram : aio_dpram
    GENERIC MAP (
      ADDR_WIDTH => ADDR_WIDTH,
      MEM_SIZE   => 7,
      WORD_SIZE  => 16
    )
    PORT MAP (
      RdAddr => RdAddr,
      RdEn   => dpRdEn,
      WrAddr => WrAddr1,
      WrEn   => WrEn1,
      clk    => clk,
      rst    => rst,
      wData  => wData1,
      WrRdy  => WrRdy1,
      rData  => rData
    );
  i2c : aio_i2c
    PORT MAP (
      rst          => rst,
      wb_adr_i     => wb_adr_i,
      wb_cyc_i     => wb_cyc_i,
      wb_dat_i     => wb_dat_i,
      wb_stb_i     => wb_stb_i,
      wb_we_i      => wb_we_i,
      scl_pad_i    => scl_i,
      scl_pad_o    => OPEN,
      scl_padoen_o => scl_o,
      sda_pad_i    => sda_i,
      sda_pad_o    => OPEN,
      sda_padoen_o => sda_o,
      wb_ack_o     => wb_ack_o,
      wb_dat_o     => wb_dat_o,
      wb_inta_o    => wb_inta_o,
      clk          => clk
    );
  txn : aio_txn
    GENERIC MAP (
      I2C_CLK_PRESCALE => X"00BC"
    )
    PORT MAP (
      Rd        => Rd,
      Start     => Start,
      Stop      => Stop,
      Wr        => Wr,
      clk       => clk,
      i2c_wdata => i2c_wdata,
      rst       => rst,
      wb_ack_o  => wb_ack_o,
      wb_dat_o  => wb_dat_o,
      wb_inta_o => wb_inta_o,
      Done      => Done,
      Err       => Err,
      Timeout   => Timeout,
      i2c_rdata => i2c_rdata,
      wb_adr_i  => wb_adr_i,
      wb_cyc_i  => wb_cyc_i,
      wb_dat_i  => wb_dat_i,
      wb_stb_i  => wb_stb_i,
      wb_we_i   => wb_we_i
    );
  subbus : subbus_io
    GENERIC MAP (
      USE_BD_WR_EN => '1'
    )
    PORT MAP (
      ExpRd  => ExpRd,
      ExpWr  => ExpWr,
      ExpAck => ExpAck,
      F8M    => clk,
      RdEn   => RdEn,
      WrEn   => WrEn,
      BdEn   => BdEn,
      BdWrEn => BdWrEn
    );

END ARCHITECTURE struct;
