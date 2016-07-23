library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is --This controller is used to control the datapath.

	generic (
		width  :     positive := 32);
	port(	
		
		clk		      : in std_logic;
		rst 	      : in std_logic;
		
		op_code		  : in std_logic_vector(5 downto 0);
		
		alu_op        : out std_logic_vector(7 downto 0);
		alu_reg_en    : out std_logic;
		
		alu_a_mux_sel : out std_logic_vector(1 downto 0);
		alu_b_mux_sel : out std_logic_vector(1 downto 0); 
		
		inst_reg_en   : out std_logic;
		
		pc_mux_sel    : out std_logic_vector(1 downto 0);
		
		mem_reg_en    : out std_logic;
		mem_mux_sel   : out std_logic;
		
		data_mux_sel  : out std_logic;
		dest_mux_sel  : out std_logic;
		
		a_reg_en      : out std_logic;
		
		b_reg_en      : out std_logic;
		
		ram_wren      : out std_logic;		-- Read and Write enable for the RAM.
		
		reg_file_wren : out std_logic;		-- Read and Write enable for the register file.
		
		pc_write      : out std_logic;
		
		pc_write_cond : out std_logic;
		
		hi_reg_en     : out std_logic;
		
		lo_reg_en     : out std_logic
		
		);
	
end controller;

architecture bhv of controller is

	--Because some of the instructions are repetitive i've only implemented the main instructions.
	--This way I have more time to learn about the different types of instructions and work on the mif files.

	type state_type is (init_state, instruction_fetch, decode_instruction, r_load, r_operation, r_write, i_branch, compute_mem, 
						compute_mem_1, compute_mem_2, wait_state, load_word, load_word_2, load_word_3, store_word, store_word_2,
						j_jump, j_link, pc_inc, branch_load, branch_calculate, branch_check, branch_wait );
						
	signal state      : state_type;
	signal next_state : state_type;
	
