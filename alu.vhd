library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
generic (
			WIDTH : positive := 32);
	port(
		input1    : in unsigned(WIDTH-1 downto 0);
		input2 	  : in unsigned(WIDTH-1 downto 0);
		sel  	  : in std_logic_vector(7 downto 0);
		output 	  : out std_logic_vector(WIDTH-1 downto 0);
		output_lo : out std_logic_vector(WIDTH-1 downto 0);
		output_hi : out std_logic_vector(WIDTH-1 downto 0);
		branch_out: out std_logic_vector(WIDTH-1 downto 0);
		zout 	  : out std_logic
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
	variable temp_output : std_logic_vector(WIDTH-1 downto 0);
	
	begin
	
	zout <= '0';
	output <= (others => '0');
	temp_output := (others => '0');
	output_lo <= (others => '0');
	output_hi <= (others => '0');
	branch_out <= (others => '0');
	
	
		case sel is
			when x"00" => --ADD
				
				temp_result := ('0' & input1) + ('0' & input2);
				temp_output := std_logic_vector(temp_result(WIDTH-1 downto 0));
				
				branch_out <= std_logic_vector(input1 + input2);

					
			when x"01" => --SUB
			
				temp_result := ('0' & input1) + not('0' & input2) + 1;
				temp_output := std_logic_vector(temp_result(WIDTH-1 downto 0));

				
			when x"02" => --MULT unsigned
			
				temp_mult_unsigned := unsigned(input1) * unsigned(input2);
				output_lo <= std_logic_vector(temp_mult_unsigned(WIDTH-1 downto 0));
				output_hi <= std_logic_vector(temp_mult_unsigned((WIDTH*2)-1 downto WIDTH));
				
				
			when x"03" => --MULT
			
				temp_mult_signed := signed(input1) * signed(input2);
				output_lo <= std_logic_vector(temp_mult_signed(WIDTH-1 downto 0));
				output_hi <= std_logic_vector(temp_mult_signed((WIDTH*2)-1 downto WIDTH));
				
			when x"04" => --AND
			
				temp_boolean := input1 and input2;
				
				temp_output := std_logic_vector(temp_boolean);

				
			when x"05" => --OR
			
				temp_boolean := input1 or input2;
				
				temp_output := std_logic_vector(temp_boolean);
						
			when x"06" => --XOR
				
				temp_boolean := input1 xor input2;
				
				temp_output := std_logic_vector(temp_boolean);
				
			when x"07" => --SLL
				
				temp_shift := shift_left(input1, 1);
				
				temp_output := std_logic_vector(temp_shift);
				
			when x"08" => --SRL
				
				temp_shift := shift_right(input1, 1);
				
				temp_output := std_logic_vector(temp_shift);
				
			when x"09" => --SRA
				
				temp_shift_signed := shift_right(signed(input1), 1);
				
				temp_output := std_logic_vector(temp_shift_signed);
				
			when x"0A" => --SLT
				
				if(signed(input2) < signed(input1)) then
					temp_output := (others => '1');
				else 
					temp_output := (others => '0');
				end if;
				
			when x"0B" => --SLTU
				
				if(input2 < input1) then
					temp_output := (others => '1');
				else
					temp_output := (others => '0');
				end if;
				
			when x"0C" => --Input A to Output
				
				temp_output := std_logic_vector(input1);
				
			when x"0D" => --Input B to Output
				
				temp_output := std_logic_vector(input2);
				
			when x"0E" => --Compare less than zero. Compare greater than or equal to zero.
			
				if(input2 = 0) then 
					if(input1 < 0) then
						temp_output := (others => '0');
					end if;
				elsif(input2 = 1) then 
					if(input1 >= 0) then
						temp_output := (others => '0');
					end if;
				end if;
				
				branch_out <= std_logic_vector(input1 + input2);
				
			
			when x"0F" => --Compare greater than zero.
			
				if(input1 > 0) then
					temp_output := (others => '0');
				end if;
				
				branch_out <= std_logic_vector(input1 + input2);
				
			when x"10" => --Compare less than or equal to zero.
			
				if(input1 <= 0) then
					temp_output := (others => '0');
				end if;
				
				branch_out <= std_logic_vector(input1 + input2);
					
			when x"11" => --Compare equal to.
				
				if(input1 = input2) then
					temp_output := (others => '0');
				end if;
				
				branch_out <= std_logic_vector(input1 + input2);
				
			when x"12" => --Compare not equal to. 
				
				if(input1 /= input2) then 
					temp_output := (others => '0');
				end if;
				
				branch_out <= std_logic_vector(input1 + input2);
				
			when x"13" => -- ADD signed (For forwards and backwards);
			
				temp_output := std_logic_vector(signed(input1) + signed(input2));
					
			when others =>
			
				null;
		
		end case;
		
		if(temp_output = x"00000000") then
			zout <= '1';
		else 
			zout <= '0';
		end if;
		
		output <= temp_output;
		
end process;

end ALU;
