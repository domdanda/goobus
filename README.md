# goobus
This repository is the final (but incomplete) version of "The adventures of Goobus the Brave" in Verilog using the DE1-SoC FPGA.

Included in this repository is a short demo video showing some of the various aspects of the game.
All sprites and audio were created by me, and are not copied from anywhere else.

My responsibility in this project was to interface with the audio and video drivers.
I also managed the on chip memories, including the inter-module interface to connect my modules with those of my partners.  

The (high level verilog) files that were written by me are listed here:
- game.v
- VGAout.v
- VGAtest.v
- AUDIOout.v

The interfaces I used for my part are listed here:
- VGA adapter: https://www.eecg.toronto.edu/~jayar/ece241_08F/vga/
- Audio controller: https://www.eecg.utoronto.ca/~pc/courses/241/DE1_SoC_cores/audio/audio.html
- Built in Altera IP cores for on chip memories

As mentioned previously, the game is not complete, however, all modules that were promised on my end are fully functional.
The premise of this project was to create a "bullet-hell" type game that was loosely based on the popular video game "The Binding of Issac".
In our game, the main character, Goobus, is placed into a room with turrets firing in many directions. The goal is to press all buttons in
a room to clear it, and then move to the next room via doors on every side of the room. To win the game, Goobus would need to find the room
with the goal.

Of course, we unfortunately did not get the game to this state, and a few things to fix/improve on are:

Personal:
- Adding sprites for the winning room
- Proper turret rotation based on fire direction
- Character animation (walking)

General:
- Adding turret fire and logic
- Adding movement in between rooms
- Winning and losing states

Overall, the project is mostly complete, and if we had a week more time, I believe that it could have been finished completely. 

If you would like to play this game: It was created using Quartus 18.0, and is meant to be run on a DE1-SoC board, though a DE2 or other board
may work, as long as there is enough memory to fit the project on the board. The pin assignments are the standard pin assignments that came 
with the board. If there are any issues with running this on your own board, please contact me and I can get them fixed!
