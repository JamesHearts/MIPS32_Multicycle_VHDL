library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is 

generic (
    width  :     positive := 32);
	
    port
    (
    output1       : out std_logic_vector(WIDTH-1 downto 0);
    output2       : out std_logic_vector(WIDTH-1 downto 0);
    input         : in  std_logic_vector(WIDTH-1 downto 0);
    wren  		  : in std_logic;
    reg1_source   : in std_logic_vector(4 downto 0);
    reg2_source   : in std_logic_vector(4 downto 0);
    reg3_dest	  : in std_logic_vector(4 downto 0);
    clk           : in std_logic;
    rst           : in std_logic
    );
end register_file;

architecture behavioral of register_file is

	type registerFile is array(0 to (WIDTH-1)) of std_logic_vector((WIDTH-1) downto 0);
	signal registers : registerFile;

begin
	process (rst,clk) is
	
	begin
	if (rst = '1') then 
		output1 <= x"00000000";
		output2 <= x"00000001";
		
	  for i in 0 to 31 loop				  
		registers(i) <=(others =>'0');
	  end loop;
	  
	elsif (rising_edge(clk)) then
			-- Read A and B before bypass
			output1 <= registers(to_integer(unsigned(reg1_source)));
			output2 <= registers(to_integer(unsigned(reg2_source)));
			
			-- Write and bypass
		if wren = '1' then
		
			registers(to_integer(unsigned(reg3_dest))) <= input;  -- Write
			
			if reg1_source = reg3_dest then  -- Bypass for read A
				output1 <= input;
			end if;
		
			if reg2_source = reg3_dest then  -- Bypass for read B
				output2 <= input;
			end if;
		end if;
    end if;
	
  end process;
  
end behavioral;