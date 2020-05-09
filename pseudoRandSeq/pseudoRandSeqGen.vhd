library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pseudoRandSeqGen is
	generic (
		F_CLK_HZ: natural := 1; --desired clock frequency
		INT_F_CLK_HZ: natural := 50_000_000); --internal clock frequency of board
	port (
		rst, clk: in std_logic;
		led1, led2, outp: out std_logic);
end entity;

architecture randNumGen of pseudoRandSeqGen is
	-- divisors used to divide down the slow ouput and LED clocks
	-- want LED clock to be twice as fast as the output clock since they are enabled
	--     for half the period of the output
	constant CLK_DIVISOR: natural := INT_F_CLK_HZ / F_CLK_HZ / 2;
	constant LED_CLK_DIVISOR: natural := INT_F_CLK_HZ / F_CLK_HZ / 4;
	
	signal outp_clk, led_clock: std_logic; --clock for how often the output updates
														--and for when the LEDs are enabled
	-- outputs of each flip flop in the shift register
	signal q1, q2, q3, q4, q5, q6, q7, q8: std_logic;
begin

	-- Output clock divider
	process(clk)
		variable i: natural; --index of counter
		variable outp_clk_var: std_logic; --variable used to store divided clock
	begin
		-- on the rising edge count until the set divisor then reset
		if rising_edge(clk) then
			i := i + 1;
			if i = CLK_DIVISOR then
				i := 0;
				-- flip the clock when the count is reached
				outp_clk_var := not outp_clk_var;
			end if;
		end if;
		
		-- store the clock here
		outp_clk <= outp_clk_var;
	
	end process;
	
	-- LED enable clock divider
	process(clk)
		variable i: natural; --index of counter
		variable led_clock_var: std_logic; --variable used to store divided clock
	begin
		-- on the rising edge count until the set divisor then reset
		if rising_edge(clk) then
			i := i + 1;
			if i = LED_CLK_DIVISOR then
				i := 0;
				-- flip the clock when the count is reached
				led_clock_var := not led_clock_var;
			end if;
		end if;
		
		-- store the clock here
		led_clock <= led_clock_var;
	
	end process;
	
	
	-- Shifter
	process(outp_clk)

	begin
		-- set the appropriate flip flop outputs on reset
		if rst = '1' then
			q8 <= '1';
			q7 <= '0';
			q6 <= '1';
			q5 <= '0';
			q4 <= '1';
			q3 <= '0';
			q2 <= '1';
			q1 <= '0';
		else
			-- on the rising edge of the slow output clock perform the LFSR shifting
			--     based on which bits are taps, connected to the output, etc
			if rising_edge(outp_clk) then
				q8 <= outp;
				q7 <= q8;
				q6 <= outp xor q7;
				q5 <= outp xor q6;
				q4 <= outp xor q5;
				q3 <= q4;
				q2 <= q3;
				q1 <= q2;
			end if;
		end if;
	
		-- store the new output here
		outp <= q1;
	
	end process;
	
	process(led_clock)
		variable led_enable: std_logic; --when to allow one of the LEDs to turn on
	begin
		-- toggle enabling the LEDs on the slow clock we constructed
		if rising_edge(led_clock) then
			led_enable := not led_enable;
			-- when enabled set one LED to the output and the other to the inverted
			--     output so only one is on at a time
			if led_enable = '1' then
				led1 <= outp;
				led2 <= not outp;
			-- otherwise disable both LEDs
			else
				led1 <= '0';
				led2 <= '0';
			end if;
		end if;
	end process;
	

end architecture;