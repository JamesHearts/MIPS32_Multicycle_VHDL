library ieee;
use ieee.std_logic_1164.all;

entity mux_2x1 is

generic (
    WIDTH  :     positive := 32);
	
  port(
    in1    : in  std_logic_vector(WIDTH-1 downto 0);
    in2    : in  std_logic_vector(WIDTH-1 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(WIDTH-1 downto 0)
	);
end mux_2x1;


architecture MUX_2x1 of mux_2x1 is

begin

  process(in1, in2, sel)
  begin
  
    case sel is
      when '0'    => --when select is 0 we take in1. in1 in the datapath is the main input.
        output <= in1;
      when others =>
        output <= in2;
    end case;
	
  end process;
end MUX_2x1;