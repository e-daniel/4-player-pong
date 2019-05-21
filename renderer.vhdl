library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity renderer is
  generic (
    bd_size  : integer := 128;
	scal     : integer := 3;
    l_buff_e : integer := (640 - (bd_size * scal))/2;
	r_buff_s : integer := 640 - l_buff_e;
	t_buff_e : integer := (480 - (bd_size * scal))/2;
	b_buff_s : integer := 480 - t_buff_e;
    p_len    : integer := 24 * scal;
	p_width  : integer := 3 * scal;
	b_width  : integer := 3 * scal
  );
  port (
    players: in std_logic_vector(3 downto 0);
    p1_pos  : in unsigned(6 downto 0);
    p2_pos  : in unsigned(6 downto 0);
	p3_pos  : in unsigned(6 downto 0);
	p4_pos  : in unsigned(6 downto 0);
    b_xcoord: in unsigned(6 downto 0);
    b_ycoord: in unsigned(6 downto 0);
    row, col : in unsigned(9 downto 0);
	is_valid : in std_logic;
    rgb_o : out std_logic_vector(5 downto 0)
  );
end renderer;

architecture synth of renderer is

signal p1_logic, p2_logic, p3_logic, p4_logic, b_logic, inbnd_logic : std_logic;
signal p1_row, p2_row, p3_col, p4_col, b_row, b_col : unsigned(9 downto 0);
signal p1_out, p2_out, p3_out, p4_out : std_logic;
signal p1_out_p, p2_out_p, p3_out_p, p4_out_p : unsigned(9 downto 0);

begin
  p1_row <= to_unsigned(t_buff_e, 10) + resize(p1_pos * scal, 10);
  p2_row <= to_unsigned(t_buff_e, 10) + resize(p2_pos * scal, 10);
  p3_col <= to_unsigned(l_buff_e, 10) + resize(p3_pos * scal, 10);
  p4_col <= to_unsigned(l_buff_e, 10) + resize(p4_pos * scal, 10);
  b_col  <= to_unsigned(l_buff_e, 10) + resize(b_xcoord * scal, 10);
  b_row  <= to_unsigned(t_buff_e, 10) + resize(b_ycoord * scal, 10);


  p1_logic <= '1' when 
				  (( ( (l_buff_e - p_width) < col) and (col < l_buff_e) ) and -- hor
			      ((p1_row < row) and (row < (p1_row + to_unsigned(p_len, 10)) )) and (players(0) = '1')) -- vert
				  else '0';
				  				  				  
  p2_logic <= '1' when
				  (( ( (r_buff_s) < col) and (col < (r_buff_s + p_width)) ) and
			      ((p2_row < row) and (row < p2_row + to_unsigned(p_len, 10) )) and (players(1) = '1')) -- vert
				  else '0';
				  
  p3_logic <= '1' when
				  (( (t_buff_e - p_width) < row) and (row < (t_buff_e) ) and
				  ((p3_col < col) and (col < p3_col + to_unsigned(p_len, 10) )) and (players(2) = '1'))
				  else '0';
				  
  p4_logic <= '1' when 
				  (( (b_buff_s) < row) and ( row < (b_buff_s + p_width)) and
				  ((p4_col < col) and (col < p4_col + to_unsigned(p_len, 10) )) and (players(3) = '1'))
				  else '0';  
	-- when a player goes out			  
  p1_out <= '1' when 
					((players(0) = '0') and (( (l_buff_e - (p_width/2)) < col) and (col < l_buff_e)))
					else '0';

  p2_out <= '1' when 
					((players(1) = '0') and (( (r_buff_s - (p_width/2)) < col) and (col < r_buff_s)))
					else '0';

  p3_out <= '1' when 
					((players(2) = '0') and (( (t_buff_e - (p_width/2)) < row) and (row < t_buff_e)))
					else '0';
					
  p4_out <= '1' when 
					((players(3) = '0') and (( (b_buff_s - (p_width/2)) < row) and (row < b_buff_s)))
					else '0';
					
  b_logic <= '1' when
				 ( (b_col < col) and (col < b_col + to_unsigned(b_width, 10) ) and
				 ( (b_row < row) and (row < b_row + to_unsigned(b_width, 10) ) ))
				 else '0';
				 
  inbnd_logic <= '1' when
				 (( (l_buff_e < col) and (col < r_buff_s) ) and
				 ( (t_buff_e < row) and (row < b_buff_s) ))
				 else '0';
				 

  rgb_o <= "000000" when not is_valid else
           "001100" when (p1_logic or p1_out) else
		   "001111" when (p2_logic or p2_out) else
		   "111100" when (p3_logic or p3_out) else
		   "110011" when (p4_logic or p4_out) else
		   "110101" when b_logic else
		   "000001" when inbnd_logic else
		   "000000";
end synth;