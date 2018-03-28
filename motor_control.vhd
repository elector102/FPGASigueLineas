library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity motor_control is
	generic(
	   --- definicion del PWM maximo que pueden tomar ---
		--- los valores de PWM ---
		MOTOR_MAX_PWM    : integer :=  99); 
	port (
	   --- Entrada de reset ---
		reset_btn : in std_logic;
		--- Entrada del error desde read_sensor_state ---
		PID_value: in integer range -500 to 500;
		--- Salida del PWM del motor_A (izquierdo) ---
		PWM_value_motor_left: out std_logic_vector(6 downto 0);
		--- Salida de polaridad del motor A(Izquierdo) ---
		motor_left_A	: out std_logic;
		motor_left_B	: out std_logic;
		--- Salida de polaridad del motor B(Derecho).
		motor_right_A	: out std_logic;
		motor_right_B	: out std_logic;
		--- Salida del PWM del motor_B (derecho) ---
		PWM_value_motor_right: out std_logic_vector(6 downto 0));
end entity;

architecture behave of motor_control is
begin
	process(PID_value, reset_btn)
	variable PWM_value_motor_left_buffer, PWM_value_motor_right_buffer : integer :=0;
	begin
		if reset_btn = '1' then
			if (PID_value < 0) then
				PWM_value_motor_left_buffer := MOTOR_MAX_PWM + PID_value;
				PWM_value_motor_right_buffer := MOTOR_MAX_PWM;
			elsif (PID_value > 0) then
				PWM_value_motor_left_buffer := MOTOR_MAX_PWM;
				PWM_value_motor_right_buffer := MOTOR_MAX_PWM - PID_value;
			else
				PWM_value_motor_left_buffer := MOTOR_MAX_PWM;
				PWM_value_motor_right_buffer := MOTOR_MAX_PWM;
			end if;
			
			if PWM_value_motor_left_buffer < 0 then
				PWM_value_motor_left_buffer := -PWM_value_motor_left_buffer;
				motor_left_A <= '0';
				motor_left_B <= '1';
				motor_right_A <= '1';
				motor_right_B <= '0';
			elsif PWM_value_motor_right_buffer < 0 then
				PWM_value_motor_right_buffer := -PWM_value_motor_right_buffer;
				motor_left_A <= '1';
				motor_left_B <= '0';
				motor_right_A <= '0';
				motor_right_B <= '1';
			else
				motor_left_A <= '1';
				motor_left_B <= '0';
				motor_right_A <= '1';
				motor_right_B <= '0';
			end if;
			
			
			if PWM_value_motor_left_buffer > MOTOR_MAX_PWM then
				PWM_value_motor_left_buffer := MOTOR_MAX_PWM;
			end if;
			if PWM_value_motor_right_buffer > MOTOR_MAX_PWM then
				PWM_value_motor_right_buffer := MOTOR_MAX_PWM;
			end if;
		else
				motor_left_A <= '1';
				motor_left_B <= '0';
				motor_right_A <= '1';
				motor_right_B <= '0';
				PWM_value_motor_left_buffer := 0;
				PWM_value_motor_right_buffer := 0;
		end if;

		PWM_value_motor_left <= std_logic_vector(to_unsigned(PWM_value_motor_left_buffer, 7)); 
		PWM_value_motor_right <= std_logic_vector(to_unsigned(PWM_value_motor_right_buffer, 7));
	end process;

end architecture;