library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is -- This datapath will be used with a controller.

	generic (
		width  :     positive := 32);
	port(
	
		clk		      : in std_logic;
		rst 	      : in std_logic;
		
		inc_number    : in std_logic_vector(31 downto 0); --Number to increment PC by.
		arb_number    : in std_logic_vector(31 downto 0); --Arbitrary signal just incase it is needed.
		alu_sel       : in std_logic_vector(3 downto 0);
		alu_reg_en    : in std_logic;
		
		alu_a_mux_sel : in std_logic;
		alu_b_mux_sel : in std_logic_vector(1 downto 0);
		
		inst_reg_en   : in std_logic;
		
		pc_reg_en     : in std_logic;
		pc_mux_sel    : in std_logic_vector(1 downto 0);
		
		mem_reg_en    : in std_logic;
		mem_mux_sel   : in std_logic;
		
		data_mux_sel  : in std_logic;
		dest_mux_sel  : in std_logic;
		
		a_reg_en      : in std_logic;
		
		b_reg_en      : in std_logic;
		
		zflag         : out std_logic;
		
		ram_wren      : in std_logic;		-- Read and Write enable for the RAM.
		
		reg_file_wren : in std_logic		-- Read and Write enable for the register file.
		
		
		
		);
	
end datapath;

architecture str of datapath is

	signal inst_reg_out   : std_logic_vector(WIDTH-1 downto 0); 
	signal alu_reg_out    : std_logic_vector(WIDTH-1 downto 0);
	signal pc_reg_out     : std_logic_vector(WIDTH-1 downto 0);
	signal mem_reg_out    : std_logic_vector(WIDTH-1 downto 0);
	signal a_reg_out 	  : std_logic_vector(WIDTH-1 downto 0);
	signal b_reg_out      : std_logic_vector(WIDTH-1 downto 0);
	signal alu_out        : std_logic_vector(WIDTH-1 downto 0);
	signal sign_ext_out   : std_logic_vector(WIDTH-1 downto 0);
	signal sl_branch_out  : std_logic_vector(WIDTH-1 downto 0);
	signal sl_jump_out    : std_logic_vector(27 downto 0);
	signal alu_b_mux_out  : std_logic_vector(WIDTH-1 downto 0);
	signal alu_a_mux_out  : std_logic_vector(WIDTH-1 downto 0);
	signal pc_mux_out     : std_logic_vector(WIDTH-1 downto 0);
	signal mem_mux_out    : std_logic_vector(WIDTH-1 downto 0);
	signal data_mux_out   : std_logic_vector(WIDTH-1 downto 0);
	signal dest_mux_out   : std_logic_vector(4 downto 0);
	signal reg_a_file_out : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_file_out : std_logic_vector(WIDTH-1 downto 0);
	signal ram_out        : std_logic_vector(WIDTH-1 downto 0);
	

begin

	ALU	: entity work.alu -- The ALU entity.
		port map(
		
			input1  => unsigned(alu_a_mux_out),
			input2	=> unsigned(alu_b_mux_out),
			sel		=> alu_sel,
			output	=> alu_out,
			zout    => zflag
		);
		
	ALU_REG : entity work.reg -- The ALU output register.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> alu_out,
			output	=> alu_reg_out,
			en		=> alu_reg_en
		);
		
	INST_REG : entity work.reg -- The instruction register.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> ram_out,
			output	=> inst_reg_out,
			en		=> inst_reg_en
		);
		
	PC_REG : entity work.reg -- The PC register.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> pc_mux_out,
			output	=> pc_reg_out,
			en		=> pc_reg_en
		);
		
	MEM_REG : entity work.reg -- Memory register, holds current memory address. Used to calculate jumps and branches.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> ram_out,
			output	=> mem_reg_out,
			en		=> mem_reg_en
		);
		
	A_REG : entity work.reg -- The output register for output A of register file.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> reg_a_file_out,
			output	=> a_reg_out,
			en		=> a_reg_en
		);
		
	B_REG : entity work.reg -- The output register for output B of register file.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> reg_b_file_out,
			output	=> b_reg_out,
			en		=> b_reg_en
		);
		
	SIGN_EXT : entity work.sign_ext -- This module does sign extension. Could also use ALU for this.
		port map(
			input	=> unsigned(inst_reg_out((WIDTH/2)-1 downto 0)),
			output	=> sign_ext_out
		);
		
	SHIFT_LEFT_BRANCH : entity work.left_shift -- This module performs a left shift twice.
		port map(
			input  => unsigned(sign_ext_out),
			output => sl_branch_out
		);
		
	SHIFT_LEFT_JUMP : entity work.left_shift -- This module performs a left shift twice. 
		port map(
			input  => unsigned(inst_reg_out(25 downto 0)),
			output => sl_jump_out
		);
		
	MEM_MUX : entity work.mux_2x1 -- The mux that feeds the memory register.
		port map(
			in1	   => pc_reg_out,
			in2	   => alu_reg_out,
			sel	   => mem_mux_sel, 
			output => mem_mux_out
		);
	
	DEST_MUX : entity work.mux_2x1 -- The mux that feeds the destination register in the register file.
		port map(
			in1	   => inst_reg_out(20 downto 16),
			in2	   => inst_reg_out(15 downto 11),
			sel	   => dest_mux_sel,
			output => dest_mux_out
		);
		
	DATA_MUX : entity work.mux_2x1 -- The mux that feeds the data input to the destination register.
		port map(
			in1	   => alu_reg_out,
			in2	   => mem_reg_out,
			sel	   => data_mux_sel,
			output => data_mux_out
		);
		
	ALU_A_MUX : entity work.mux_2x1 -- The mux that feeds the A input to the ALU.
		port map(
			in1	   => pc_reg_out,
			in2	   => a_reg_out,
			sel	   => alu_a_mux_sel,
			output => alu_a_mux_out
		);
		
	ALU_B_MUX : entity work.mux_4x1 -- The mux that feeds the B input to the ALU.
		port map(
			in1	   => b_reg_out,
			in2	   => inc_number,
			in3	   => sign_ext_out,
			in4    => sl_branch_out,
			sel	   => alu_b_mux_sel,
			output => alu_b_mux_out
		);
		
	PC_MUX : entity work.mux_4x1 -- The mux that feeds the PC register.
		port map(
			in1	   => alu_out,
			in2	   => alu_reg_out,
			in3    => sl_jump_out,
			in4	   => arb_number,
			sel	   => pc_mux_sel,
			output => pc_mux_out
		);
		
	REG_FILE : entity work.register_file -- The register file contains all 32 registers.
		port map(
			output1       => reg_a_file_out,
			output2       => reg_b_file_out,
			input         => data_mux_out,
			wren  		  => reg_file_wren,
			reg1_source   => inst_reg_out(25 downto 21),
			reg2_source   => inst_reg_out(20 downto 16),
			reg3_dest	  => dest_mux_out,
			clk           => clk
		
		);
		
	RAM : entity work.mips_ram -- Not sure if the RAM implementation is the correct one but needed to compile datapath.
		port map(
			address	=>  pc_mux_out,
			clock	=>	clk,
			data	=>  b_reg_out,
			wren	=>	ram_wren,
			q		=>  ram_out
		
		);
	

end str;