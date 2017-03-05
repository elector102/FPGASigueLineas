library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
  
entity pwm_dc_101 is
    PORT(
        clk    : IN  STD_LOGIC;
        reset  : IN  STD_LOGIC;
        entrada: IN  STD_LOGIC_VECTOR(6 downto 0);
        salida : OUT STD_LOGIC
    );
end pwm_dc_101;
  
architecture Behavioral of pwm_dc_101 is
    signal cnt : UNSIGNED(6 downto 0);
begin
    contador: process (clk, reset, entrada) begin
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
    salida <= '1' when (cnt < UNSIGNED(entrada)) else '0';
end Behavioral;