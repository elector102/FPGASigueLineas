library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_pid_error is
	generic(
		--- threshold value between black and white --
		threshold_value    : integer :=  1900 );
	port (
		sensor_data	: out std_logic_vector(7 downto 0);
		sensor_state	: out std_logic_vector(7 downto 0);
		CLK_50M		: in std_logic;
		reset			: in std_logic;

		--- Datos de entrada ADC ---
		ADC_CH0  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH1  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH2  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH3  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH4  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH5  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH6  :  IN INTEGER RANGE 0 TO 4095;
		ADC_CH7  :  IN INTEGER RANGE 0 TO 4095);
end entity;

architecture main of adc_pid_error is

signal sensor: std_logic_vector(7 downto 0);
begin	

	process(ADC_CH0, ADC_CH1, ADC_CH2, ADC_CH3, ADC_CH4, ADC_CH5)
		begin
			if reset = '1' then
				if (ADC_CH0 > threshold_value) then --Negro
					sensor(0) <= '0';
				else
					sensor(0) <= '1';
				end if;
				if (ADC_CH1 > threshold_value) then -- Negro
					sensor(1) <= '0';
				else
					sensor(1) <= '1';
				end if;
				if (ADC_CH2 > threshold_value) then -- Blanco
					sensor(2) <= '0';
				else
					sensor(2) <= '1';
				end if;
				if (ADC_CH3 > threshold_value) then -- Blanco
					sensor(3) <= '0';
				else
					sensor(3) <= '1';
				end if;
				if (ADC_CH4 > threshold_value) then -- Negro
					sensor(4) <= '0';
				else
					sensor(4) <= '1';
				end if;
				if (ADC_CH5 > threshold_value) then -- Negro
					sensor(5) <= '0';
				else
					sensor(5) <= '1';
				end if;
			else
				sensor(0) <= '1';
				sensor(1) <= '1';
				sensor(2) <= '1';
				sensor(3) <= '1';
				sensor(4) <= '1';
				sensor(5) <= '1';
			end if;
			sensor_state(0) <= sensor(0);
			sensor_state(1) <= sensor(1);
			sensor_state(2) <= sensor(2);
			sensor_state(3) <= sensor(3);
			sensor_state(4) <= sensor(4);
			sensor_state(5) <= sensor(5);
			sensor_state(6) <= sensor(6);
			sensor_state(7) <= sensor(7);
	end process;
	
	process(sensor, reset)
		variable error : integer:= 0;-- Variable error
		begin
		   if reset = '1' then
				if (sensor(0) = '0') and (sensor(1) = '1') then-- negro y blanco
					error := - 10;
				elsif (sensor(0) = '0') and (sensor(1) = '0') then-- negro y negro
					error := - 8;
				elsif (sensor(1) = '0') and (sensor(2) = '1') then-- negro y blanco
					error := - 6;
				elsif (sensor(1) = '0') and (sensor(2) = '0') then-- negro y negro
					error := - 4;
				elsif (sensor(2) = '0') and (sensor(3) = '1') then-- negro y negro
					error := - 2;
				elsif (sensor(2) = '0') and (sensor(3) = '0') then-- negro y negro
					error := 0;
				elsif (sensor(3) = '0') and (sensor(4) = '1') then-- negro y negro
					error := 2;
				elsif (sensor(3) = '0') and (sensor(4) = '0') then-- negro y negro
					error := 4;
				elsif (sensor(4) = '0') and (sensor(5) = '1') then-- negro y negro
					error := 6;
				elsif (sensor(4) = '0') and (sensor(5) = '0') then-- negro y negro
					error := 8;
				elsif (sensor(4) = '1') and (sensor(5) = '0') then-- negro y negro
					error := 10;
				end if;
			else
				error := 0;
			end if;
			
			sensor_data <= std_logic_vector(to_signed(error, 8));
	end process;
end architecture;