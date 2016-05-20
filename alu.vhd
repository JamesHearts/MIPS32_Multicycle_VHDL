library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
generic (
			WIDTH : positive := 32);
	port (
		input1  : in unsigned(WIDTH-1 downto 0);
		input2 	: in unsigned(WIDTH-1 downto 0);
		sel  	: in std_logic_vector(3 downto 0);
		output 	: out std_logic_vector(WIDTH-1 downto 0);
		zout 	: out std_logic
		);

end alu;

architecture ALU of alu is

begin

	
process (input1, input2, sel)

	variable temp_result : unsigned(WIDTH downto 0);
	variable temp_mult_unsigned : unsigned((WIDTH * 2)-1 downto 0);
	variable temp_mult_signed : signed((WIDTH * 2)-1 downto 0);
	variable temp_boolean : unsigned(WIDTH-1 downto 0);
	variable temp_shift : unsigned(WIDTH-1 downto 0);
	variable temp_shift_signed : signed(WIDTH-1 downto 0);
	
	begin
	
	zout <= '0';
	output <= (others => '0');
	
		case sel is
			when "0000" => --ADD
				
				temp_result := ('0' & input1) + ('0' & input2);
				output <= std_logic_vector(temp_result(WIDTH-1 downto 0));
				
				if(temp_result = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
					
			when "0001" => --SUB
			
				temp_result:= ('0' & input1) + not('0' & input2) + 1;
				output <= std_logic_vector(temp_result(WIDTH-1 downto 0));
				
				if(temp_result = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
			when "0010" => --MULT unsigned	LOW
			
				temp_mult_unsigned := unsigned(input1) * unsigned(input2);
				output <= std_logic_vector(temp_mult_unsigned((WIDTH-1) downto 0));
				
				if(temp_mult_unsigned = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
			when "0011" => --MULT unsigned HIGH
			
				temp_mult_unsigned := unsigned(input1) * unsigned(input2);
				output <= std_logic_vector(temp_mult_unsigned((WIDTH) downto (WIDTH-1)));
				
				if(temp_mult_unsigned = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
			when "0100" => --MULT LOW
			
				temp_mult_signed := signed(input1) * signed(input2);
				output <= std_logic_vector(temp_mult_signed((WIDTH-1) downto 0));
				
				if(temp_mult_signed = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
			when "0101" => --MULT HIGH
			
				temp_mult_signed := signed(input1) * signed(input2);
				output <= std_logic_vector(temp_mult_signed((WIDTH) downto (WIDTH-1)));
				
				if(temp_mult_signed = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
			
						
			when "0110" => --AND
				temp_boolean := input1 and input2;
				
				if(temp_boolean = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_boolean);
				
			when "0111" => --OR
				temp_boolean := input1 or input2;
				
				if(temp_boolean = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_boolean);
				
			when "1000" => --XOR
				temp_boolean := input1 xor input2;
				
				if(temp_boolean = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_boolean);
				
			when "1001" => --SLL
				temp_shift := shift_left(input1, 1);
				
				if(temp_shift = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_shift);
				
			when "1010" => --SRL
				temp_shift := shift_right(input1, 1);
				
				if(temp_shift = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_shift);
				
			when "1011" => --SRA
				temp_shift_signed := shift_right(signed(input1), 1);
				
				if(temp_shift_signed = 0) then
					zout <= '1';
				else 
					zout <= '0';
				end if;
				
				output <= std_logic_vector(temp_shift_signed);
				
			when others =>
		
		end case;
		
end process;

end ALU;
