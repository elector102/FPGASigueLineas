-- Decod Hexa a 7 segmentos
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY Deco IS
PORT (
		Hex : in std_logic_vector (3 downto 0) ;
		Seg7 : out std_logic_vector (6 downto 0));
END Deco ;

ARCHITECTURE Behavior OF Deco IS

BEGIN

	WITH Hex SELECT
	Seg7 <=  "1000000" when "0000", -- 0  gfedcba
			"1111001" when "0001", -- 1
			"0100100" when "0010", -- 2
			"0110000" when "0011", -- 3
			"0011001" when "0100", -- 4
			"0010010" when "0101", -- 5
			"0000010" when "0110", -- 6
			"1111000" when "0111", -- 7
			"0000000" when "1000", -- 8
			"0010000" when "1001", -- 9
			"1111111" when others; -- 				
			
END Behavior ;