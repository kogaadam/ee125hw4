library ieee;
use ieee.std_logic_1164.all;

package subprograms_pkg is
	function slv_to_ssd (input: std_logic_vector) return std_logic_vector;
end package;

package body subprograms_pkg is

	
	function slv_to_ssd (input: std_logic_vector) return std_logic_vector is
	begin
		case input is
			when "0000" => return "0000001";		--"0" on SSD
			when "0001" => return "1001111";		--"1" on SSD
			when "0010" => return "0010010";		--"2" on SSD
			when "0011" => return "0000110";		--"3" on SSD
			when "0100" => return "1001100";		--"4" on SSD
			when "0101" => return "0100100";		--"5" on SSD
			when "0110" => return "0100000";		--"6" on SSD
			when "0111" => return "0001111";		--"7" on SSD
			when "1000" => return "0000000";		--"8" on SSD
			when "1001" => return "0000100";		--"9" on SSD
			when "1010" => return "0001000";		--"A" on SSD
			when "1011" => return "1100000";		--"b" on SSD
			when "1100" => return "0110001";		--"C" on SSD
			when "1101" => return "1000010";		--"d" on SSD
			when "1110" => return "0110000";		--"E" on SSD
			when "1111" => return "0111000";		--"F" on SSD
			when others => return "1111110";		--"-" on SSD
		end case;
	end function slv_to_ssd;

end package body;