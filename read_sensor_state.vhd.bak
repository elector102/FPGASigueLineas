library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity read_sensor is 
	port (
	sensor_data	: out std_logic_vector(7 downto 0);
	read_ok		: out std_logic;
	CLK_50M		: in std_logic;
   o_sclk      : out std_logic;
   o_ss        : out std_logic;
   o_mosi      : out std_logic;
   i_miso      : in  std_logic);
end entity;

architecture principal of read_sensor is
	component adc_serial_control is
		generic(CLK_DIV : integer := 100 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
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
--signal adc_chanel_selec				: std_logic_vector(2 downto 0) := "000";
--signal error 							: natural :=0;
signal in_adc_ch						: std_logic_vector(2 downto 0);
signal out_adc_ch						: std_logic_vector(2 downto 0); 
signal adc_conv_ena 					: std_logic;
signal Rst								: std_logic := '1';
signal adc_data_valid				: std_logic;
signal adc_data_out					: std_logic_vector(11 downto 0);

begin
   ADC : adc_serial_control	PORT MAP(CLK_50M, Rst, adc_conv_ena, in_adc_ch, adc_data_valid, out_adc_ch, adc_data_out, o_sclk, o_ss, o_mosi, i_miso );

   Rst <= '1';
	adc_conv_ena <= '1';
   process(clk_50M)
	variable error : integer:=0;
	begin
	   in_adc_ch <= "000";
      if adc_data_valid ='1' then
			if out_adc_ch = "000" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := -6;
			end if;
		end if;
		
		in_adc_ch <= "001";
		if adc_data_valid = '1' then
			if  out_adc_ch = "001" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := -4;
			end if;
		end if;
		
		in_adc_ch <= "010";
		if adc_data_valid = '1' then
			if  out_adc_ch = "010" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := -2;
			end if;
		end if;	
		
		in_adc_ch <= "011";
		if adc_data_valid = '1' then
			if  out_adc_ch = "011" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := 2;
			end if;
		end if;
		in_adc_ch <= "100";
		if adc_data_valid = '1' then
			if  out_adc_ch = "100" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := 4;
			end if;
		end if;
		
		in_adc_ch <= "101";
			if adc_data_valid = '1' then
			if  out_adc_ch = "101" then
				read_ok <= '1';
			else
				read_ok <= '0';
			end if;
			if (UNSIGNED(adc_data_out) > 2000)  then
				error := 6;
			end if;
			end if;
		sensor_data <= std_logic_vector(to_signed(error, 8));
	end process;
	

end architecture;
	
