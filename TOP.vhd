-- Top
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

ENTITY Top IS
	generic (num_de_cont:integer := 4);
PORT(
	--- Entrada de relog ---
	CLK_50M 	: in std_logic;
	--- Entrada de reset ---
	Rst  		: in std_logic;
	--- Salidas de los LED ---
	led0		: out std_logic;
	led1		: out std_logic;
	led2		: out std_logic;
	led3 		: out std_logic;
	led4		: out std_logic;
	led5		: out	std_logic;
	led6		: out std_logic;
	led7		: out std_logic;
	--- Salidas PWM de los motores ---
	motor_left_pwm_out : out std_LOGIC;
	motor_right_pwm_out : out std_LOGIC;
	--- Salida de sentido de giro de los motores ---
	motor_left1 : out std_LOGIC;
	motor_left2 : out std_LOGIC;
	motor_right1 : out std_LOGIC;
	motor_right2 : out std_logic;
	--- Comunicacion SPI para conversor ADC
	adc_sclk	: out std_logic;
	adc_ss	: out std_logic;
	adc_mosi	: out std_logic;
	adc_miso	: in std_logic;
	--- Señales de Testeo ---
	out_motor_clock		: out std_LOGIC;
   out_ADC_clock			: out std_LOGIC;
   out_port_serie_clock	: out std_LOGIC;
   out_PLL_clock			: out std_LOGIC;
   out_pll_locked		   : out std_LOGIC);	
END Top ;

ARCHITECTURE Behavior OF Top IS

-- Declaracion de componentes
-- lectura de sensores mediante maquina de estado
	component adc_pid_error is
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
	end component;
	-- Definicion del PWM
	component pwm_dc is
    PORT(
		  --- Señal de relog, frecuencia del PWM ---
        clk    : IN  STD_LOGIC; 
		  --- Señal de reset ---
        reset  : IN  STD_LOGIC; 
		  --- valor del duty cycle  ---
        duty_cycle: IN  STD_LOGIC_VECTOR(6 downto 0);
		  --- Salida del PWM ---
        pwm_out : OUT STD_LOGIC);
	end component;

	-- Definicion del modulo de control por PID
	component pid_control is
	generic(
		--- Parametro del controlador PID ---
		KP               : integer :=  20 ;
		KI               : integer :=  0 ;
		KD               : integer :=  0 );
	port (
	   --- Entrada de reloj ---
		clk_50mhz : in std_logic;
		--- Entrada de reset ---
		reset_btn : in std_logic; 
		--- Entrada del error desde read_sensor_state ---
		sensor_data: in std_logic_vector(7 downto 0); 
		PID_value : OUT integer range -500 to 500);
	end component;
	
	
	component Top_pll IS
	PORT (
		--- Frecuencia de salida divididas---
		Y_motor : out std_logic;
		Y_ADC : out std_logic;
		Y_portserie : out std_logic;
		--- Salida directa del PLL ---
		cx0				:	out std_logic;
		--- Entrada del reset ---
		areset		: IN STD_LOGIC  := '0';
		--- Entrada del reloj del FPGA, 50 MHz ---
		inclk0		: IN STD_LOGIC  := '0';
		--- Salida activada en alto cuando el PLL esta enganchado ---
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
	
	component motor_control is
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
	end component;

signal sensor_data		: std_logic_vector(7 downto 0);
signal sensor_state		: std_logic_vector(7 downto 0);
signal reset				: std_LOGIC;
signal pwm_motor_left	:std_logic_vector(6 downto 0);
signal pwm_motor_right  :std_logic_vector(6 downto 0);
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
signal PID_value : integer range -500 to 500;
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
	   TEST_OUT =>TEST_OUT_BUF);
	sensor : adc_pid_error PORT MAP(
		sensor_data	=>	sensor_data, 
		sensor_state	=>	sensor_state, 
		CLK_50M	=>	CLK_50M, 
		reset	=>	reset,
		
			--- Datos de entrada ADC ---
		ADC_CH0 => ADC_BUF_CH(0),
		ADC_CH1 => ADC_BUF_CH(1),
		ADC_CH2 => ADC_BUF_CH(2),
		ADC_CH3 => ADC_BUF_CH(3),
		ADC_CH4 => ADC_BUF_CH(4),
		ADC_CH5 => ADC_BUF_CH(5),
		ADC_CH6 => ADC_BUF_CH(6),
		ADC_CH7 => ADC_BUF_CH(7));

	pid : pid_control PORT MAP(CLK_50M, reset, sensor_data,  PID_value);
	velocity_motor_control : motor_control port map(
		reset,
		PID_value,
		pwm_motor_left,
		motor_left1,
		motor_left2,
		motor_right1,
		motor_right2,
		PWM_motor_right);
	motor_left_pwm : pwm_dc port map(motor_clock, reset, PWM_motor_left, motor_left_pwm_out);
	motor_right_pwm : pwm_dc port map(motor_clock, reset, PWM_motor_right, motor_right_pwm_out);
		
		
	reset <= Rst;
	reset_pll <= not reset;

   out_motor_clock <= motor_clock;
   out_ADC_clock <=ADC_clock;
   out_port_serie_clock	<= port_serie_clock;
   out_PLL_clock <= PLL_clock;
   out_pll_locked	<=pll_locked;

   -- Proceso por el cual se muestran distintos estados de los sensores de linea.
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
