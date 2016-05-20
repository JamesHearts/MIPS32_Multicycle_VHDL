library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity left_shift is
generic (
			WIDTH : positive := 32);
	port (
		input  : in unsigned(WIDTH-1 downto 0);
		output : out std_logic_vector(WIDTH-1 downto 0)
		
		);

end left_shift;

architecture SHIFTLEFT of left_shift is

	

begin
		
		output <= std_logic_vector(shift_left(input, 2));

	
end SHIFTLEFT;