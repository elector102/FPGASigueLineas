library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_control is
	generic(
		--- Parametro del controlador PID ---
		KP               : integer :=  20 ;
		KI               : integer :=  0 ;
		KD               : integer :=  0 );
	port (
	   --- Entrada de reloj ---
		clk_50mhz : in std_logic;
		--- Entrada de reset ---
		reset_btn : in std_logic; 
		--- Entrada del error desde read_sensor_state ---
		sensor_data: in std_logic_vector(7 downto 0); 
		PID_value : OUT integer range -500 to 500);
end entity;

architecture behave of pid_control is
begin
	process(sensor_data)
	variable proportional, integral, derivative :integer :=0;
	variable last_proportional : integer :=0;
	
	begin
		if reset_btn = '0' then 
			proportional := to_integer(signed(sensor_data(7 downto 0)));
			integral := proportional + last_proportional;
			derivative := proportional - last_proportional;
			--limitamos la integral para no causar problemas
			if (integral > 100) then 
				integral := 100; 
			end if;
			if (integral < -100) then 
				integral := -100;
			end if;
			PID_value <= ( proportional * KP ) + ( derivative * KD ) + (integral * KI);
			last_proportional := proportional;
		else
			last_proportional := 0;
			PID_value <= 0;
		end if;
	end process;
end architecture;
