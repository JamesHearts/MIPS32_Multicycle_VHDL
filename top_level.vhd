library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is

	generic (
		width  :     positive := 32);
	port(
		signal clk, rst 		: in std_logic
		
	);
end top_level;

architecture STR of top_level is
	     
		signal op_code_n : std_logic_vector(5 downto 0);
		signal alu_op_n : std_logic_vector(7 downto 0);    
		signal alu_sel_n : std_logic_vector(7 downto 0);
		signal alu_reg_en_n : std_logic; 
		signal alu_a_mux_sel_n : std_logic_vector(1 downto 0);
		signal alu_b_mux_sel_n : std_logic_vector(1 downto 0);
		signal inst_reg_en_n : std_logic; 
		signal pc_mux_sel_n : std_logic_vector(1 downto 0);
		signal mem_reg_en_n : std_logic;
		signal mem_mux_sel_n : std_logic;
		signal data_mux_sel_n : std_logic;
		signal dest_mux_sel_n : std_logic;
		signal a_reg_en_n : std_logic;
		signal b_reg_en_n : std_logic;
		signal ram_wren_n : std_logic;
		signal reg_file_wren_n : std_logic;
		signal pc_write_cond_n : std_logic;
		signal pc_write_n : std_logic;
		signal hi_reg_en_n : std_logic;
		signal lo_reg_en_n : std_logic;

begin

	CTRL : entity work.controller
	port map(
	
		clk	=> clk,     
		rst => rst,	     
		op_code	=> op_code_n,
		alu_op => alu_op_n,   
		alu_reg_en => alu_reg_en_n,  
		alu_a_mux_sel => alu_a_mux_sel_n,
		alu_b_mux_sel => alu_b_mux_sel_n,
		inst_reg_en => inst_reg_en_n,  
		pc_mux_sel => pc_mux_sel_n,
		mem_reg_en => mem_reg_en_n,
		mem_mux_sel => mem_mux_sel_n,  
		data_mux_sel => data_mux_sel_n,
		dest_mux_sel => dest_mux_sel_n,
		a_reg_en => a_reg_en_n,
		b_reg_en => b_reg_en_n,
		ram_wren => ram_wren_n,
		reg_file_wren => reg_file_wren_n,
		pc_write_cond => pc_write_cond_n,
		pc_write => pc_write_n,
		hi_reg_en => hi_reg_en_n,
		lo_reg_en => lo_reg_en_n
	);
	
	DPATH : entity work.datapath
	port map(
	
		clk => clk,	    
		rst => rst,	      
		alu_reg_en => alu_reg_en_n,  
		alu_a_mux_sel => alu_a_mux_sel_n, 
		alu_b_mux_sel => alu_b_mux_sel_n,
		inst_reg_en => inst_reg_en_n, 
		pc_mux_sel => pc_mux_sel_n,  
		mem_reg_en => mem_reg_en_n,
		mem_mux_sel => mem_mux_sel_n,
		data_mux_sel => data_mux_sel_n,  
		dest_mux_sel => dest_mux_sel_n, 
		a_reg_en => a_reg_en_n,		
		b_reg_en => b_reg_en_n,     
		ram_wren => ram_wren_n,     
		reg_file_wren => reg_file_wren_n, 
		alu_op => alu_op_n,      
		pc_write_cond => pc_write_cond_n,
		pc_write => pc_write_n,
		lo_reg_en => lo_reg_en_n,     
		hi_reg_en => hi_reg_en_n,   
		op_code => op_code_n     
	
	);

end STR;
