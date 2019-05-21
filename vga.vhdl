library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity vga is 
  port (
    clk : in std_logic;
	hsync, vsync : out std_logic;
	row, col : out unsigned(9 downto 0);
	is_valid : out std_logic
  );
end vga;

architecture synth of vga is 
signal hcount : unsigned(9 downto 0) := 10x"0";
signal vcount : unsigned(9 downto 0) := 10x"0";

begin 
  process (clk) begin
    if rising_edge(clk) then 
	  if hcount = 10d"799" then
         hcount <= 10x"0";
         vcount <= 10x"0" when vcount = 10d"524" else vcount+1;
      else
	    hcount <= hcount+1;
		
	  end if;
	end if;
  end process;
      hsync <= '0' when hcount < 96 else '1';
      vsync <= '0' when vcount < 2 else '1';
	  col <= hcount - 144;
	  row <= vcount - 35;
	  is_valid <= '1' when (col < 640) and (row < 480) else '0';

end synth;