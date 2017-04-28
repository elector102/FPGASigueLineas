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
	motor_left_pwm_out : out std_LOGIC;
	motor_right_pwm_out : out std_LOGIC;
	motor_left1 : out std_LOGIC;
	motor_left2 : out std_LOGIC;
	motor_right1 : out std_LOGIC;
	motor_right2 : out std_logic;
	adc_sclk	: out std_logic;
	adc_ss	: out std_logic;
	adc_mosi	: out std_logic;
	adc_miso	: in std_logic);
--	Pll_locked : out std_logic;
--	Out_7 : out std_logic_vector (6 downto 0));	
END Top ;

ARCHITECTURE Behavior OF Top IS

-- Declaracion de componentes
	component read_sensor_state is
	port(
		sensor_data	: out std_logic_vector(7 downto 0);
		CLK_50M		: in std_logic;
		dato_ok		:out std_logic;
		state_out	: out std_logic_vector(2 downto 0);
		reset			: in std_logic;
		o_sclk      : out std_logic;
		o_ss        : out std_logic;
		o_mosi      : out std_logic;
		i_miso      : in  std_logic);
	end component;
	component pwm_dc_101 is
    PORT(
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        duty_cycle: IN  STD_LOGIC_VECTOR(6 downto 0);
        pwm_out : OUT STD_LOGIC);
	end component;

	component pid_control is
	port (
		clk_50mhz : in std_logic;
		reset_btn : in std_logic;
		sensor_data: in std_logic_vector(7 downto 0);
		PWM_motorA: out std_logic_vector(6 downto 0);
		PWM_motorB: out std_logic_vector(6 downto 0));
	end component;
--	component adc_serial_control is
--		generic(CLK_DIV : integer := 100 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(CLK_DIV)
--	port (
--	  i_clk                       : in  std_logic;
--	  i_rstb                      : in  std_logic;
--	  i_conv_ena                  : in  std_logic;  -- enable ADC convesion
--	  i_adc_ch                    : in  std_logic_vector(2 downto 0);  -- ADC channel 0-7
--	  o_adc_data_valid            : out std_logic;  -- conversion valid pulse
--	  o_adc_ch                    : out std_logic_vector(2 downto 0);  -- ADC converted channel
--	  o_adc_data                  : out std_logic_vector(11 downto 0); -- adc parallel data  
--	-- ADC serial interface
--	  o_sclk                      : out std_logic;
--	  o_ss                        : out std_logic;
--	  o_mosi                      : out std_logic;
--	  i_miso                      : in  std_logic);
--	end component;
--signal adc_chanel_selec				: std_logic_vector(2 downto 0) := "000";
--signal adc_data_valid				: std_logic;
--signal adc_chanel_out				: std_logic_vector(2 downto 0);
--signal adc_data_out					: std_logic_vector(11 downto 0);	
--signal adc_conv_ena					: std_logic;
signal sensor_data		: std_logic_vector(7 downto 0);
signal read_ok 			: std_logic;
signal reset				: std_LOGIC;
signal dato_ok_top		: std_LOGIC;
signal motor_left_pwm_in :std_logic_vector(6 downto 0);
signal motor_right_pwm_in :std_logic_vector(6 downto 0);
signal adc_state_out 	: std_logic_vector(2 downto 0);
BEGIN

-- Instanciacion de componentes:

	sensor : read_sensor_state PORT MAP(sensor_data, CLK_50M, dato_ok_top, adc_state_out, reset, adc_sclk, adc_ss, adc_mosi, adc_miso);
	pid : pid_control PORT MAP(CLK_50M, reset, sensor_data,  motor_left_pwm_in, motor_right_pwm_in);
	motor_left_pwm : pwm_dc_101 port map(CLK_50M, reset, motor_left_pwm_in, motor_left_pwm_out);
	motor_right_pwm : pwm_dc_101 port map(CLK_50M, reset, motor_right_pwm_in, motor_right_pwm_out);
	reset <= '1';
	motor_left1 <= '0';
	motor_left2 <= '1';
	motor_right1 <= '0';
	motor_right2 <= '1';
--	to_integer(signed(sensor_data))

	process(clk_50M, sensor_data)
	variable error :integer;
	begin
	   error := to_integer(signed(sensor_data(7 downto 0)));
		if (error = -6) then
			led0 <= '1';
			led1 <= '0';
			led2 <= '0';
			led3 <= '0';
			led4 <= '0';
--			led5 <= '0';
--			led6 <= '0';
		elsif (error = -4) then
			led0 <= '0';
			led1 <= '1';
			led2 <= '0';
			led3 <= '0';
			led4 <= '0';
--			led5 <= '0';
--			led6 <= '0';
		elsif (error = -2) then
			led0 <= '0';
			led1 <= '0';
			led2 <= '1';
			led3 <= '0';
			led4 <= '0';
--			led5 <= '0';
--			led6 <= '0';
		elsif (error = 2) then
			led0 <= '0';
			led1 <= '0';
			led2 <= '0';
			led3 <= '1';
			led4 <= '0';
--			led5 <= '0';
--			led6 <= '0';
		elsif (error = 4) then
			led0 <= '0';
			led1 <= '0';
			led2 <= '0';
			led3 <= '0';
			led4 <= '0';
--			led5 <= '0';
--			led6 <= '0';
		elsif (error = 6) then
			led0 <= '0';
			led1 <= '0';
			led2 <= '0';
			led3 <= '0';
			led4 <= '0';
--			led5 <= '1';
--			led6 <= '0';
		else
			led0 <= '1';
			led1 <= '1';
			led2 <= '1';
			led3 <= '1';
			led4 <= '1';
--			led5 <= '0';
--			led6 <= '1';
		end if;

	end process;
	
	process(clk_50M)
	begin
		led5 <= adc_state_out(0);
		led6 <= adc_state_out(1);
		led7 <= adc_state_out(2);
--		led5 <= '0';
--		led6 <= '0';
--		led7 <= '0';
	end process;
--	adc_conv_ena <= '1';
--   adc_chanel_selec <= "010";
--	led4 <= adc_chanel_out(0);
--	led5 <= adc_chanel_out(1);
--	led6 <= adc_chanel_out(2);
--	led7 <= Rst;
--	process (adc_data_valid, adc_chanel_out)
--		begin
--			if rising_edge(adc_data_valid) then
--				if (UNSIGNED(adc_data_out) > 2000)  then
--					if (adc_chanel_out = "000") then
--						led0 <= '1';
--					end if;
--					if (adc_chanel_out = "010") then
--						led1 <= '1';
--					end if;
--					if (adc_chanel_out = "100") then
--						led2 <= '1';
--					end if;
--					if (adc_chanel_out = "101") then
--						led3 <= '1';
--					end if;
--				end if;
--				if (UNSIGNED(adc_data_out) < 3000)  then
--					if (adc_chanel_out = "000") then
--						led0 <= '0';
--					end if;
--					if (adc_chanel_out = "010") then
--						led1 <= '0';
--					end if;
--					if (adc_chanel_out = "100") then
--						led2 <= '0';
--					end if;
--					if (adc_chanel_out = "101") then
--						led3 <= '0';
--					end if;	
--				end if;
--			end if;
--		end process;
END Behavior ;