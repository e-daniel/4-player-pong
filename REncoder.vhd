library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.numeric_std.all;

entity REncoder is 
	port(
		clk_in : in std_logic;
		rot1 : in std_logic;
		rot2 : in std_logic;
		Rvalue : out unsigned(6 downto 0) := 7d"64"
		);
end REncoder;

architecture synth of REncoder is
--component HSOSC is
	--generic (
		--CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2ˆN (0-3)
	--port(
		--CLKHFPU : in std_logic := 'X'; -- Set to 1 to power up
		--CLKHFEN : in std_logic := 'X'; -- Set to 1 to enable output
		--CLKHF : out std_logic := 'X'); -- Clock output
--end component;

signal rotary_a_prev : std_logic := '0';
signal rotary_b_prev : std_logic := '0';
signal synca, syncb : std_logic := '0';

begin

--clock : hsosc
	--port map(
		--clkhfpu => '1',
		--clkhfen => '1',
		--clkhf => clk
		--);
		

process (clk_in) is
begin
	if rising_edge(clk_in) then
		rotary_a_prev <= synca;
		rotary_b_prev <= syncb;
		synca <= rot1;
		syncb <= rot2;
		if rotary_a_prev = '0' and synca = '1' and rotary_b_prev = '0' and syncb = '0' and RValue < 100 then
			RValue <= RValue + 3;
		elsif rotary_a_prev = '1' and synca = '0' and rotary_b_prev = '0' and syncb = '0' and RValue > 1 then
			Rvalue <= Rvalue - 3;
		else
			Rvalue <= Rvalue;
		end if;

	end if;
end process;
end;