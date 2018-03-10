library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adc_pid_error is 
	port (
	sensor_data	: out std_logic_vector(7 downto 0);
	sensor_state	: out std_logic_vector(7 downto 0);
	CLK_50M		: in std_logic;
	reset			: in std_logic;
   o_sclk      : out std_logic; -- Salida de sclk hacia el adc
   o_ss        : out std_logic; -- Salida de ss hacia el adc
   o_mosi      : out std_logic; -- salida mosi del adc
   i_miso      : in  std_logic);
end entity;

architecture main of adc_pid_error is

-- ADC conversion
component ADC is
port (	
	
	--- ADC Pins ---
	Clk      :  IN  STD_LOGIC;
	oDIN     :  OUT STD_LOGIC;
	oCS_n    :  OUT STD_LOGIC;
	oSCLK    :  OUT STD_LOGIC;
	iDOUT    :  IN  STD_LOGIC;
	
	--- ADC Datas ---
	ADC_CH0  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH1  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH2  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH3  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH4  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH5  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH6  :  OUT INTEGER RANGE 0 TO 4095;
	ADC_CH7  :  OUT INTEGER RANGE 0 TO 4095;
	
	--- Test Output ---
	TEST_OUT :  OUT STD_LOGIC  	
	
);
end component;
-- ADC signals
type BUFFER_DATAS is array (7 DOWNTO 0) of INTEGER RANGE 0 TO 4095;
signal ADC_BUF_CH : BUFFER_DATAS;
signal TEST_OUT_BUF  : STD_LOGIC;
signal sensor: std_logic_vector(7 downto 0);
begin
   	
	line_sensor : ADC PORT MAP(	
		
		--- ADC Pins ---
		Clk => CLK_50M,
		oDIN => o_mosi,
		oCS_n => o_ss,
		oSCLK => o_sclk,
		iDOUT => i_miso,
		
		-- ADC Data Buffers --						  
		ADC_CH0     =>  ADC_BUF_CH(0), 
		ADC_CH1     =>  ADC_BUF_CH(1),
		ADC_CH2     =>  ADC_BUF_CH(2),
		ADC_CH3     =>  ADC_BUF_CH(3),
		ADC_CH4     =>  ADC_BUF_CH(4),
		ADC_CH5     =>  ADC_BUF_CH(5),
		ADC_CH6     =>  ADC_BUF_CH(6),
		ADC_CH7     =>  ADC_BUF_CH(7),
		
		--- Test Output ---
		TEST_OUT    =>  TEST_OUT_BUF  );	
		
	

	process(clk_50M)
		
		begin		
		if clk_50M'event and clk_50M = '1' then

			if (ADC_BUF_CH(0) > 1900) then --Negro
				sensor(0) <= '0';
			else
			   sensor(0) <= '1';
			end if;
			if (ADC_BUF_CH(1) > 1900) then -- Negro
				sensor(1) <= '0';
			else
			   sensor(1) <= '1';
			end if;
			if (ADC_BUF_CH(2) > 1900) then -- Blanco
				sensor(2) <= '0';
			else
			   sensor(2) <= '1';
			end if;
			if (ADC_BUF_CH(3) > 1900) then -- Blanco
				sensor(3) <= '0';
			else
			   sensor(3) <= '1';
			end if;
			if (ADC_BUF_CH(4) > 1900) then -- Negro
				sensor(4) <= '0';
			else
			   sensor(4) <= '1';
			end if;
			if (ADC_BUF_CH(5) > 1900) then -- Negro
				sensor(5) <= '0';
			else
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
			-- Salida del error 
	      
		end if;
	end process;
	
	process(clk_50M)
		variable error : integer:= 0;-- Variable error
		begin
		
		if clk_50M'event and clk_50M = '1' then
			error := 0;
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
			
			
--						if (sensor(0) = '0') and (sensor(1) = '1') then-- negro y blanco
--				error := - 10;
--			end if;
--			if (sensor(0) = '0') and (sensor(1) = '0') then-- negro y negro
--				error := - 8;
--			end if;
--			if (sensor(1) = '0') and (sensor(2) = '1') then-- negro y blanco
--				error := - 6;
--			end if;
--			if (sensor(1) = '0') and (sensor(2) = '0') then-- negro y negro
--				error := - 4;
--			end if;
--			if (sensor(2) = '0') and (sensor(3) = '1') then-- negro y negro
--				error := - 2;
--			end if;
--			if (sensor(2) = '0') and (sensor(3) = '0') then-- negro y negro
--				error := 0;
--			end if;
--			if (sensor(3) = '0') and (sensor(4) = '1') then-- negro y negro
--				error := 2;
--			end if;
--			if (sensor(3) = '0') and (sensor(4) = '0') then-- negro y negro
--				error := 4;
--			end if;
--			if (sensor(4) = '0') and (sensor(5) = '1') then-- negro y negro
--				error := 6;
--			end if;
--			if (sensor(4) = '0') and (sensor(5) = '1') then-- negro y negro
--				error := 8;
--			end if;
--			if (sensor(4) = '1') and (sensor(5) = '0') then-- negro y negro
--				error := 10;
--			end if;
--			error := 0;
--			if (ADC_BUF_CH(0) > 1900) then
--				error := error - 6;
--				sensor(0) := '1';
--			end if;
--			if (ADC_BUF_CH(1) > 1900) then
--				error := error - 4;
--				sensor(1) := '1';
--			end if;
--			if (ADC_BUF_CH(2) > 1900) then
--				error := error - 2;
--				sensor(2) := '1';
--			end if;
--			if (ADC_BUF_CH(3) > 1900) then
--				error := error + 2;
--				sensor(3) := '1';
--			end if;
--			if (ADC_BUF_CH(4) > 1900) then
--				error := error + 4;
--				sensor(4) := '1';
--			end if;
--			if (ADC_BUF_CH(5) > 1900) then
--				error := error + 6;
--				sensor(5) := '1';
--			end if;
--			if (ADC_BUF_CH(0) > 1800) then
--				error := error - 6;
--				sensor(0) := '1';
--			elsif (ADC_BUF_CH(5) > 1800) then
--				error := error + 6;
--				sensor(5) := '1';
--			elsif (ADC_BUF_CH(1) > 1800) then
--				error := error - 4;
--				sensor(1) := '1';
--			elsif (ADC_BUF_CH(2) > 1800) then
--				error := error - 2;
--				sensor(2) := '1';
--			elsif (ADC_BUF_CH(3) > 1800) then
--				error := error + 2;
--				sensor(3) := '1';
--
--
--			else
--				error := 0;
----			end if;
--			sensor_state(0) <= sensor(0);
--			sensor_state(1) <= sensor(1);
--			sensor_state(2) <= sensor(2);
--			sensor_state(3) <= sensor(3);
--			sensor_state(4) <= sensor(4);
--			sensor_state(5) <= sensor(5);
--			sensor_state(6) <= sensor(6);
--			sensor_state(7) <= sensor(7);
			-- Salida del error 
	      
		end if;
		sensor_data <= std_logic_vector(to_signed(error, 8));
	end process;	
