library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_control is
	port (
		clk_50mhz : in std_logic; --entrada de reloj
		reset_btn : in std_logic; -- Entrada de reset
		sensor_data: in std_logic_vector(7 downto 0); -- Entrada del error desde read_sensor_state
		PWM_motorA: out std_logic_vector(6 downto 0); -- Salida del PWM del motor_A (izquierdo)
		PWM_motorB: out std_logic_vector(6 downto 0)); -- Salida del PWM del motor_B (derecho)
end entity;

architecture behave of pid_control is
begin
   -- PID control, define las salidas de los PWM de acuerdo con la lectura de los sensores
	process(clk_50mhz, reset_btn)
	variable error, pwm_motorAA, pwm_motorBB :integer;
	
	begin
		error := to_integer(signed(sensor_data(7 downto 0)));
	   if error > 0 then -- si el error es mayor a 0, giro a la izquierda
			pwm_motorAA := 20;
			pwm_motorBB := 100;
		elsif error < 0 then -- Si el error es menor a 0, giro a la derecha
			pwm_motorAA := 100;
			pwm_motorBB := 20;
		else -- Si no tenemos error sigo hacia delante
			pwm_motorAA := 100;
			pwm_motorBB := 100;
		end if;
		-- convierto los porcentajes de entero a std_logic_vector
		pwm_motorA <= std_logic_vector(to_signed(pwm_motorAA, 7)); 
		pwm_motorB <= std_logic_vector(to_signed(pwm_motorBB, 7));
	end process;
end behave;