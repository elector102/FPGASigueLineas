-- Top
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY Top_pll IS
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
END Top_pll ;

ARCHITECTURE Behavior OF Top_pll IS

Signal Pll_out : std_logic;

COMPONENT Div_freq is
PORT (
		CLK : in std_logic;
		Y_motor : out std_logic;
		Y_ADC : out std_logic;
		Y_portserie : out std_logic);	
END COMPONENT;

COMPONENT Pllmw IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END COMPONENT;

signal Y_motorin : std_LOGIC;
signal Y_ADCin   : std_LOGIC;
signal Y_portseriein : std_LOGIC;

BEGIN

	U1: Div_freq PORT MAP(Pll_out, Y_motorin, Y_ADCin, Y_portseriein );

	U2: Pllmw PORT MAP (
			areset	 => areset,
			inclk0	 => inclk0,
			c0	 => Pll_out,
			locked	 => locked
		);

		Y_motor <= Y_motorin;
		Y_ADC <= Y_ADCin;
		Y_portserie <=Y_portseriein;
		cx0 <= pll_out;
	
END Behavior ;