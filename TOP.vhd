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
	adc_miso	: in std_logic;
	out_motor_clock		: out std_LOGIC;
   out_ADC_clock			: out std_LOGIC;
   out_port_serie_clock	: out std_LOGIC;
   out_PLL_clock			: out std_LOGIC;
   out_pll_locked		   : out std_LOGIC);
--	Pll_locked : out std_logic;
--	Out_7 : out std_logic_vector (6 downto 0));	
END Top ;

ARCHITECTURE Behavior OF Top IS

-- Declaracion de componentes
-- lectura de sensores mediante maquina de estado
	component adc_pid_error is
	port(
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
	end component;
	-- Definicion del PWM
	component pwm_dc is
    PORT(
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        duty_cycle: IN  STD_LOGIC_VECTOR(6 downto 0);
        pwm_out : OUT STD_LOGIC);
	end component;

	-- Definicion del modulo de control por PID
	component pid_control is
	generic(
		KP               : integer :=  25 ;
		KI               : integer :=  3 ;
		KD               : integer :=  0;
		MOTOR_MAX_PWM    : integer :=  80); 
	port (
		clk_50mhz : in std_logic;
		reset_btn : in std_logic;
		sensor_data: in std_logic_vector(7 downto 0);
		PWM_motorA: out std_logic_vector(6 downto 0);
		PWM_motorB: out std_logic_vector(6 downto 0);
		motor_direcction : out integer range -1 to 1);
	end component;
	
	
	component Top_pll IS
	PORT (	
			Y_motor : out std_logic;
			Y_ADC : out std_logic;
			Y_portserie : out std_logic;
			cx0				:	out std_logic;	
			areset		: IN STD_LOGIC  := '0';
			inclk0		: IN STD_LOGIC  := '0';
			locked		: OUT STD_LOGIC);
	END component ;
	
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

signal sensor_data		: std_logic_vector(7 downto 0);
signal sensor_state		: std_logic_vector(7 downto 0);
signal read_ok 			: std_logic;
signal reset				: std_LOGIC;
signal dato_ok_top		: std_LOGIC;
signal motor_left_pwm_in :std_logic_vector(6 downto 0);
signal motor_right_pwm_in :std_logic_vector(6 downto 0);
signal adc_state_out 	: std_logic_vector(2 downto 0);
signal motor_clock		: std_LOGIC;
signal ADC_clock			: std_LOGIC;
signal port_serie_clock	: std_LOGIC;
signal PLL_clock			: std_LOGIC;
signal pll_locked		   : std_LOGIC;
signal reset_pll			: std_logic;
-- ADC signals
type BUFFER_DATAS is array (7 DOWNTO 0) of INTEGER RANGE 0 TO 4095;
signal ADC_BUF_CH : BUFFER_DATAS;
signal TEST_OUT_BUF  : STD_LOGIC;
signal motor_direcction : integer range -1 to 1;

BEGIN
-- Instanciacion de componentes:
   pll : Top_pll port map(
		Y_motor 	=>		motor_clock, 
		Y_ADC		=>		ADC_clock, 
		Y_portserie	=>	port_serie_clock, 
		cx0			=>	PLL_clock, 
		areset		=>	reset_pll, 
		inclk0		=>	CLK_50M, 
		locked		=>	pll_locked);
	line_sensor : ADC PORT MAP(	
		
		--- ADC Pins ---
		Clk => CLK_50M,
		oDIN => adc_mosi,
		oCS_n => adc_ss,
		oSCLK => adc_sclk,
		iDOUT => adc_miso,
		
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
		
	sensor : adc_pid_error PORT MAP(sensor_data, sensor_state, CLK_50M, reset,
	
		--- Datos de entrada ADC ---
	ADC_CH0 => ADC_BUF_CH(0),
	ADC_CH1 => ADC_BUF_CH(1),
	ADC_CH2 => ADC_BUF_CH(2),
	ADC_CH3 => ADC_BUF_CH(3),
	ADC_CH4 => ADC_BUF_CH(4),
	ADC_CH5 => ADC_BUF_CH(5),
	ADC_CH6 => ADC_BUF_CH(6),
	ADC_CH7 => ADC_BUF_CH(7));

	pid : pid_control PORT MAP(CLK_50M, reset, sensor_data,  motor_left_pwm_in, motor_right_pwm_in, motor_direcction);
	motor_left_pwm : pwm_dc port map(motor_clock, reset, motor_left_pwm_in, motor_left_pwm_out);
	motor_right_pwm : pwm_dc port map(motor_clock, reset, motor_right_pwm_in, motor_right_pwm_out);
	reset <= '1';
	reset_pll <='0';
	process(motor_direcction)
	begin
		if motor_direcction = 1 then
			motor_left1 <= '0';
			motor_left2 <= '1';
			motor_right1 <= '1';
			motor_right2 <= '0';
		elsif motor_direcction = -1 then
			motor_left1 <= '1';
			motor_left2 <= '0';
			motor_right1 <= '0';
			motor_right2 <= '1';
		else
			motor_left1 <= '1';
			motor_left2 <= '0';
			motor_right1 <= '1';
			motor_right2 <= '0';
		end if;
	end process;

   out_motor_clock <= motor_clock;
   out_ADC_clock <=ADC_clock;
   out_port_serie_clock	<= port_serie_clock;
   out_PLL_clock <= PLL_clock;
   out_pll_locked	<=pll_locked;

   -- Proceso por el cueal se muestran distintos estados de la medicion de adc por los led
	process(sensor_state)
	variable error :integer;
	begin
	   if rising_edge(clk_50M) then
			led0 <= sensor_state(0);
			led1 <= sensor_state(1);
			led2 <= sensor_state(2);
			led3 <= sensor_state(3);
			led4 <= sensor_state(4);
			led5 <= sensor_state(5);
			led6 <= sensor_state(6);
			
		end if;
	end process;
END Behavior ;
-- de atras, para atras
--	motor_left1 <= '0';
--	motor_left2 <= '1';
--	motor_right1 <= '0';
--	motor_right2 <= '1';
-- de atras, para delante
--	motor_left1 <= '1';
--	motor_left2 <= '0';
--	motor_right1 <= '1';
--	motor_right2 <= '0';

--			error := to_integer(signed(sensor_data(7 downto 0)));
--			if (error = -10) then
--				led0 <= '1';
--				led1 <= '0';
--				led2 <= '0';
--				led3 <= '0';
--				led4 <= '0';
--				led5 <= '0';
--				led6 <= '0';
--			elsif (error = -6) then
--				led0 <= '0';
--				led1 <= '1';
--				led2 <= '0';
--				led3 <= '0';
--				led4 <= '0';
--				led5 <= '0';
--				led6 <= '0';
--			elsif (error = -2) then
--				led0 <= '0';
--				led1 <= '0';
--				led2 <= '1';
--				led3 <= '0';
--				led4 <= '0';
--				led5 <= '0';
--				led6 <= '0';
--			elsif (error = 2) then
--				led0 <= '0';
--				led1 <= '0';
--				led2 <= '0';
--				led3 <= '1';
--				led4 <= '0';
--				led5 <= '0';
--				led6 <= '0';
--			elsif (error = 6) then
--				led0 <= '0';
--				led1 <= '0';
--				led2 <= '0';
--				led3 <= '0';
--				led4 <= '1';
--				led5 <= '0';
--				led6 <= '0';
--			elsif (error = 10) then
--				led0 <= '0';
--				led1 <= '0';
--				led2 <= '0';
--				led3 <= '0';
--				led4 <= '0';
--				led5 <= '1';
--				led6 <= '0';
--			else
--				led0 <= '0';
--				led1 <= '0';
--				led2 <= '0';
--				led3 <= '0';
--				led4 <= '0';
--				led5 <= '0';
--				led6 <= '1';
--			end if;
--       end if;
--	end process;
	
--	process(clk_50M)
--	begin
--		led5 <= adc_state_out(0);
--		led6 <= adc_state_out(1);
--		led7 <= adc_state_out(2);
--		led5 <= '0';
--		led6 <= '0';
--		led7 <= '0';
--	end process;
--END Behavior ;