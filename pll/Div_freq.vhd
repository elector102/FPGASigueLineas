-- Divisor de frecuencias a partir de CLK de 2 kHZ
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY Div_freq IS
PORT (
		CLK : in std_logic;
		Y_motor : out std_logic;
		Y_ADC : out std_logic;
		Y_portserie : out std_logic);
--Frecuencias para simulacion	-- Cant de semiperiodos
--	constant TMax_0 : natural := 2;
--	constant TMax_1 : natural := 5;
--	constant TMax_2 : natural := 10;
--	constant TMax_3 : natural := 20;
--	constant TMax_4 : natural := 100;
	
--Frecuencias Reales
	constant TMax_0 : natural := 70;
	constant TMax_1 : natural := 1;
	constant TMax_2 : natural := 1000;
	constant TMax_3 : natural := 2000;
	constant TMax_4 : natural := 10000;
END Div_freq ;

ARCHITECTURE Behavior OF Div_freq IS
signal YY : std_logic_vector (4 downto 0):="11111";
BEGIN	
	Process (CLK) 
	variable A0,A1,A2,A3,A4: natural :=0;
--	variable YY : std_logic_vector (4 downto 0) :="11111";
		begin
		if (rising_edge(CLK)) then
			A0:=A0+1;
			A1:=A1+1;
			A2:=A2+1;
			A3:=A3+1;
			A4:=A4+1;		
			if (A0=TMax_0) then -- 5 hz
				A0:=0;
				YY(0)<=not(YY(0));
			end if;
			if (A1=TMax_1) then -- 2 hz
				A1:=0;
				YY(1)<=not(YY(1));
			end if;
			if (A2=TMax_2) then -- 1 hz
				A2:=0;
				YY(2)<=not(YY(2));
			end if;
			if (A3=TMax_3) then -- 0.5 hz
				A3:=0;
				YY(3)<=not(YY(3));
			end if;
			if (A4=TMax_4) then -- 0.1 hz
				A4:=0;
				YY(4)<=not(YY(4));
			end if;			
		end if;
		end process;
		Y_motor <= YY(0);
		Y_ADC <= YY(1);
		Y_portserie <=YY(2);
END Behavior ;