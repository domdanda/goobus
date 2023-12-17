module VGAtest(
	CLOCK_50,
	SW,
	playerx,
	playery
);

input CLOCK_50;
input [9:0] SW;
output reg [7:0] playerx;
output reg [6:0] playery;

	//this is a simple test for the VGA,
	//it employs a simple movement scheme
	//using the switches.
	reg movementclock;
	reg [24:0] movementclockcounter;
	
	always @ (posedge movementclock)begin
		playerx = playerx + SW[9:9] - SW[8:8];
		playery = playery + SW[7:7] - SW[6:6];
	end
	
	always @ (posedge CLOCK_50)begin
		if(movementclockcounter < 1000000)begin
			movementclockcounter = movementclockcounter + 1;
		end
		if(movementclockcounter == 1000000)begin
			movementclock = !movementclock;
			movementclockcounter = 0;
		end
	end
	
endmodule