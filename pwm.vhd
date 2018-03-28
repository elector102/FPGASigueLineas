library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--- Modulo PWM de 100 estados, desde 0% a 100% ---
entity pwm_dc is
    PORT(
		  --- Señal de relog, frecuencia del PWM ---
        clk    : IN  STD_LOGIC; 
		  --- Señal de reset ---
        reset  : IN  STD_LOGIC; 
		  --- valor del duty cycle  ---
        duty_cycle: IN  STD_LOGIC_VECTOR(6 downto 0);
		  --- Salida del PWM ---
        pwm_out : OUT STD_LOGIC);
end pwm_dc;
  
architecture Behavioral of pwm_dc is
    signal cnt : UNSIGNED(6 downto 0);
begin
    contador: process (clk, reset, duty_cycle) begin
        if reset = '0' then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if cnt = 99 then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;
    -- Asignación de señales --
    pwm_out <= '1' when (cnt < UNSIGNED(duty_cycle)) else '0';
end Behavioral;