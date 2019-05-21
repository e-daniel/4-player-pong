-- velocityclk
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity velocityclk is 
  generic (
    div_max        : integer := 10;
	delta_init     : integer := 50;
	decay          : integer := 1
  );
  port (
    clk_hf : in std_logic;
	hit    : in std_logic;
	reset  : in std_logic;
	enable : in std_logic;
	clk_vel: out std_logic := '0'
  );
end velocityclk;

architecture synth of velocityclk is
signal counter     : unsigned(div_max-1 downto 0) := (others => '0');
signal counter_lim : unsigned(div_max-1 downto 0) := (others => '1');
signal delta       : unsigned(7 downto 0);
signal hit_last    : std_logic := '0';

begin
  process(clk_hf) is begin
	if (reset = '1') then
	  counter <= (others => '0');
	  counter_lim <= (others => '1');
	  delta <= to_unsigned(delta_init, 8);
	  hit_last <= '0';
		
    elsif (rising_edge(clk_hf)) then
	  hit_last <= hit;
	  --if ((hit_last = '0') and (hit = '1')) then
	    --counter_lim <= counter_lim - delta;
		--delta <= (delta - decay) when ((delta - decay) < delta) else (others => '0');
	  --end if;
	  if (counter = counter_lim) then
		clk_vel <= not clk_vel;
		counter <= (others => '0');
	  else
		counter <= counter + 1;
	  end if;
	end if;
  end process;
end synth;
