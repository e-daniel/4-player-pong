
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity collision is
  generic(
  p_len : integer := 24; -- paddle length
  b_size: integer := 3;
  front : integer := 0;  -- where the left paddle is
  back  : integer := 127; -- where the right paddle is
  vx_init : integer := 3;
  vy_init : integer := 0
  );
  port(
	clk       : in std_logic;
	reset     : in std_logic;
    b_pos_x    : in unsigned(6 downto 0);
	b_pos_y    : in unsigned(6 downto 0);
	p1_pos   : in unsigned(6 downto 0);
	p2_pos   : in unsigned(6 downto 0);
	p3_pos   : in unsigned(6 downto 0);
	p4_pos   : in unsigned(6 downto 0);
	players  : out std_logic_vector(3 downto 0);
	x_vel      : out signed(2 downto 0) := to_signed(vx_init,3);
	y_vel      : out signed(2 downto 0) := to_signed(vy_init,3);
	hit, hit_p      : out std_logic
	);
end collision;

architecture synth of collision is

  signal offset: unsigned(2 downto 0);
  signal side_hit : unsigned(1 downto 0);

begin
  process(clk) begin
    if rising_edge(clk) then
	  if (reset = '1') then
	    x_vel <= to_signed(vx_init,3);
		y_vel <= to_signed(vy_init,3);
		hit <= '0';
		players <= "1111";
		side_hit <= "00";
	  --end if;
	  
	  elsif (b_pos_x < 7d"1" and x_vel(2) = '1') then
	    hit <= '1';
		side_hit <= "00";
	    if ( (p1_pos < b_pos_y) and (b_pos_y < (p1_pos + p_len) ) and (players(0) = '1') ) then
		  offset <= resize( shift_right( resize(b_pos_y - p1_pos, 5), 2), 3) +1;
		else
		  offset <= 3d"0";
		  players(0) <= '0';
		end if;
	  --end if;
	  
	  elsif (b_pos_x > 7d"124" and x_vel(2) = '0') then
	    hit <= '1';
		side_hit <= "01";
	    if ( (p2_pos < b_pos_y) and (b_pos_y < (p2_pos + p_len) ) and (players(1) = '1') ) then
		  hit_p <= '1';
		  offset <= resize( shift_right( resize(b_pos_y - p2_pos, 5), 2), 3) +1;
	    else
		  hit_p <= '0';
		  offset <= 3d"0";
		  players(1) <= '0';
	    end if;
      --end if;		
	  
	  elsif (b_pos_y < 7d"1" and y_vel(2) = '1') then
	    hit <= '1';
		side_hit <= "10";
	    if ( (p3_pos < b_pos_x) and (b_pos_x < (p3_pos + p_len) ) and (players(2) = '1') ) then
		  hit_p <= '1';
		  offset <= resize( shift_right( resize(b_pos_x - p3_pos, 5), 2), 3) +1;
	    else
		  hit_p <= '0';
		  offset <= 3d"0";
		  players(2) <= '0';
	    end if;
	  --end if;
	  
	  elsif (b_pos_y > 7d"124" and y_vel(2) = '0') then
	    hit <= '1';
		side_hit <= "11";
	    if ( (p4_pos < b_pos_x) and (b_pos_x < (p4_pos + p_len) ) and (players(3) = '1') ) then
		  hit_p <= '1';
		  offset <= resize( shift_right( resize(b_pos_x - p4_pos, 5), 2), 3) +1;
	    else
		  hit_p <= '0';
		  offset <= 3d"0";
		  players(3) <= '0';
	    end if;
	  else
	    x_vel <= x_vel;
		y_vel <= y_vel;
		--hit <= '0'; -- driven multiple times?
		hit_p <= '0';
	  end if;
      
	  if (hit = '1') then
	    hit <= '0';
	    case (side_hit) is
		  when "00" =>
			case (offset) is
			  when "001" => 
				hit_p <= '1';
				x_vel <= "001"; -- 1
				y_vel <= "101"; -- -3
			  when "010" =>
				hit_p <= '1';
				x_vel <= "010"; -- 2
				y_vel <= "110"; -- -2
			  when "011" =>
				hit_p <= '1';
				x_vel <= "011"; -- 3
				y_vel <= "111"; -- -1
			  when "100" =>
				hit_p <= '1';
				x_vel <= "011"; -- 3
				y_vel <= "001"; -- 1
			  when "101" =>
				hit_p <= '1';
				x_vel <= "010"; -- 2
				y_vel <= "010"; -- 2
			  when "110" =>
				hit_p <= '1';
				x_vel <= "001"; -- 1
				y_vel <= "011"; -- 3
			  when others =>
				hit_p <= '0';
				x_vel <= not x_vel +1;
				y_vel <= y_vel;
			end case;
			
		  when "01" => 
			case (offset) is
			  when "001" => 
				x_vel <= "111"; -- -1
				y_vel <= "101"; -- -3
			  when "010" =>
				x_vel <= "110"; -- -2
				y_vel <= "110"; -- -2
			  when "011" =>
				x_vel <= "101"; -- -3
				y_vel <= "111"; -- -1
			  when "100" =>
				x_vel <= "101"; -- -3
				y_vel <= "001"; -- 1
			  when "101" =>
				x_vel <= "110"; -- -2
				y_vel <= "010"; -- 2
			  when "110" =>
				x_vel <= "111"; -- -1
				y_vel <= "011"; -- 3
			  when others =>
				x_vel <= not x_vel +1;
				y_vel <= y_vel;
			end case;
			
		  when "10" =>
			case (offset) is
			  when "001" => 
				x_vel <= "101";
				y_vel <= "001";
			  when "010" =>
				x_vel <= "110";
				y_vel <= "010";
			  when "011" =>
				x_vel <= "111";
				y_vel <= "011";
			  when "100" =>
				x_vel <= "001";
				y_vel <= "011";
			  when "101" =>
				x_vel <= "010";
				y_vel <= "010";
			  when "110" =>
				x_vel <= "011";
				y_vel <= "001";
			  when others =>
				x_vel <= x_vel;
				y_vel <= not y_vel +1;
			end case;
			
		  when "11" =>	
			case (offset) is
			  when "001" => 
				x_vel <= "101";
				y_vel <= "111";
			  when "010" =>
				x_vel <= "110";
				y_vel <= "110";
			  when "011" =>
				x_vel <= "111";
				y_vel <= "101";
			  when "100" =>
				x_vel <= "001";
				y_vel <= "101";
			  when "101" =>
				x_vel <= "010";
				y_vel <= "110";
			  when "110" =>
				x_vel <= "011";
				y_vel <= "111";
			  when others =>
				x_vel <= x_vel;
				y_vel <= not y_vel +1;
			end case;
		  when others => -- do nothing
        end case;
	  end if;
	end if;
  end process;
end;