begin

	process(clk, rst)
	
	begin 	
		if(rst = '1') then
			state <= init_state;
			
		elsif(rising_edge(clk)) then 
			state <= next_state;
			
		end if;
	end process;
	
	process(state, op_code)
	
	begin 
	         
		alu_op <= x"08";
			
		alu_reg_en <= '0'; -- Disable loading of all registers by default.
		
		alu_a_mux_sel <= "00"; -- Select the PC register by default.
		alu_b_mux_sel <= "01"; -- Select the increment number (4) by default.
		
		inst_reg_en <= '0'; 
		  
		pc_mux_sel <= "00"; -- By default we want the mux that feeds the PC register to select data from the ALU.
		
		mem_reg_en <= '0';
		mem_mux_sel <= '0'; -- Route the address from the PC register by default. 
		
		data_mux_sel <= '0'; -- Set default data to be stored into the destination register from alu.
		dest_mux_sel <= '1'; -- Set default destination register from bits 15 downto 11.
		
		a_reg_en <= '0'; 
		
		b_reg_en <= '0';       
		
		ram_wren <= '0'; -- Do not want to write to memory by default.  	
		
		reg_file_wren <= '0'; -- Disable write enable on register file by default.
		
		pc_write <= '0';
		
		pc_write_cond <= '0';
		
		hi_reg_en <= '0';
		
		lo_reg_en <='0';
	
	
	case(state) is

		when init_state =>
		    
			next_state <= instruction_fetch;
			
		when instruction_fetch => -- This state fetches the instruction.
		
			inst_reg_en <= '1';
			
			next_state <= decode_instruction;
			
		when pc_inc =>
		
			pc_write <= '1';
			
			next_state <= init_state;
			
			
		when decode_instruction => 
		
			case(op_code) is
			
			when("000000") => -- R-Type
			
			next_state <= r_load;
			
			when("100011") => -- 0x23 Load Word
			
			
			next_state <= compute_mem;
			
			when("101011") => -- 0x2B Store Word
			
			next_state <= compute_mem;
			
			when("000010") => -- 0x02 Jump to Address
			
			pc_mux_sel <= "10"; -- The shifted value + the pc register.
			pc_write <= '1';
			
			next_state <= init_state; -- Wait for pc register to load so go to the init_state instead of instruction_fetch state.
			
			when("000100") => -- 0x04 Branch if equal.
			
			pc_write <= '1'; -- The offset is added to the next address not the current.
			next_state <= branch_load;
			
			when("000101") => -- 0x05 Branch if not equal.
			
			pc_write <= '1';
			next_state <= branch_load;
			
			when("000110") => -- 0x06 Branch if less than or equal to zero.
			 
			pc_write <= '1'; -- The offset is added to the next address not the current.
			next_state <= branch_load;
			
			when("000111") => -- 0x07 Branch on greater than zero.
			
			pc_write <= '1'; -- The offset is added to the next address not the current.
			next_state <= branch_load;
			
			when("000001") => -- 0x01 Branch on less than zero, Branch on greater or equal zero.
			
			pc_write <= '1'; -- The offset is added to the next address not the current.
			next_state <= branch_load;
			
			when others =>
			
			next_state <= instruction_fetch;
			
			end case;
		when compute_mem =>
			a_reg_en <= '1';
			next_state <= compute_mem_1;
			
		when compute_mem_1 =>
		
			alu_b_mux_sel <= "10"; -- Set sign extended immediate value as input2.
			alu_a_mux_sel <= "01"; -- Set register A as input1.
			alu_op <= x"23";	   -- Set the ALU to add signed numbers.
			alu_reg_en <= '1';	   -- Enable the ALU register.
			
			next_state <= compute_mem_2;
			
		when compute_mem_2 =>
		
			if(op_code = "100011") then 
				next_state <= load_word;
			elsif(op_code = "101011") then
				b_reg_en <= '1'; -- 
				next_state <= store_word;
			else
				next_state <= pc_inc;
			end if;
			
		when load_word =>
		
			mem_mux_sel <= '1';    -- Set the address to RAM from the ALU output register.
			
			next_state <= load_word_2;
		
		when load_word_2 =>
		
			mem_reg_en <= '1'; 	   -- Enable memory register.
			
			next_state <= load_word_3;
			
		when load_word_3 =>
			
			dest_mux_sel <= '0';   -- Set the destination register from bits 20 downto 16.
			data_mux_sel <= '1';   -- Data to come from memory data register.
			reg_file_wren <= '1';  -- Write Data to register file.
			
			next_state <= pc_inc;
			
		when store_word_2 =>
		
			ram_wren <= '1';
			
			next_state <= pc_inc;
			
		when r_load =>
			a_reg_en <= '1';
			b_reg_en <= '1';
			
			next_state <= r_operation;
			
		when r_operation =>
			alu_op <= x"00";
			alu_a_mux_sel <= "01";
			alu_b_mux_sel <= "00";
			alu_reg_en <= '1';
			
			next_state <= r_write;
			
		when r_write =>
		
			reg_file_wren <= '1';
			
			next_state <= wait_state;
			
		when branch_load =>
		
			next_state <= branch_calculate;
			
		when branch_calculate =>
		
			alu_b_mux_sel <= "11"; -- Select the offset that is sign extended and aligned.
			alu_op <= x"23"; -- Set alu_op to add unsigned.
			alu_reg_en <= '1'; -- Save the data.
			a_reg_en <= '1';
			b_reg_en <= '1';
			
			next_state <= branch_check;
			
		when branch_check =>
			
			alu_a_mux_sel <= "01";
			alu_b_mux_sel <= "00";
			pc_mux_sel <= "01"; -- Set pc to get data from alu register incase branch is needed.
			pc_write_cond <= '1';
			
			if(op_code = "000100") then 
				alu_op <= x"04"; -- Set alu to check beq conditions.
				next_state <= branch_wait;
			elsif(op_code = "000101") then 
				alu_op <= x"05";
				next_state <= branch_wait;
			elsif(op_code = "000110") then 
				alu_op <= x"06";
				next_state <= branch_wait;
			elsif(op_code = "000111") then 
				alu_op <= x"07";
				next_state <= branch_wait;
			elsif(op_code = "000001") then 
				alu_op <= x"01";
				next_state <= branch_wait;
			else
				next_state <= wait_state;
			end if;
				
			
		when branch_wait =>
		
			next_state <= init_state;
			
		
			
		when wait_state =>
		
			next_state <= pc_inc;
			
			
		when others =>
			next_state <= instruction_fetch;
		end case;
		
	end process;
	
	



end bhv;