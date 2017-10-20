library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_sensor_state is 
	port (
	sensor_data	: out std_logic_vector(7 downto 0);
	CLK		: in std_logic;
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
signal nueva_medida					: std_logic;
signal nueva_medida_2					: std_logic;

type my_state is (read_sensor_0, read_sensor_1, read_sensor_2, read_sensor_3, read_sensor_4, read_sensor_5);
signal D_bus, Q_bus : my_state;
begin
   ADC : adc_serial_control	PORT MAP(CLK, Rst, adc_conv_ena, in_adc_ch2, adc_data_valid, out_adc_ch, adc_data_out, o_sclk, o_ss, o_mosi, i_miso );
	
	-- Logica del siguiente estado
	
   dato_ok <= adc_data_valid;
	in_adc_ch2 <= in_adc_ch;
	

	--
   process(clk,reset)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				Q_bus <= D_bus;
				Rst <= '1';
			else 
				Q_bus <= read_sensor_0;
				Rst <= '0';
			end if;
		end if;
	end process;
	
	--------
	process(clk)
	variable contador_2 : integer;
		
	begin
	   if rising_edge(clk) then
			if nueva_medida = '1' then
				case Q_bus is
				-- Lectura sensor 0
				when read_sensor_0 =>
					in_adc_ch <= "000";
					D_bus <= read_sensor_1;
				when read_sensor_1 =>
					in_adc_ch <= "001";
					D_bus <= read_sensor_2;
				when read_sensor_2 =>
					in_adc_ch <= "010";
					D_bus <= read_sensor_3;
				when read_sensor_3 =>
					in_adc_ch <= "011";
					D_bus <= read_sensor_4;
				when read_sensor_4 =>
					in_adc_ch <= "100";
					D_bus <= read_sensor_5;
				when read_sensor_5 =>
					in_adc_ch <= "101";
					D_bus <= read_sensor_0;
				when others =>
					in_adc_ch <= "000";
					D_bus <= read_sensor_0;
				end case;
				nueva_medida_2 <= '0';
				adc_conv_ena <= '0';
				-- Contador para mantener en cero algunos pulsos de reloj el enable.
			else
				nueva_medida_2 <='1';
				adc_conv_ena <= '1';
			end if;
		end if;
	end process;
	
	process(clk)
	variable error : integer;-- Variable error
	variable contador : integer;
	begin
	   if rising_edge(clk) then
			if nueva_medida_2 = '0' then
				nueva_medida <= '0';
			-- contador para darle una demora a empezar a leer.
			elsif adc_data_valid = '1' then
				   ---
					-- Blanco es menor humbral.
					-- Negro es mayor al humbral.
					-- 
					-- Estoy detectando negro y encuentro un blanco
					if (UNSIGNED(adc_data_out) < 2500)  then 
						if out_adc_ch = "000" then
							error := - 6;
						elsif out_adc_ch = "001" then
							error := - 4;
						elsif out_adc_ch = "100" then
							error := 4;
						elsif out_adc_ch = "101" then
							error := 6;
						else
							error :=0;
						end if;

					-- blanco
					elsif (UNSIGNED(adc_data_out) > 2500) then
						if out_adc_ch = "010" then
							error := - 2;
						elsif out_adc_ch = "011" then
							error := 2;
						else
							error:= 0;
						end if;
					else
						error :=0;
					end if;
					nueva_medida <= '1';
					sensor_data <= std_logic_vector(to_signed(error, 8));
					
				end if;
	   end if;
	end process;
	

   -- Salida del estado actual. 
   PROCESS (clk, Q_bus)
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
	
