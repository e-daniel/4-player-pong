--interactiveCounter.vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interactcounter is
  port (
  clklf : in std_logic;
  sel : in std_logic_vector(1 downto 0);
  unum: out unsigned(6 downto 0) := 7x"1"
  );
end interactcounter;

architecture synth of interactcounter is


begin
  process(clklf) is begin
    if (rising_edge(clklf)) then
	  unum <= unum - 1 when sel = "01" else
		      unum + 1 when sel = "10";
    end if;
  end process;
end synth;
