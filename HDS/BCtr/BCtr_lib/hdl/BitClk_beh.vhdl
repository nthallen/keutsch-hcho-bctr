--
-- VHDL Architecture BCtr_lib.BitClk.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 19:27:04 10/ 7/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY BitClk IS
  GENERIC (
    TRIG_POS : boolean := true;
    TRIG_NEG : boolean := true
  );
  PORT ( PMT, PMT_EN, OE, CLR: IN std_logic;
         Q: OUT std_logic );
END BitClk ;

--
ARCHITECTURE beh OF BitClk IS
  SIGNAL FDQP : std_logic;
  SIGNAL FDQN : std_logic;
BEGIN

  positive: IF TRIG_POS GENERATE
    pos_trig: PROCESS (PMT, CLR)
    BEGIN
      IF CLR = '1' THEN
        FDQP <= '0';
      ELSE
        IF PMT = '1' AND PMT'event THEN
          IF PMT_EN = '1' THEN
            FDQP <= '1';
          END IF;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE positive;
  
  not_positive: IF TRIG_POS = false GENERATE
    FDQP <= '0';
  END GENERATE not_positive;

  negative: IF TRIG_NEG GENERATE
    neg_trig: PROCESS (PMT, CLR)
    BEGIN
      IF CLR = '1' THEN
        FDQN <= '0';
      ELSE
        IF PMT = '0' AND PMT'event THEN
          IF PMT_EN = '1' THEN
            FDQN <= '1';
          END IF;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE negative;
  
  not_negative: IF TRIG_NEG = false GENERATE
    FDQN <= '0';
  END GENERATE;

  PROCESS (FDQP, FDQN, OE)
  BEGIN
    IF OE = '1' AND (FDQP = '1' OR FDQN = '1') THEN
      Q <= '1';
    ELSE
      Q <= '0';
    END IF;
  END PROCESS;
END ARCHITECTURE beh;

