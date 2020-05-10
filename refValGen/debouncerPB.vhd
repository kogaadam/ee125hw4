library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debouncer is
	generic (
		T_DEB_MS: natural;	--minimum debounce time in ms
		F_CLK_KHZ: natural); --clock frequency in kHz
	port (
		x, clk: in std_logic;
		y: out std_logic);
end entity;

architecture pushButton of debouncer is
	constant COUNTER_BITS: natural := 1 + integer(ceil(log2(real(T_DEB_MS*F_CLK_KHZ))));
begin

	process(clk)
		variable count: unsigned(COUNTER_BITS-1 downto 0);
		variable counter_done: std_logic; --indicates if we have finished the deb count
	begin
		-- Timer
		if rising_edge(clk) then
			-- reset the debounce counter if the input is high (active low button)
			if x then
				count := (others => '0');
				-- otherwise if the counter is not done then increment it
			elsif not counter_done then
				count := count + 1;
			end if;
		end if;
		
		-- Output register
		if falling_edge(clk) then
			-- if the switch is not pressed then reset the counter done indicator
			if x then
				counter_done := '0';
			end if;
			
			-- Invert y after it goes high so that the debounced output contains 1-clock
			--     length pulses to indicate button presses
			if y then
				y <= not y;
			end if;
			
			if count(COUNTER_BITS-1) then
				-- invert the output if we reached the end of the timer and set the
				--     indicator that we are done counting
				counter_done := '1';
				y <= '1';--not y;
			end if;
		end if;
		
		-- we are done counting so reset the debounce counter
		if counter_done then
			count := (others => '0');
		end if;
	
	end process;
		
end architecture;