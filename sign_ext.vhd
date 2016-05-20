library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_ext is
generic (
			WIDTH : positive := 16);
	port (
		input  : in unsigned(WIDTH-1 downto 0);
		output : out std_logic_vector((WIDTH*2)-1 downto 0)
		
		);

end sign_ext;

architecture SIGNEXT of sign_ext is

begin

process

begin

	if(input(WIDTH-1) = '1') then
		output <= std_logic_vector(x"FF" & input);
	elsif(input(WIDTH-1) = '0') then
		output <= std_logic_vector(x"00" & input);
	end if;
	
end process;
	
end SIGNEXT;