library ieee;
use ieee.std_logic_1164.all;

entity oneShotPulseCapt is
    port (
	 
	     -- input clock of arbitrary frequency
	     clk: in std_logic;
		  
		  -- input pulse train
		  p_in: in std_logic;
		  
		  -- output one-shot pulse train
		  p_out: out std_logic);
		  
end entity;


architecture pulseConditioning of oneShotPulseCapt is
    
	 -- output of each flip flop
	 signal q0, q1, q2: std_logic;
	 
begin

    process(clk)
	 begin
	     if rising_edge(clk) then
		      -- create three flip flops with the same clock but
				--    cascaded inputs
		      q0 <= p_in;
				q1 <= q0;
				q2 <= q1;
	     end if;
	 end process;

    -- use the trick prescribed in the textbook
    p_out <= (q1 and (not q2));
	 
end architecture;
	 
	 
	 
	 
	 
		  
	 