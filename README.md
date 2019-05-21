# 4-player-pong
Version of the arcade classic pong, but with 4 simultaneous players. Implemented on an UPDuino

## Project information
This project was part of a group project for Intro to Digital Logic Circuits (ES4). This project was implemented on the UPDuino V2.0, part name iCE40UP5K-SG48I. Other group members are Olive Garst, Tiamike Dudley, and Daisy Sanchez

## Game concept
- Like the classic version of pong, each player controls a "paddle" which they move along the edge of the play area. There are 4 players, each belonging to one of the 4 sides of the play area. 
- There is also a ball which bounces around.
The objective of the game is to keep the ball from going out on your side. If the ball *does* go out on your side, your paddle will be replaced with a wall, and you will no longer be in the game. The last person still in the game is the winner.
### details
- Paddles are controlled via rotary encoders.
- The ball bounces off paddles at different angles depending on what part of the paddle it hits. Walls will just reflect the ball.
- This game can be played with a max of 4 players, if you wish to play with less let the ball hit the unoccupied sides.
- There is no win screen or score count, to start/restart the game press the reset button.
- Displays via VGA, using a simple 6-bit breakout board.

This project uses the Lattice iCE40 UltraPlus PLL IP (not included).
