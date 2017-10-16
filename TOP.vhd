-- Top
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

ENTITY Top IS
	generic (num_de_cont:integer := 4);
PORT(
	CLK_50M 	: in std_logic;
	Rst  		: in std_logic;
	led0		: out std_logic;
	led1		: out std_logic;
	led2		: out std_logic;
	led3 		: out std_logic;
	led4		: out std_logic;
	led5		: out	std_logic;
	led6		: out std_logic;
	led7		: out std_logic;
	adc_sclk	: out std_logic;
	adc_ss	: out std_logic;
	adc_mosi	: out std_logic;
	adc_miso	: in std_logic;
	test_sclk	: out std_logic;
	test_ss	: out std_logic;
	test_mosi	: out std_logic;
	test_miso	: out std_logic;
	start_adc   : in std_logic;
	in_data_ch : in std_logic_vector(2 downto 0));
END Top ;

ARCHITECTURE Behavior OF Top IS

-- Declaracion de componentes
	component read_sensor is
	port(
		sensor_data	: out std_logic_vector(7 downto 0);
		read_ok		: out std_logic;
		CLK_50M		: in std_logic;
		o_sclk      : out std_logic;
		o_ss        : out std_logic;
		o_mosi      : out std_logic;
		i_miso      : in  std_logic);
	end component;
	component pwm_dc_101 is
    PORT(
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        entrada: IN  STD_LOGIC_VECTOR(6 downto 0);
        salida : OUT STD_LOGIC);
	end component;

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
signal adc_chanel_selec				: std_logic_vector(2 downto 0) := "000";
signal adc_data_valid				: std_logic;
signal out_adc_ch				: std_logic_vector(2 downto 0);
signal adc_data_out					: std_logic_vector(11 downto 0);	
signal adc_conv_ena					: std_logic;
signal sensor_data		: std_logic_vector(7 downto 0);
signal read_ok 			: std_logic;
signal reset				: std_LOGIC;
signal internal_adc_sclk: std_logic;
signal internal_adc_ss  : std_logic;
signal internal_adc_mosi : std_logic;
signal internal_adc_miso : std_logic;
BEGIN

-- Instanciacion de componentes:
   ADC : adc_serial_control	PORT MAP(CLK_50M, Rst, adc_conv_ena, adc_chanel_selec, adc_data_valid, out_adc_ch, adc_data_out, internal_adc_sclk, internal_adc_ss, internal_adc_mosi, internal_adc_miso );
	reset <= Rst;
	adc_conv_ena <= start_adc;
   adc_chanel_selec <= in_data_ch;
	led4 <= out_adc_ch(0);
	led5 <= out_adc_ch(1);
	led6 <= out_adc_ch(2);
	led7 <= Rst and adc_conv_ena;
	adc_sclk <= internal_adc_sclk;
	test_sclk <= internal_adc_sclk;
	adc_ss <= internal_adc_ss;
	test_ss <= internal_adc_ss;
	adc_mosi <= internal_adc_mosi;
	test_mosi <= internal_adc_mosi;
	internal_adc_miso <= adc_miso;
	test_miso <= internal_adc_miso;
	process (adc_data_valid, out_adc_ch)
		begin
			if rising_edge(adc_data_valid) then
				if (UNSIGNED(adc_data_out) > 2000)  then
					if (out_adc_ch = "000") then
						led0 <= '1';
					end if;
					if (out_adc_ch = "001") then
						led1 <= '1';
					end if;
					if (out_adc_ch = "010") then
						led2 <= '1';
					end if;
					if (out_adc_ch = "011") then
						led3 <= '1';
					end if;
				end if;
				if (UNSIGNED(adc_data_out) < 2000)  then
					if (out_adc_ch = "000") then
						led0 <= '0';
					end if;
					if (out_adc_ch = "001") then
						led1 <= '0';
					end if;
					if (out_adc_ch = "010") then
						led2 <= '0';
					end if;
					if (out_adc_ch = "011") then
						led3 <= '0';
					end if;	
				end if;
			end if;
		end process;
END Behavior ;