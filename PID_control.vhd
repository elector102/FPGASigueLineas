library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pid_control is
	generic(
		KP               : integer :=  20 ;
		KI               : integer :=  0 ;
		KD               : integer :=  0 ;
		MOTOR_MAX_PWM    : integer :=  99); 
	port (
		clk_50mhz : in std_logic; --entrada de reloj
		reset_btn : in std_logic; -- Entrada de reset
		sensor_data: in std_logic_vector(7 downto 0); -- Entrada del error desde read_sensor_state
		PWM_motorA: out std_logic_vector(6 downto 0); -- Salida del PWM del motor_A (izquierdo)
		PWM_motorB: out std_logic_vector(6 downto 0); -- Salida del PWM del motor_B (derecho)
		motor_direcction : out integer range -1 to 1);
end entity;

architecture behave of pid_control is
begin
	process(sensor_data)
	variable proportional, integral, derivative, PWM_motorAA, PWM_motorBB, PID_value:integer :=0;
	variable last_proportional : integer :=0;
	
	
	begin
		proportional := to_integer(signed(sensor_data(7 downto 0)));
		integral := proportional + last_proportional;
		derivative := proportional - last_proportional;
		if (integral > 100) then 
			integral := 100; --limitamos la integral para no causar problemas
		end if;
      if (integral < -100) then 
			integral := -100;
		end if;
		
		PID_value := ( proportional * KP ) + ( derivative * KD ) + (integral * KI);
		if (PID_value < 0) then
			PWM_motorAA := MOTOR_MAX_PWM + PID_value;
			PWM_motorBB := MOTOR_MAX_PWM;
		elsif (PID_value > 0) then
			PWM_motorAA := MOTOR_MAX_PWM;
			PWM_motorBB := MOTOR_MAX_PWM - PID_value;
		else
			PWM_motorAA := MOTOR_MAX_PWM;
			PWM_motorBB := MOTOR_MAX_PWM;
		end if;
		
		if pwm_motorAA < 0 then
			pwm_motorAA := -pwm_motorAA;
			motor_direcction <= 1;
		elsif pwm_motorBB < 0 then
			pwm_motorBB := -pwm_motorBB;
			motor_direcction <= -1;
		else
			motor_direcction <= 0;
		end if;
		if pwm_motorAA > MOTOR_MAX_PWM then
			pwm_motorAA := MOTOR_MAX_PWM;
		end if;
		if pwm_motorBB > MOTOR_MAX_PWM then
			pwm_motorBB := MOTOR_MAX_PWM;
		end if;
		pwm_motorA <= std_logic_vector(to_unsigned(pwm_motorAA, 7)); 
		pwm_motorB <= std_logic_vector(to_unsigned(pwm_motorBB, 7));
		last_proportional := proportional;
	end process;
end architecture;



	
--------------------------------------------------------------------------------------------------------
	
--	PID_value <= 	MOTOR_MAX_PWM 		when PID_value > MOTOR_MAX_PWM 	else
--						- MOTOR_MAX_PWM 	when PID_value < -MOTOR_MAX_PWM 	else
--						PID_value;
--						
--	
--   PWM_motorAA <= MOTOR_MAX_PWMA + PID_value	when PID_value < 0	else
--						MOTOR_MAX_PWMA;
--	
--	PWM_motorBB <= MOTOR_MAX_PWMA - PID_value	when PID_value > 0	else
--						MOTOR_MAX_PWMA;
--						
--						
--   PWM_motorAA <= -PWM_motorAA when PWM_motorAA < 0 else
--						PWM_motorAA;
--	PWM_motorBB <= -PWM_motorBB when PWM_motorBB < 0 else
--						PWM_motorBB;
--
--	pwm_motorA <= std_logic_vector(to_unsigned(PWM_motorAA, 7)); 
--	pwm_motorB <= std_logic_vector(to_unsigned(PWM_motorBB, 7));
--end architecture;


