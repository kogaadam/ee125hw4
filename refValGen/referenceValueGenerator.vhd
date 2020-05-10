library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.subprograms_pkg.all;

entity referenceValueGenerator is

	generic (
		T_DEB_MS: natural := 20;		 --minimum debounce time in ms
		F_CLK_KHZ: natural := 50_000); --clock frequency in kHz

	port (
		up, dn, clk, rst: in std_logic; --up or down counter inputs, clock and reset
		ref: out std_logic_vector(4 downto 0); --result of the counter (reference value)
		ssd1, ssd0: out std_logic_vector(6 downto 0)); --ssd digit outputs

end entity;

architecture refValGen of referenceValueGenerator is
	signal debounceUpOutput, debounceDnOutput: std_logic; --signals for debounced up
																			--    and down buttons
	signal result: unsigned(4 downto 0);						--result of the up or down
																			--    counting
	signal dig1, dig0: std_logic_vector(3 downto 0);		--bcd digits

begin

	-- Debounce the up button press
	doUpDebounce: entity work.debouncer
		generic map (
			T_DEB_MS, F_CLK_KHZ)
		port map (
			up, clk, debounceUpOutput);
			
	-- Debounce the down button press
	doDnDebounce: entity work.debouncer
		generic map (
			T_DEB_MS, F_CLK_KHZ)
		port map (
			dn, clk, debounceDnOutput);
	
	-- Change the result of the counter depending on which button was pressed
	process(clk)
	
	begin
		if rising_edge(clk) then
			-- Up button debounced output high so increment unless we are at the max
			if debounceUpOutput then
				if result /= "10100" then
					result <= result + "00001";
				end if;
			-- Down button debounced output high so decrement unless we are at the min
			elsif debounceDnOutput then
				if result /= "00000" then
					result <= result - "00001";
				end if;
			end if;
		end if;
		
		-- Store the reference value
		ref <= std_logic_vector(result);
		
		-- Deal with reset
		if rst then
			result <= "00000";
			ref <= "00000";
		end if;
			
	end process;
	
	
	-- Convert to BCD
	process(ref)
		variable bin_cpy: std_logic_vector(4 downto 0); --copy of the binary input
		variable bcd: unsigned(7 downto 0); --full bcd output vector
	begin
	
		bin_cpy := ref; --set binary input to reference value
		bcd := (others => '0'); --initialize the bcd value
	
		-- Perform the double-dabble algorithm
		for i in 0 to 4 loop
			
			-- If the lower BCD digit is larger than 4 add 3 to it
			--     (dont need to check the higher BCD digit since the max value is 20)
			if bcd(3 downto 0) > 4 then
				bcd(3 downto 0) := bcd(3 downto 0) + 3;
			end if;
			
			-- Shift the bcd value left and get the LSB from the MSB of the binary input
			bcd := bcd(6 downto 0) & bin_cpy(4);
			-- Shift the binary input left
			bin_cpy := bin_cpy(3 downto 0) & '0';
		
		end loop;
		
		-- Get the bcd digits on their own and convert them to SSD values
		dig0 <= std_logic_vector(bcd(3 downto 0));
		ssd0 <= slv_to_ssd(dig0);
		dig1 <= std_logic_vector(bcd(7 downto 4));
		ssd1 <= slv_to_ssd(dig1);
		
	end process;
	
	
end architecture;