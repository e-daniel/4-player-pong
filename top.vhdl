--top.vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is 
  port(
   --sel : in std_logic_vector(1 downto 0) := "01";
	rot_1a, rot_1b : in std_logic; 
	rot_2a, rot_2b : in std_logic;
	rot_3a, rot_3b : in std_logic;
	rot_4a, rot_4b : in std_logic;
	reset          : in std_logic := '1';
    hsync, vsync : out std_logic;
	hit, hit_p    : out std_logic;
    rgb : out std_logic_vector(5 downto 0)
  );
end top;

architecture synth of top is

component HSOSC is
  generic (
    CLKHF_DIV : String := "0b00"); -- Divide 48MHz clock by 2^N (0-3)
  port(
    CLKHFPU : in std_logic := '1'; -- Set to 1 to power up
    CLKHFEN : in std_logic := '1'; -- Set to 1 to enable output
    CLKHF : out std_logic := '0'   -- Clock output
  ); 
end component;

component pll is -- from Lattice Radiant ICEUP5K-SG48I IP
    port(outglobal_o: out std_logic;
         outcore_o: out std_logic;
         ref_clk_i: in std_logic;
         rst_n_i: in std_logic := '1'
		 );
end component;

component clkdivider is
  generic (div_exp2 : integer := 1); -- divided clock by (div_exp2)^2
  port (
  clkhf : in std_logic;
  clklf : out std_logic
  );
end component;

component velocityclk is 
  generic (
    div_max   : integer := 20;
	delta_init: integer := 50;
	decay     : integer := 5
  );
  port (
    clk_hf : in std_logic;
	hit    : in std_logic;
	reset  : in std_logic;
	enable : in std_logic;
	clk_vel: out std_logic := '0'
  );
  
end component;



component vga is 
  port (
    clk : in std_logic;
	hsync, vsync : out std_logic;
	row, col : out unsigned(9 downto 0);
	is_valid : out std_logic
  );
end component;

component REncoder is
	port(
		clk_in : in std_logic;
		rot1 : in std_logic;
		rot2 : in std_logic;
		Rvalue : out unsigned(6 downto 0) := 7d"64"
		);
end component;

component ball is
  port (
  clk : in std_logic;
  reset : in std_logic;
  vel_x : in signed(2 downto 0); 
  vel_y : in signed(2 downto 0);  
  b_x: out unsigned(6 downto 0) := "0100000"; -- initial pos of ball
  b_y: out unsigned(6 downto 0) := "0100000"-- initial pos of ball
  -- col = x
  -- row = y
  );
end component;

component renderer is
  port (
    players : in std_logic_vector(3 downto 0) := "1111";
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
end component;

  
component collision is
  generic(
  p_len : integer := 24; -- paddle length
  b_size: integer := 3;
  front : integer := 0;  -- where the left paddle is
  back  : integer := 127; -- where the right paddle is
  vx_init : integer := 3;
  vy_init : integer := -1
  );
  port(
	clk       : in std_logic;
	reset     : in std_logic;
    b_pos_x    : in unsigned(6 downto 0) := "1000000";
	b_pos_y    : in unsigned(6 downto 0) := "1000000";
	p1_pos   : in unsigned(6 downto 0);
	p2_pos   : in unsigned(6 downto 0);
	p3_pos   : in unsigned(6 downto 0);
	p4_pos   : in unsigned(6 downto 0);
	players  : out std_logic_vector(3 downto 0);
	x_vel      : out signed(2 downto 0) := to_signed(vx_init,3);
	y_vel      : out signed(2 downto 0) := to_signed(vy_init,3);
	hit, hit_p      : out std_logic
	);
end component;

signal clkosc , pixclk,  clkcount: std_logic;
signal pixrow, pixcol : unsigned(9 downto 0);
signal pix_is_valid : std_logic;
signal ball_pos_x, ball_pos_y : unsigned (6 downto 0);
signal p1_pos, p2_pos, p3_pos, p4_pos : unsigned(6 downto 0);
signal b_p_x, b_p_y : unsigned(6 downto 0);
signal collision_l, collision_r : std_logic := '0';
signal rotation_1_s, rotation_2_s : unsigned(6 downto 0);
signal game_over, game_over_2 : std_logic;
signal b_v_x, b_v_y : signed(2 downto 0);
signal rot_s_1, rot_s_2: std_logic;
signal players : std_logic_vector(3 downto 0);

begin
  
  osc : HSOSC port map (clkhf => clkosc);
  pllpix : pll port map (ref_clk_i => clkosc, outglobal_o => pixclk);
  vgadisp : vga port map (clk => pixclk, hsync => hsync, vsync => vsync, row => pixrow, col => pixcol, is_valid => pix_is_valid);
  ball_1 : ball port map (clk => clkcount, reset => not reset, vel_x => b_v_x, vel_y => b_v_y, b_x => b_p_x, b_y => b_p_y);
  paddle  : REncoder port map (rot1 => rot_1a, rot2 => rot_1b, clk_in => vsync, Rvalue => p1_pos);
  paddle2 : REncoder port map (rot1 => rot_2a, rot2 => rot_2b, clk_in => vsync, Rvalue => p2_pos);
  paddle3 : REncoder port map (rot1 => rot_3a, rot2 => rot_3b, clk_in => vsync, Rvalue => p3_pos);
  paddle4 : REncoder port map (rot1 => rot_4a, rot2 => rot_4b, clk_in => vsync, Rvalue => p4_pos);
 --icounter : interactcounter port map (clklf => clkcount, sel => sel, unum => ball_pos);
  
 
colli : collision
	port map(
	clk => hsync,
	reset => not reset,
    b_pos_x => b_p_x,
	b_pos_y => b_p_y,
	p1_pos  => p1_pos,
	p2_pos  => p2_pos,
	p3_pos  => p3_pos,
	p4_pos  => p4_pos,
	players => players,
	x_vel   => b_v_x,
	y_vel   => b_v_y,
	hit     => hit,
	hit_p   => hit_p
	);
	
 rndr : renderer 
  port map (
	players  => players,
    p1_pos   => p1_pos,
    p2_pos   => p2_pos,
	p3_pos   => p3_pos,
	p4_pos   => p4_pos,
    b_xcoord => b_p_x,
    b_ycoord => b_p_y,
    row      => pixrow,
	col      => pixcol,
	is_valid => pix_is_valid,
    rgb_o    => rgb
  );
  clkdiv: clkdivider generic map (div_exp2 => 8)
                     port map (clkhf => hsync, clklf => clkcount);
  --velclkgen : velocityclk port map (clk_hf => clkosc, hit => hit, reset => reset, enable => '1', clk_vel => clkcount);
	
end synth;
