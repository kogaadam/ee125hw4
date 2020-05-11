library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.subprograms_pkg.all;

entity timer is
	generic (
	
		-- desired clock frequency, in Hz
		F_CLK_DES: natural := 1;
		
		-- board clock frequency, in Hz
		F_CLK_BOARD: natural := 50000000);
	
	port (
		
		run, clear, clk: in std_logic;
		
		-- flag that goes high when the ssd's read 60 exactly
		is_60: out std_logic;
		
		-- encoding of digits for two ssd's
		dig1, dig2: out std_logic_vector(6 downto 0));
		
end entity;


architecture synchronous_timer of timer is

	-- upper bound for dig1 (seconds)
	constant MAX1: natural := 9;
	
	-- upper bound for dig2 (tens of seconds)
	constant MAX2: natural := 6;
	
	-- used to do clock division
	-- note that this value must be even for clock division
	-- 	to work properly
	constant CLK_DIVISOR: natural := F_CLK_BOARD / F_CLK_DES;
	
	-- result of clock division
	signal divided_clock: std_logic;
	
begin

	-- does clock division
	-- note that clock division does not work if CLK_DIVISOR is
	-- 	an odd number
	process(clk)
	
		-- counter for clock division
		variable i: natural range 0 to CLK_DIVISOR;
		
		-- stores output clock
		variable div_clock: std_logic;
		
	begin
		if rising_edge(clk) then
			i := i + 1;
			if i = (CLK_DIVISOR / 2) then
				i := 0;
				-- flip the clock
				div_clock := not div_clock;
			end if;
		end if;
		
		-- set the divided output clock
		divided_clock <= div_clock;
	end process;
	
	
	-- while run is enabled, count the derived clock, divided_clock,
	-- 	and update cnt1 and cnt2 accordingly
	-- this process is hard-coded to stop at MAX2 * 10
	process(divided_clock)
	
		-- internal counts which are mapped to ssd outputs
		variable cnt1: natural range 0 to MAX1;
		variable cnt2: natural range 0 to MAX2;
		
		-- internal flag to which indicates that maximum count has
		-- 	been achieved
		variable maxCntFlag: std_logic;
		
	begin
	
		if rising_edge(divided_clock) then
			-- if clear is active, reset both digits and maxCntFlag
			if clear = '1' then
				cnt1 := 0;
				cnt2 := 0;
				maxCntFlag := '0';	
			-- if clear is not active and run is active, allow the
			-- 	cnt1 and cnt2 to increment appropriately
			elsif run = '1' then
				-- first check if the count is saturated
				-- if it is, do not modify cnt1, cnt2 or maxCntFlag
				if (cnt1 = 0 and cnt2 = MAX2) then
					null;
				-- otherwise let cnt1 and cnt2 continue incrementing
				else
					-- if the ones digit, cnt1, is not at maximum, 
					-- 	increment it
					if cnt1 /= MAX1 then
						cnt1 := cnt1 + 1;
					-- otherwise reset it and increment the
					-- 	tens digit, cnt2
					else
						cnt1 := 0;
						-- if the tens digit, cnt2, is not at maximum, 
						-- 	increment it
						if cnt2 /= MAX2 then
							cnt2 := cnt2 + 1;
							-- and if the counter has saturated, set the led indicator
							-- this ensures the led indicator is set the same clock edge
							-- 	that the timer saturates, as stipulated by the question
							if cnt2 = MAX2 then
								maxCntFlag := '1';
							end if;
						end if;
					end if;
				end if;
			end if;			
		end if;
		
		-- the led is turned on when maxCntFlag goes high i.e. when
		-- 	the tens digit, cnt2, is at MAX2 and cnt1, the ones digit,
		-- 	is at 0
		is_60 <= maxCntFlag;
		
		-- convert the ones count, cnt1, and the tens count, cnt2, to ssd digits
		dig1 <= slv_to_ssd(std_logic_vector(to_unsigned(cnt1, 4)));
		dig2 <= slv_to_ssd(std_logic_vector(to_unsigned(cnt2, 4)));
		
	end process;
end architecture;
		
		

		
		
		
		
		