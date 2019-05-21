library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkdivider is
  generic (div_exp2 : integer := 1); -- divided clock by (div_exp2)^2
  port (
  clkhf : in std_logic;
  clklf : out std_logic
  );
end clkdivider;

architecture synth of clkdivider is

signal counter : unsigned (div_exp2-1 downto 0) := (others => '0');
begin
  process (clkhf) begin
    if (rising_edge(clkhf)) then
	  counter <= counter+1;
      clklf <= counter(div_exp2-1); 
	end if;
  end process;
end synth;





