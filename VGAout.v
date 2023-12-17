module VGAout
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		playerx,
		playery,
		turretaddress,
		turretdatain,
		bulletaddress,
		bulletdatain,
		buttonaddress,
		buttondatain,
		gamestate
	);
	
	//+----------------+//
	//| 3rd party code |//
	//+----------------+//

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	// Declare your inputs and outputs here
	input [9:0] SW;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	reg [5:0] colour;
	reg [7:0] x;
	reg [6:0] y;
	
	reg writeEn;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2; //must be set to 2 on the DE1-SoC, but double buffer doesnt fit on the DE1, so set to 1 in that case.
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn ***END OF 3RD PARTY CODE***
	
	//+--------------------+//
	//| Inputs and Outputs |//
	//+--------------------+//	
	
	input wire [7:0] playerx;
	input wire [6:0] playery;
	
	input wire [1:0] gamestate;
	
	output reg [2:0] turretaddress;
	input wire [11:0] turretdatain;
	
	//massaged turret data input
	wire [7:0] turretx;
	assign turretx = (turretdatain[6:2]*8) + 8;
	wire [6:0] turrety;
	assign turrety = (turretdatain [10:7] * 8) + 8;
	wire [1:0] turretdirection;
	assign turretdirection = turretdatain[1:0];
	wire turretactive;
	assign turretactive = turretdatain [11:11];
	
	output reg [2:0] buttonaddress;
	input wire [9:0] buttondatain;
	
	//massaged button data input
	wire [7:0] buttonx;
	assign buttonx = (buttondatain[4:0]*8) + 8;
	wire [6:0] buttony;
	assign buttony = (buttondatain[8:5]*8) + 8;
	wire buttonactive;
	assign buttonactive = buttondatain[9:9];
	
	output reg [7:0] bulletaddress;
	input wire [15:0] bulletdatain;
	
	//massaged button data input
	wire [7:0] bulletx;
	assign bulletx = bulletdatain[7:0];
	wire [6:0] bullety;
	assign bullety = bulletdatain[14:8];
	wire bulletactive = bulletdatain[15:15];
	
	
	
	
	
	//+-------------+//
	//| ROM-Sprites |//
	//+-------------+//
	
	//player
	player player1(playercounter + 2, CLOCK_50, playervisdata);
	reg [5:0] playercounter;
	wire [5:0] playervisdata;
	
	//turrets
	turret turret1(turretcounter + 2, CLOCK_50, turretvisdata);
	reg [5:0] turretcounter;
	wire [5:0] turretvisdata;
	
	//buttons
	button button1(buttoncounter + 2, CLOCK_50, buttonvisdata);
	reg [5:0] buttoncounter;
	wire [5:0] buttonvisdata;
	
	//bullets (not rom)
	reg [2:0] bulletcounter;
	
	//background
	
	background background1(backgroundcounter + 2, CLOCK_50, backgroundvisdata);
	reg[14:0] backgroundcounter;
	wire [5:0] backgroundvisdata;
	
	//lostscreen
	
	lostscreen lostscreen1(lostscreencounter +2, CLOCK_50, lostscreenvisdata);
	reg[14:0] lostscreencounter;
	wire [5:0] lostscreenvisdata;
	
	//wonscreen
	wonscreen wonscreen1(wonscreencounter +2, CLOCK_50, wonscreenvisdata);
	reg[14:0] wonscreencounter;
	wire [5:0] wonscreenvisdata;
	
	
	
	//blanking (only if no background), not technically rom here
	reg [7:0] blankx;
	reg [6:0] blanky;
	
	
	//+---------------------+//
	//| Scene drawing logic |//
	//+---------------------+//
	
	//graphical state FSM (this employs direct
	//next state logic, rather than having it
	//wait until the next clock cycle).
	reg [3:0] graphicstate;
	localparam
		drawBACKGROUND = 0,
		drawPLAYER = 1,
		drawBULLETS = 2,
		drawBUTTONS = 3,
		drawTURRETS = 4,
		drawWIN = 5,
		drawLOSS = 6;
	
	//this is used to detect if Vsync was pulsed.
	reg VGAVSprev;
	
	always @ (posedge CLOCK_50)begin
		
		//this will allow the scene to be drawn to memory
		//upon seeing a negedge of vertical sync. it is
		//important to do it this way because of multiple
		//driver errors.
		if(VGAVSprev == 1 && VGA_VS == 0)begin
			writeEn = 1;
			graphicstate = drawBACKGROUND;
		end
		else
			VGAVSprev = VGA_VS;
			
		
		//draw the scene to memory when writeEn is high.
		//no point in having writeEn high when we arent
		//writing en-ything (hahahahha).
		if(writeEn) begin
		
			if(gamestate == 2'b10)begin
				graphicstate = drawLOSS;
			end
			if(gamestate == 2'b01)begin
				graphicstate = drawWIN;
			end
			
			if(graphicstate == drawLOSS)begin
				if(blanky < 120) begin
					colour = lostscreenvisdata;
					x = blankx;
					y = blanky;
					if(blankx < 160)begin
						blankx = blankx + 1;
						lostscreencounter = lostscreencounter + 1;
					end
					if(blankx == 160)begin
						blankx = 0;
						blanky = blanky + 1;
					end
				end
				if(blanky == 120)begin
					blanky = 0;
					lostscreencounter = 0;
					graphicstate = drawLOSS;
				end
			end
			
			if(graphicstate == drawWIN)begin
				if(blanky < 120) begin
					colour = wonscreenvisdata;
					x = blankx;
					y = blanky;
					if(blankx < 160)begin
						blankx = blankx + 1;
						wonscreencounter = wonscreencounter + 1;
					end
					if(blankx == 160)begin
						blankx = 0;
						blanky = blanky + 1;
					end
				end
				if(blanky == 120)begin
					blanky = 0;
					wonscreencounter = 0;
					graphicstate = drawWIN;
				end
			end
			
			//draw background
			if(graphicstate == drawBACKGROUND)begin
				if(blanky < 120) begin
					colour = backgroundvisdata;
					x = blankx;
					y = blanky;
					if(blankx < 160)begin
						blankx = blankx + 1;
						backgroundcounter = backgroundcounter + 1;
					end
					if(blankx == 160)begin
						blankx = 0;
						blanky = blanky + 1;
					end
				end
				if(blanky == 120)begin
					blanky = 0;
					backgroundcounter = 0;
					graphicstate = drawTURRETS;
				end
			end
			
			//draw turrets
			if(graphicstate == drawTURRETS)begin
				//loop through the memory of turrets, this interacts with top level ram
				if(turretaddress < 7) begin
					//draw the current turret as long as the active bit is high
						  if(turretactive == 1)begin
                        if(turretcounter < 63)begin
									if(turretvisdata != 0) begin
										 x = turretx + turretcounter[2:0];
										 y = turrety + turretcounter[5:3];
										 colour = turretvisdata;
									 end
									 
									 turretcounter = turretcounter + 1;
                        end

                        if(turretcounter == 63)begin
                            turretcounter = 0;
									 turretaddress = turretaddress + 1;
                        end
                    end else turretaddress = turretaddress + 1;

                    //go to next turret after drawing or skipping current turret
				end
				if(turretaddress == 7) begin
					turretaddress = 0;
					graphicstate = drawBUTTONS;
				end
			end
			
			//draw buttons
			if(graphicstate == drawBUTTONS)begin
				//loop through the memory of turrets, this interacts with top level ram
				if(buttonaddress < 7) begin
					//draw the current turret as long as the active bit is high
						  if(buttonactive == 1)begin
                        if(buttoncounter < 63)begin
									if(buttonvisdata != 0) begin
										 x = buttonx + buttoncounter[2:0];
										 y = buttony + buttoncounter[5:3];
										 colour = buttonvisdata;
									 end
									 
									 buttoncounter = buttoncounter + 1;
                        end

                        if(buttoncounter == 63)begin
                            buttoncounter = 0;
									 buttonaddress = buttonaddress + 1;
                        end
                    end else buttonaddress = buttonaddress + 1;

                    //go to next turret after drawing or skipping current turret
				end
				if(buttonaddress == 7) begin
					buttonaddress = 0;
					graphicstate = drawBULLETS;
				end
			end
			
			//draw bullets
			if(graphicstate == drawBULLETS)begin
				if(bulletaddress < 128)begin
					if(bulletactive == 1)begin
						if(bulletcounter < 4)begin
							x = bulletx + bulletcounter [0:0];
							y = bullety + bulletcounter [1:1];
							colour = 48;
							bulletcounter = bulletcounter + 1;
						end
						if(bulletcounter == 4)begin
							bulletcounter = 0;
							bulletaddress = bulletaddress + 1;
						end
					end else bulletaddress = bulletaddress + 1;
				end
				if(bulletaddress == 128) begin
					bulletaddress = 0;
					graphicstate = drawPLAYER;
				end
			end
			
			//draw player
			if(graphicstate == drawPLAYER)begin
				if(playercounter < 63)begin
					if(playervisdata != 0)begin
						x = playerx + playercounter[2:0];
						y = playery + playercounter[5:3];
						colour = playervisdata;
					end
					playercounter = playercounter + 1;
				end
				if(playercounter == 63)begin
					playercounter = 0;
					writeEn = 0;
				end
			end
			
		end
	end
	
	
endmodule
