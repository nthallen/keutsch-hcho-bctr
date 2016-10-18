--
-- VHDL Architecture BCtr_lib.TriEn.beh
--
-- Created:
--          by - nort.UNKNOWN (NORT-XPS14)
--          at - 19:28:22 10/ 7/2016
--
-- using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY TriEn IS
   PORT( 
      clk     : IN     std_logic;
      EN1     : OUT    std_logic;
      EN2     : OUT    std_logic;
      EN3     : OUT    std_logic;
      PMT_clr : IN     std_logic
   );

-- Declarations

END TriEn ;

--
ARCHITECTURE beh OF TriEn IS
	TYPE type_sreg IS (INIT,S1,S2,S3);
	SIGNAL sreg, next_sreg : type_sreg;
BEGIN
	PROCESS (CLK, next_sreg)
	BEGIN
		IF CLK='1' AND CLK'event THEN
			sreg <= next_sreg;
		END IF;
	END PROCESS;

	PROCESS (sreg,PMT_clr)
	BEGIN

		next_sreg<=INIT;

		IF ( PMT_clr='1' ) THEN
			next_sreg<=INIT;
		ELSE
			CASE sreg IS
				WHEN INIT =>
					next_sreg<=S1;
				WHEN S1 =>
					next_sreg<=S2;
				WHEN S2 =>
					next_sreg<=S3;
				WHEN S3 =>
					next_sreg<=S1;
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;

	PROCESS (sreg)
	BEGIN
		IF ((  (sreg=INIT)) OR (  (sreg=S1))) THEN EN1<='1';
		ELSE EN1<='0';
		END IF;
	END PROCESS;

	PROCESS (sreg)
	BEGIN
		IF ((  (sreg=INIT)) OR (  (sreg=S2))) THEN EN2<='1';
		ELSE EN2<='0';
		END IF;
	END PROCESS;

	PROCESS (sreg)
	BEGIN
		IF ((  (sreg=INIT)) OR (  (sreg=S3))) THEN EN3<='1';
		ELSE EN3<='0';
		END IF;
	END PROCESS;
END ARCHITECTURE beh;

