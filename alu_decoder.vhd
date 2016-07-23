library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_decoder is --This decoder determines the select value of the ALU.

	generic (
		width  :     positive := 32);
	port(	
		
			inst_reg_out : in std_logic_vector(5 downto 0);
			alu_op       : in std_logic_vector(7 downto 0);
			alu_sel      : out std_logic_vector(7 downto 0)
		);
	
end alu_decoder;

architecture bhv of alu_decoder is

begin

	process(alu_op, inst_reg_out)
	
	variable inst_reg_out_temp : std_logic_vector(7 downto 0);
	
	begin 
	
	alu_sel <= (others => '0');
	inst_reg_out_temp := "00" & inst_reg_out;
	
	case(alu_op) is

		when x"00" => -- R_Type
		
			case(inst_reg_out_temp) is
				
				when x"21" => -- addu
					alu_sel <= x"00";
				when x"23" => -- subu
					alu_sel <= x"01";
				when x"19" => -- multu
					alu_sel <= x"02";
				when x"18" => -- mult
					alu_sel <= x"03";
				when x"24" => -- and
					alu_sel <= x"04";
				when x"25" => -- or
					alu_sel <= x"05";
				when x"26" => -- xor
					alu_sel <= x"06";
				when x"02" => -- srl
					alu_sel <= x"08";
				when x"00" => -- sll
					alu_sel <= x"07";
				when x"2A" => -- slt
					alu_sel <= x"0A";
				when x"28" => -- sltu
					alu_sel <= x"0B";
				when x"10" => -- mfhi
					alu_sel <= x"0C";
				when x"12" => -- mflo
					alu_sel <= x"0C";
				when x"08" => -- jr
					alu_sel <= x"0E";
				when others =>
				null;
				
				end case;
		
		when x"08" => -- addiu
			alu_sel <= x"00";
		when x"0C" => -- andi
			alu_sel <= x"04";
		when x"0D" => -- ori
			alu_sel <= x"05";
		when x"0E" => -- xori
			alu_sel <= x"06";
		when x"09" => -- slti
			alu_sel <= x"0A";
		when x"0B" => -- sltiu
			alu_sel <= x"0B";
		when x"23" => -- lw
			alu_sel <= x"13";
		when x"2B" => -- sw
			alu_sel <= x"13";
		when x"20" => -- lb
			alu_sel <= x"0C";
		when x"28" => -- sb
			alu_sel <= x"0C";
		when x"24" => -- lbu
			alu_sel <= x"0C";
		when x"21" => -- lh
			alu_sel <= x"0C";
		when x"25" => -- lhu
			alu_sel <= x"0C";
		when x"29" => -- sh
			alu_sel <= x"0C";
		when x"04" => -- beq 	
			alu_sel <= x"11";
		when x"05" => -- bne
			alu_sel <= x"12";
		when x"06" => -- blez
			alu_sel <= x"10";
		when x"07" => -- bgtz
			alu_sel <= x"0F";
		when x"01" => -- bltz & bgez
			alu_sel <= x"0E";
		when x"02" => -- j
			alu_sel <= x"0C";
		when x"03" => -- jal
			alu_sel <= x"0C";
		when others =>
		null;
			
		end case;
		
	end process;
	
	



end bhv;