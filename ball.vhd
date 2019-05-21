--ball.vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ball is
  port (
  clk : in std_logic;
  reset : in std_logic;
  vel_x : in signed(2 downto 0); 
  vel_y : in signed(2 downto 0); 
  b_x: out unsigned(6 downto 0)  := 7d"64"; -- initial pos of ball
  b_y: out unsigned(6 downto 0)  := 7d"64"-- initial pos of ball
  -- col = x
  -- row = y
  );
end ball;

architecture synth of ball is

  signal count : unsigned(2 downto 0) := 3d"4";
  signal currvx, currvy : signed(2 downto 0) := "000"; 
  
begin
  process(clk) is begin
    
    if rising_edge(clk) then
      if reset = '1' then
	    b_x <= 7d"20";
	    b_y <= 7d"64";
		currvx <= "000";
		currvy <= "000";
	  else
  	    if (currvx = currvy and currvy = "000") then
		  currvx <= vel_x when 0 < vel_x else not vel_x +1;
		  currvy <= vel_y when 0 < vel_y else not vel_y +1;
	    else
		  if (not (currvx = "000")) then
		    b_x <= (b_x + 1) when (vel_x(2) = '0') else (b_x - 1);
		    currvx <= currvx-1;
		  end if;
		  if (not (currvy = "000")) then
		    b_y <= (b_y + 1) when (vel_y(2) = '0') else (b_y - 1);
		    currvy <= (currvy - 1);
		  end if;
	    end if;
	  end if;
	end if;
  end process;
end;
