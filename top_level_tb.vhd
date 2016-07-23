library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end top_level_tb;

architecture TB of top_level_tb is

  -- MODIFY TO MATCH YOUR TOP LEVEL
  component top_level
    port ( 
	       	signal clk		: in std_logic;
			signal rst 		: in std_logic
		 ); 
		
  end component;

	    signal clk   	: std_logic := '1';
		signal rst 		: std_logic := '1';
		

begin  -- TB

  -- MODIFY TO MATCH YOUR TOP LEVEL
  UUT : top_level port map (
	    clk => clk,
		rst => rst
		
	);
	
	--rst2 <= '1';
		
	clk <= not clk after 10 ns;
	
	
  
  process
  begin
	 
	wait for 40 ns;
	
	rst <= '0';
	
	wait for 40 ns;
	 
	report "done";
	
	wait;
	
  end process;

end TB;