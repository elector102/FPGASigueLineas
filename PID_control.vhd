library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_control is
	port (
		clk_50mhz : in std_logic;
		reset_btn : in std_logic;
		sensor_data: in std_logic_vector(7 downto 0);
		PWM_motorA: out std_logic_vector(6 downto 0);
		PWM_motorB: out std_logic_vector(6 downto 0));
end entity;

architecture behave of pid_control is
signal clk_1hz : std_logic;
begin

	process(clk_50mhz, reset_btn)
	variable error, pwm_motorAA, pwm_motorBB :integer;
	
	begin
		error := to_integer(signed(sensor_data(7 downto 0)));
	   if error > 0 then
			pwm_motorAA := 0;
			pwm_motorBB := 100;
		elsif error < 0 then
			pwm_motorAA := 100;
			pwm_motorBB := 0;
		else
			pwm_motorAA := 100;
			pwm_motorBB := 100;
		end if;
		pwm_motorA <= std_logic_vector(to_signed(pwm_motorAA, 7));
		pwm_motorB <= std_logic_vector(to_signed(pwm_motorBB, 7));
	end process;
end behave;