--	process(clk_50M)
--		variable error : integer:= 0;-- Variable error
--		variable sensor: std_logic_vector(7 downto 0);
--		begin
--		sensor(0) := '0';
--		sensor(1) := '0';
--		sensor(2) := '0';
--		sensor(3) := '0';
--		sensor(4) := '0';
--		sensor(5) := '0';
--		
--		if clk_50M'event and clk_50M = '1' then
--			error := 0;
--			if (ADC_BUF_CH(0) > 1900) then -- negro
--				error := - 10;
--				sensor(0) := '1';
--			end if;
--			if (ADC_BUF_CH(0) > 1900) and (ADC_BUF_CH(1) > 1900) then-- negro y negro
--				error := - 8;
--			end if;
--			if (ADC_BUF_CH(0) < 1900) and (ADC_BUF_CH(1) > 1900) then--blanco y negro
--				error := - 6;
--				sensor(1) := '1';
--			end if;
--			if (ADC_BUF_CH(1) > 1900) and (ADC_BUF_CH(2) > 1900)  then-- negro y negro
--				error := - 4;
--			end if;
--			if (ADC_BUF_CH(1) > 1900) and (ADC_BUF_CH(2) < 1900) then -- negro y blanco
--				error := - 2;
--				sensor(2) := '1';
--			end if;
--			if (ADC_BUF_CH(2) < 1900) and (ADC_BUF_CH(3) < 1900) then -- negro y negro
--				error := 0;
--			end if;
--			if (ADC_BUF_CH(3) < 1900) then
--				error := 2;
--				sensor(3) := '1';
--			end if;
--			if (ADC_BUF_CH(3) < 1900) and (ADC_BUF_CH(4) > 1900) then
--				error := 4;
--			end if;
--			if (ADC_BUF_CH(4) > 1900) then
--				error := 6;
--				sensor(4) := '1';
--			end if;
--			if (ADC_BUF_CH(4) > 1900) and (ADC_BUF_CH(5) > 1900) then
--				error := 8;
--			end if;
--			if (ADC_BUF_CH(5) > 1900) then
--				error := 10;
--				sensor(5) := '1';
--			end if;
----			error := 0;
----			if (ADC_BUF_CH(0) > 1900) then
----				error := error - 6;
----				sensor(0) := '1';
----			end if;
----			if (ADC_BUF_CH(1) > 1900) then
----				error := error - 4;
----				sensor(1) := '1';
----			end if;
----			if (ADC_BUF_CH(2) > 1900) then
----				error := error - 2;
----				sensor(2) := '1';
----			end if;
----			if (ADC_BUF_CH(3) > 1900) then
----				error := error + 2;
----				sensor(3) := '1';
----			end if;
----			if (ADC_BUF_CH(4) > 1900) then
----				error := error + 4;
----				sensor(4) := '1';
----			end if;
----			if (ADC_BUF_CH(5) > 1900) then
----				error := error + 6;
----				sensor(5) := '1';
----			end if;
----			if (ADC_BUF_CH(0) > 1800) then
----				error := error - 6;
----				sensor(0) := '1';
----			elsif (ADC_BUF_CH(5) > 1800) then
----				error := error + 6;
----				sensor(5) := '1';
----			elsif (ADC_BUF_CH(1) > 1800) then
----				error := error - 4;
----				sensor(1) := '1';
----			elsif (ADC_BUF_CH(2) > 1800) then
----				error := error - 2;
----				sensor(2) := '1';
----			elsif (ADC_BUF_CH(3) > 1800) then
----				error := error + 2;
----				sensor(3) := '1';
----
----
----			else
----				error := 0;
----			end if;
--			sensor_state(0) <= sensor(0);
--			sensor_state(1) <= sensor(1);
--			sensor_state(2) <= sensor(2);
--			sensor_state(3) <= sensor(3);
--			sensor_state(4) <= sensor(4);
--			sensor_state(5) <= sensor(5);
--			sensor_state(6) <= sensor(6);
--			sensor_state(7) <= sensor(7);
--			-- Salida del error 
--	      
--		end if;
--		sensor_data <= std_logic_vector(to_signed(error, 8));
--	end process;
--------------------------------------------------------------------------
		
		
--	-- Logica de siguiente estado y salida
--	process(clk_50M)
--	variable error : integer;-- Variable error
--	begin
--	if clk_50M'event and clk_50M = '1' then
--		case Q_bus is
--		-- Lectura sensor 0
--		when read_sensor_0 =>
--		   --error := 0;
--		   in_adc_ch <= "000";-- Selecciono el canal que deseo leer.
--			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida. 
--				if out_adc_ch = "000" then -- Verifico que la salida sea del canal seleccionado.
--					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error := - 6; -- Si lee un color blanco le asigno el error -6.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "001";
--					D_bus <= read_sensor_1;
--				else
--				   -- Si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_0;
--				end if;
--			end if;
--		-- Lectura sensor 1
--		when read_sensor_1 =>
--		   in_adc_ch <= "001";
--			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
--				if out_adc_ch = "001" then -- Verifico que la salida sea del canal seleccionado.
--					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error :=	- 4;-- Si lee un color blanco le asigno el error -4.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "010";
--					D_bus <= read_sensor_2;
--				else
--					-- si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_1;
--				end if;
--			end if;
--		-- Lectura sensor 2
--		when read_sensor_2 =>
--		   in_adc_ch <= "010";
--			if adc_data_valid = '1' then-- Verifico si ya tengo un dato valido a la salida.
--				if out_adc_ch = "010" then-- Verifico si ya tengo un dato valido a la salida. 
--					if (UNSIGNED(adc_data_out) > 2500)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error := - 2; -- Si lee un color blanco le asigno el error -2.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "011";
--					D_bus <= read_sensor_3;
--				else
--				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_2;
--				end if;
--			end if;
--		-- Lectura sensor 3
--		when read_sensor_3 =>
--		   in_adc_ch <= "011";
--			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
--				if out_adc_ch = "011" then -- Verifico si ya tengo un dato valido a la salida. 
--					if (UNSIGNED(adc_data_out) > 2500)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error := 2;	-- Si lee un color blanco le asigno el error 2.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "100";
--					D_bus <= read_sensor_4;
--				else
--				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_3;
--				end if;
--			end if;
--		-- Lectura sensor 4
--		when read_sensor_4 =>
--		   in_adc_ch <= "100";
--			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
--				if out_adc_ch = "100" then -- Verifico si ya tengo un dato valido a la salida. 
--					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error := 4; -- Si lee un color blanco le asigno el error 4.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "101";
--					D_bus <= read_sensor_5;
--				else
--				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_4;
--				end if;
--			end if;
--		-- Lectura sensor 5
--		when read_sensor_5 =>
--		   in_adc_ch <= "101";
--			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
--				if out_adc_ch = "101" then -- Verifico si ya tengo un dato valido a la salida. 
--					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
--						error :=  6; -- Si lee un color blanco le asigno el error 6.
--					end if;
--					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
--					in_adc_ch <= "000";
--					D_bus <= read_sensor_0;
--				else
--				   -- Si aun no se encuentra el dato disponible, me quedo en el estado actual.
--					D_bus <= read_sensor_5;
--				end if;
--			end if;
--		end case;
--							-- Salida del error 
--					--sensor_data <= std_logic_vector(to_signed(error, 8));
--	end if;
--	-- Salida del error 
--	sensor_data <= std_logic_vector(to_signed(error, 8));
--	end process; 
--   -- Salida del estado actual. 
--   PROCESS (clk_50M, Q_bus)
--   BEGIN
--      CASE Q_bus IS
--         WHEN read_sensor_0 =>
--            state_out <= "001";
--         WHEN read_sensor_1 =>
--            state_out <= "010";
--			WHEN read_sensor_2 =>
--            state_out <= "011";
--			WHEN read_sensor_3 =>
--            state_out <= "100";
--			WHEN read_sensor_4 =>
--            state_out <= "101";
--			WHEN read_sensor_5 =>
--            state_out <= "110";
--			WHEN others => state_out <= "000";
--      END CASE;
--   END PROCESS;	
	
end architecture;