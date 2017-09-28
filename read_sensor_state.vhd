library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_sensor_state is 
	port (
	sensor_data	: out std_logic_vector(7 downto 0);
	CLK_50M		: in std_logic;
	dato_ok		:out std_logic;
	state_out	: out std_logic_vector(2 downto 0);
	reset			: in std_logic;
   o_sclk      : out std_logic; -- Salida de sclk hacia el adc
   o_ss        : out std_logic; -- Salida de ss hacia el adc
   o_mosi      : out std_logic; -- salida mosi del adc
   i_miso      : in  std_logic);
end entity;

architecture main of read_sensor_state is
	component adc_serial_control is
		generic(CLK_DIV : integer := 5 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
	port (
	  i_clk                       : in  std_logic;
	  i_rstb                      : in  std_logic;
	  i_conv_ena                  : in  std_logic;  -- enable ADC convesion
	  i_adc_ch                    : in  std_logic_vector(2 downto 0);  -- ADC channel 0-7
	  o_adc_data_valid            : out std_logic;  -- conversion valid pulse
	  o_adc_ch                    : out std_logic_vector(2 downto 0);  -- ADC converted channel
	  o_adc_data                  : out std_logic_vector(11 downto 0); -- adc parallel data  
	-- ADC serial interface
	  o_sclk                      : out std_logic;
	  o_ss                        : out std_logic;
	  o_mosi                      : out std_logic;
	  i_miso                      : in  std_logic);
	end component;
signal in_adc_ch	, in_adc_ch2						: std_logic_vector(2 downto 0);
signal out_adc_ch						: std_logic_vector(2 downto 0); 
signal adc_conv_ena 					: std_logic;
signal Rst								: std_logic;
signal adc_data_valid				: std_logic;
signal adc_data_out					: std_logic_vector(11 downto 0);


type my_state is (read_sensor_0, read_sensor_1, read_sensor_2, read_sensor_3, read_sensor_4, read_sensor_5);
signal D_bus, Q_bus : my_state;
begin
   ADC : adc_serial_control	PORT MAP(CLK_50M, Rst, adc_conv_ena, in_adc_ch2, adc_data_valid, out_adc_ch, adc_data_out, o_sclk, o_ss, o_mosi, i_miso );
	
	-- Logica del siguiente estado
	adc_conv_ena <= '1';
   dato_ok <= adc_data_valid;
	in_adc_ch2 <= in_adc_ch;
	
	--
   process(clk_50M,reset)
	begin
		if clk_50M'event and clk_50M = '1' then
			if reset = '1' then
				Q_bus <= D_bus;
				Rst <= '1';
			else 
				Q_bus <= read_sensor_0;
				Rst <= '0';
			end if;
		end if;
	end process;
	
	-- Logica de siguiente estado y salida
	process(clk_50M)
	variable error : integer;-- Variable error
	begin
	if clk_50M'event and clk_50M = '1' then
		case Q_bus is
		-- Lectura sensor 0
		when read_sensor_0 =>
		   --error := 0;
		   in_adc_ch <= "000";-- Selecciono el canal que deseo leer.
			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida. 
				if out_adc_ch = "000" then -- Verifico que la salida sea del canal seleccionado.
					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
						error := - 6; -- Si lee un color blanco le asigno el error -6.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "001";
					D_bus <= read_sensor_1;
				else
				   -- Si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_0;
				end if;
			end if;
		-- Lectura sensor 1
		when read_sensor_1 =>
		   in_adc_ch <= "001";
			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
				if out_adc_ch = "001" then -- Verifico que la salida sea del canal seleccionado.
					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
						error :=	- 4;-- Si lee un color blanco le asigno el error -4.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "010";
					D_bus <= read_sensor_2;
				else
					-- si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_1;
				end if;
			end if;
		-- Lectura sensor 2
		when read_sensor_2 =>
		   in_adc_ch <= "010";
			if adc_data_valid = '1' then-- Verifico si ya tengo un dato valido a la salida.
				if out_adc_ch = "010" then-- Verifico si ya tengo un dato valido a la salida. 
					if (UNSIGNED(adc_data_out) > 2500)  then -- Pregunto si el sensor esta viendo un color blanco.
						error := - 2; -- Si lee un color blanco le asigno el error -2.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "011";
					D_bus <= read_sensor_3;
				else
				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_2;
				end if;
			end if;
		-- Lectura sensor 3
		when read_sensor_3 =>
		   in_adc_ch <= "011";
			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
				if out_adc_ch = "011" then -- Verifico si ya tengo un dato valido a la salida. 
					if (UNSIGNED(adc_data_out) > 2500)  then -- Pregunto si el sensor esta viendo un color blanco.
						error := 2;	-- Si lee un color blanco le asigno el error 2.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "100";
					D_bus <= read_sensor_4;
				else
				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_3;
				end if;
			end if;
		-- Lectura sensor 4
		when read_sensor_4 =>
		   in_adc_ch <= "100";
			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
				if out_adc_ch = "100" then -- Verifico si ya tengo un dato valido a la salida. 
					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
						error := 4; -- Si lee un color blanco le asigno el error 4.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "101";
					D_bus <= read_sensor_5;
				else
				   -- si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_4;
				end if;
			end if;
		-- Lectura sensor 5
		when read_sensor_5 =>
		   in_adc_ch <= "101";
			if adc_data_valid = '1' then -- Verifico si ya tengo un dato valido a la salida.
				if out_adc_ch = "101" then -- Verifico si ya tengo un dato valido a la salida. 
					if (UNSIGNED(adc_data_out) < 1000)  then -- Pregunto si el sensor esta viendo un color blanco.
						error :=  6; -- Si lee un color blanco le asigno el error 6.
					end if;
					-- Luego de leer el sensor, lego el siguiente canar, selecciono el proximo canal y cambio de estado.
					in_adc_ch <= "000";
					D_bus <= read_sensor_0;
				else
				   -- Si aun no se encuentra el dato disponible, me quedo en el estado actual.
					D_bus <= read_sensor_5;
				end if;
			end if;
		end case;
							-- Salida del error 
					--sensor_data <= std_logic_vector(to_signed(error, 8));
	end if;
	-- Salida del error 
	sensor_data <= std_logic_vector(to_signed(error, 8));
	end process; 
   -- Salida del estado actual. 
   PROCESS (clk_50M, Q_bus)
   BEGIN
      CASE Q_bus IS
         WHEN read_sensor_0 =>
            state_out <= "001";
         WHEN read_sensor_1 =>
            state_out <= "010";
			WHEN read_sensor_2 =>
            state_out <= "011";
			WHEN read_sensor_3 =>
            state_out <= "100";
			WHEN read_sensor_4 =>
            state_out <= "101";
			WHEN read_sensor_5 =>
            state_out <= "110";
			WHEN others => state_out <= "000";
      END CASE;
   END PROCESS;	
	
end architecture;
	