--
--	begin
--		proportional := to_integer(signed(sensor_data(7 downto 0)));
--		integral := proportional + last_proportional;
--		derivative := proportional - last_proportional;
--		if (integral > 100) then 
--			integral := 100; --limitamos la integral para no causar problemas
--		end if;
--      if (integral < -100) then 
--			integral := -100;
--		end if;
--		
--		PID_value := ( proportional * KP ) + ( derivative * KD ) + (integral * KI);
--		
--		if (  PID_value > MOTOR_MAX_PWM ) then 
--			PID_value := MOTOR_MAX_PWM; --limitamos la salida de pwm
--		elsif ( PID_value < -MOTOR_MAX_PWM ) then
--			PID_value := -MOTOR_MAX_PWM;
--		end if;
----      PID_value := to_integer(signed(sensor_data(7 downto 0)));
--		if (PID_value < 0) then
--			PWM_motorAA := MOTOR_MAX_PWM + PID_value;
--			PWM_motorBB := MOTOR_MAX_PWM;
--		elsif (PID_value > 0) then
--			PWM_motorAA := MOTOR_MAX_PWM;
--			PWM_motorBB := MOTOR_MAX_PWM - PID_value;
--		else
--			PWM_motorAA := MOTOR_MAX_PWM;
--			PWM_motorBB := MOTOR_MAX_PWM;
--		end if;
--		if pwm_motorAA < 0 then
--			pwm_motorAA := pwm_motorAA * -1;
--		end if;
--		if pwm_motorBB < 0 then
--			pwm_motorBB := pwm_motorBB * -1;
--		end if;
--		if pwm_motorAA >100 then
--		pwm_motorA <= std_logic_vector(to_unsigned(pwm_motorAA, 7)); 
--		pwm_motorB <= std_logic_vector(to_unsigned(pwm_motorBB, 7));
--		last_proportional := proportional;
--	end process;
--end architecture;
		---------------------------------------------------------------------------------

--   -- PID control, define las salidas de los PWM de acuerdo con la lectura de los sensores
--	process(clk_50mhz, reset_btn)
--	variable error, pwm_motorAA, pwm_motorBB :integer;
--	
--	begin
--		error := to_integer(signed(sensor_data(7 downto 0)));
--		
--		
--	   if error > 0 then -- si el error es mayor a 0, giro a la izquierda
--			pwm_motorAA := 20;
--			pwm_motorBB := 100;
--		elsif error < 0 then -- Si el error es menor a 0, giro a la derecha
--			pwm_motorAA := 100;
--			pwm_motorBB := 20;
--		else -- Si no tenemos error sigo hacia delante
--			pwm_motorAA := 100;
--			pwm_motorBB := 100;
--		end if;
--		-- convierto los porcentajes de entero a std_logic_vector
--		pwm_motorA <= std_logic_vector(to_signed(pwm_motorAA, 7)); 
--		pwm_motorB <= std_logic_vector(to_signed(pwm_motorBB, 7));
--	end process;
--end behave;


-- void pid(int linea, int velocidad, float Kp, float Ki, float Kd)
--{
--  position = qtrrc.readLine(sensorValues, QTR_EMITTERS_ON, linea); //0 para linea negra, 1 para linea blanca
--  proporcional = (position) - 3500; // set point es 3500, asi obtenemos el error
--  integral=integral + proporcional_pasado; //obteniendo integral
--  derivativo = (proporcional - proporcional_pasado); //obteniedo el derivativo
--  if (integral>1000) integral=1000; //limitamos la integral para no causar problemas
--  if (integral<-1000) integral=-1000;
--  salida_pwm =( proporcional * Kp ) + ( derivativo * Kd )+(integral*Ki);
--   
--  if (  salida_pwm > velocidad )  salida_pwm = velocidad; //limitamos la salida de pwm
--  if ( salida_pwm < -velocidad )  salida_pwm = -velocidad;
--   
--  if (salida_pwm < 0)
-- {
--  motores(velocidad+salida_pwm, velocidad);
-- }
-- if (salida_pwm >0)
-- {
--  motores(velocidad, velocidad-salida_pwm);
-- }
-- 
-- proporcional_pasado = proporcional;  
--}
 