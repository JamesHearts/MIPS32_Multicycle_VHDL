library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is -- This datapath will be used with a controller.

	generic (
		width  :     positive := 32);
	port(
	
		clk		      : in std_logic;
		rst 	      : in std_logic;

		alu_reg_en    : in std_logic;
		
		alu_a_mux_sel : in std_logic_vector(1 downto 0);
		alu_b_mux_sel : in std_logic_vector(1 downto 0);
		
		inst_reg_en   : in std_logic;
		
		pc_mux_sel    : in std_logic_vector(1 downto 0);
		
		mem_reg_en    : in std_logic;
		mem_mux_sel   : in std_logic;
		
		data_mux_sel  : in std_logic;
		dest_mux_sel  : in std_logic;
		
		a_reg_en      : in std_logic;
		
		b_reg_en      : in std_logic;
		
		ram_wren      : in std_logic;		-- Read and Write enable for the RAM.
		
		reg_file_wren : in std_logic;		-- Read and Write enable for the register file.
		
		alu_op        : in std_logic_vector(7 downto 0);		-- Op Codes coming from CONTROLLER.
		pc_write_cond : in std_logic; 		-- Comes from controller.
		pc_write      : in std_logic;       -- Comes from controller.
		
		
		lo_reg_en     : in std_logic;
		hi_reg_en     : in std_logic;
		
		op_code       : out std_logic_vector(5 downto 0)
		
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
	signal sl_jump_out    : std_logic_vector(WIDTH-1 downto 0);
	signal alu_b_mux_out  : std_logic_vector(WIDTH-1 downto 0);
	signal alu_a_mux_out  : std_logic_vector(WIDTH-1 downto 0);
	signal pc_mux_out     : std_logic_vector(WIDTH-1 downto 0);
	signal mem_mux_out    : std_logic_vector(WIDTH-1 downto 0);
	signal data_mux_out   : std_logic_vector(WIDTH-1 downto 0);
	signal dest_mux_out   : std_logic_vector(4 downto 0);
	signal reg_a_file_out : std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_file_out : std_logic_vector(WIDTH-1 downto 0);
	signal ram_out        : std_logic_vector(WIDTH-1 downto 0);
	signal alu_sel        : std_logic_vector(7 downto 0);
	signal z_flag         : std_logic;
	signal pc_reg_en      : std_logic;
	signal lo_reg_in      : std_logic_vector(WIDTH-1 downto 0);
	signal lo_reg_out     : std_logic_vector(WIDTH-1 downto 0);
	signal hi_reg_in      : std_logic_vector(WIDTH-1 downto 0);
	signal hi_reg_out     : std_logic_vector(WIDTH-1 downto 0);
	signal alu_branch_out : std_logic_vector(WIDTH-1 downto 0);
	signal inc_number	  : std_logic_vector(WIDTH-1 downto 0);
	signal arb_number     : std_logic_vector(WIDTH-1 downto 0);
	signal pc_mux_in3     : signed(WIDTH-1 downto 0);
	signal sl_in		  : unsigned(WIDTH-1 downto 0);
	

begin

	ALU	: entity work.alu -- The ALU entity.
		port map(
		
			input1    => unsigned(alu_a_mux_out),
			input2	  => unsigned(alu_b_mux_out),
			sel	   	  => alu_sel,
			output	  => alu_out,
			output_lo => lo_reg_in,
			output_hi => hi_reg_in,
			branch_out=> alu_branch_out,
			zout      => z_flag
		);
		
	ALU_REG : entity work.reg -- The ALU output register.
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> alu_out,
			output	=> alu_reg_out,
			en		=> alu_reg_en
		);
		 
	ALU_DEC : entity work.alu_decoder -- The ALU Decoder.
		port map(
			inst_reg_out => inst_reg_out(5 downto 0),
			alu_op       => alu_op(7 downto 0),
			alu_sel      => alu_sel
		
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
			input  => sl_in,
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
		generic map (width => 5)
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
		
	ALU_A_MUX : entity work.mux_4x1 -- The mux that feeds the A input to the ALU.
		port map(
			in1	   => pc_reg_out,
			in2	   => a_reg_out,
			in3    => hi_reg_out,
			in4    => lo_reg_out,
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
			in1	   => alu_branch_out,
			in2	   => alu_reg_out,
			in3    => std_logic_vector(pc_mux_in3),
			in4	   => arb_number,
			sel	   => pc_mux_sel,
			output => pc_mux_out
		);
		
	PC_EN : entity work.pc_write -- Logic that enables the PC register.
		port map(
			z_flag		  => z_flag,
			pc_write_cond => pc_write_cond,
			pc_write	  => pc_write,
			output 		  => pc_reg_en
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
			clk           => clk,
			rst           => rst
		
		);
		
	HI_REG : entity work.reg
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> hi_reg_in,
			output	=> hi_reg_out,
			en		=> hi_reg_en	
		);
		
	LO_REG : entity work.reg
		port map(
			clk 	=> clk,
			rst	    => rst,
			input	=> lo_reg_in,
			output	=> lo_reg_out,
			en		=> lo_reg_en
		);
		
	RAM : entity work.ram_1 -- Not sure if the RAM implementation is the correct one but needed to compile datapath.
		port map(
			address	=>  mem_mux_out(13 downto 0),
			clock	=>	clk,
			data	=>  b_reg_out,
			wren	=>	ram_wren,
			q		=>  ram_out
		
		);
		
	op_code <= inst_reg_out(31 downto 26);
	inc_number <= x"0000000" & "0100";
	arb_number <= x"00000000";
	pc_mux_in3 <= signed(sl_jump_out) + signed(pc_reg_out);
	sl_in <=  "000000" & unsigned(inst_reg_out(25 downto 0));
	

end str;