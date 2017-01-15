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
      clk : IN     std_logic;
      EN1 : OUT    std_logic;
      EN2 : OUT    std_logic;
      EN3 : OUT    std_logic;
      rst : IN     std_logic
   );

-- Declarations

END TriEn ;

--
ARCHITECTURE beh OF TriEn IS
	TYPE type_sreg IS (INIT,S1,S2,S3);
	SIGNAL sreg : type_sreg;
BEGIN
	PROCESS (CLK)
	BEGIN
		IF CLK='1' AND CLK'event THEN
		  IF ( rst='1' ) THEN
		    sreg <= INIT;
		    EN1 <= '1';
		    EN2 <= '1';
		    EN3 <= '1';
      ELSE
    			 CASE sreg IS
      				WHEN INIT =>
      	 				sreg <= S1;
      				WHEN S1 =>
       					sreg <= S2;
      		    EN1 <= '1';
      		    EN2 <= '0';
      		    EN3 <= '0';
      				WHEN S2 =>
      					sreg <= S3;
      		    EN1 <= '0';
      		    EN2 <= '1';
      		    EN3 <= '0';
      				WHEN S3 =>
      					sreg <= S1;
      		    EN1 <= '0';
      		    EN2 <= '0';
      		    EN3 <= '1';
      				WHEN OTHERS =>
      			   sreg <= INIT;
      		    EN1 <= '1';
      		    EN2 <= '1';
      		    EN3 <= '1';
      		END CASE;
      END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE beh;

