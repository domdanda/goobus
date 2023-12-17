module datapath(
	input [3:0] moveState,
	input [3:0] gameState,
	input clk,
	input [14:0] prevPlayerPos,
	input [1:0] roomType,
	
	input [9:0] buttonreaddata,
	input [11:0] turretreaddata,
	input [17:0] bulletreaddata,
	
	output reg [14:0] curPlayerPos,
	output reg [7:0] playerx,
	output reg [6:0] playery,
	
	output reg buttonwren,
	output reg turretwren,
	output reg bulletwren,
	output reg [2:0] buttonAdr_out,
	output reg [2:0] turretAdr_out,
	output reg [6:0] bulletAdr_out,
	
	output reg [9:0] buttonwritedata,
	output reg [11:0] turretwritedata,
	output reg [17:0] bulletwritedata,
	
	output reg doneInit
);
	
	// movement state parameters
	parameter IDLE = 4'b0000;
	parameter MOVING_NORTH = 4'b0001;
	parameter MOVING_EAST = 4'b0010;
	parameter MOVING_SOUTH = 4'b0011;
	parameter MOVING_WEST = 4'b0100;
	
	// gamestate parameters
	parameter INITIALIZATION = 4'b0000;			// Initialize room data 
	parameter GAME_PROGRESSING = 4'b0010;		// playing game
	parameter GAMEOVER = 4'b0100;				// if hit then game over
	parameter WIN = 4'b0101;
	parameter ENDPROGRAM = 4'b0110;
	parameter CHANGE_ROOM = 4'b0111;
	
	parameter LOAD_BUTTONS = 2'b00;
	parameter LOAD_TURRETS = 2'b01;
	parameter LOAD_BULLETS = 2'b10;
	
	parameter READ_BUTTONS = 3'b000;
	parameter READ_BULLETS = 3'b001;
	parameter CHECK_BUTTONS = 3'b010;
	parameter CHECK_BULLETS = 3'b011;
	parameter WAIT = 3'b100;
	parameter UPDATE = 3'b101;
	
	reg [6:0] moveCounter = 0;
	
	reg [19:0] rdCounter = 0;

	reg [3:0] buttonAdr = 0;
	reg [3:0] turretAdr = 0;
	reg [8:0] bulletAdr = 0;

	reg [1:0] loadState = LOAD_BUTTONS;
	reg [1:0] nextLoadState = LOAD_BUTTONS;
	reg readWriteToggle = 0;
	
	reg [2:0] dataState = 0;
	reg [2:0] nextDataState = 0;
	reg [3:0] numButtonsPressed = 0; 
	reg [2:0] buttonCount = 0;
	reg registeringButton = 0;
	reg writeToButton = 0;
	reg [9:0] buttonReg;
	
	reg [9:0] buttons [0:7];
	reg [11:0] turrets [0:7];
	reg [19:0] bullets [0:127];
	
	wire [9:0] aButton;
	assign aButton = buttonreaddata;
	wire [7:0] buttonx;
	assign buttonx = (aButton[4:0] * 8) + 8;
	wire [7:0] buttony;
	assign buttony = (aButton[8:5] * 8) + 8;
	
	reg atEdge = 0;

	always @ (negedge clk) begin
		case (gameState) 
			INITIALIZATION: begin
				/*
					write over all existing buttons, turrets to predefined values
					write over all bullets to inactive
					after finish writing init bullets, then doneInit = 1
				*/
				case (roomType)
					2'b00: begin
						// check which load state then check which address
						case (loadState) 
							LOAD_BUTTONS: begin
						
									case (buttonAdr) 
										4'b0000: buttonwritedata = 12'b110100010000;
										4'b0001: buttonwritedata = 12'b110100010100;
										4'b0010: buttonwritedata = 12'b110100011000;
										4'b0011: buttonwritedata = 12'b110100011100;
										4'b0100: buttonwritedata = 12'b110100100000;
										4'b0101: buttonwritedata = 12'b110100100100;
										4'b0110: buttonwritedata = 12'b110100101000;
										4'b0111: buttonwritedata = 12'b111000101100;
										default: ;
									endcase
									buttonAdr_out = buttonAdr[2:0];
								
									buttonwren = 1;
								
									buttonAdr = buttonAdr + 1;
								
								if (buttonAdr > 4'b0111) begin
									buttonAdr = 4'b000;
									buttonAdr_out = buttonAdr;
									buttonwritedata = 0;
									
									nextLoadState = LOAD_TURRETS;
								end
								else begin
									nextLoadState = LOAD_BUTTONS;
								end

								doneInit = 0;
							end
							LOAD_TURRETS: begin
								buttonwren = 0;
						
									if (readWriteToggle == 0) begin
										turretAdr_out = turretAdr[2:0];
									
										case (turretAdr) 
											4'b0000: turretwritedata = 12'b110100010000;
											4'b0001: turretwritedata = 12'b110100010100;
											4'b0010: turretwritedata = 12'b110100011000;
											4'b0011: turretwritedata = 12'b110100011100;
											4'b0100: turretwritedata = 12'b110100100000;
											4'b0101: turretwritedata = 12'b110100100100;
											4'b0110: turretwritedata = 12'b110100101000;
											4'b0111: turretwritedata = 12'b111000101100;
											default: ;
										endcase
										
									
										turretwren = 1;
										readWriteToggle = 1;
									end
									else begin
										turretAdr = turretAdr + 1;
										readWriteToggle = 0;
									end
								
								if (turretAdr > 4'b0111) begin
									turretAdr = 4'b000;
									turretAdr_out = turretAdr;
									turretwritedata = 0;
									
									nextLoadState = LOAD_BULLETS;
								end
								else begin
									nextLoadState = LOAD_TURRETS;
								end
								
								doneInit = 0;
							
							end
							LOAD_BULLETS: begin
								buttonwren = 0;
								turretwren = 0;
									
								bulletwritedata = 20'b00000000000000000000;
								bulletAdr_out = bulletAdr;
								
								bulletwren = 1;
								
								bulletAdr = bulletAdr + 1;
								
								if (bulletAdr > 127) begin
									bulletAdr = 0;
									turretAdr_out = 0;
									doneInit = 1;
								end
								else nextLoadState = LOAD_BULLETS;
						
							end
							default: ;
						endcase
					end
					2'b01: begin
						
					end
					2'b10: begin
					
					end
					2'b11: begin
					
					end
					default: ;
				endcase
			end
			GAME_PROGRESSING: begin
				doneInit = 0;
				
				if (playerx == 0 && playery == 0) begin
					curPlayerPos = 15'b000100100001001;
					playerx = 8'b00001001;
					playery = 7'b0001001;
				end
				
				if (buttonAdr <= 7) begin
					buttonAdr_out = buttonAdr;
				
					if (aButton[9] == 1) begin
						if (prevPlayerPos[7:0] >= buttonx && prevPlayerPos[7:0] < buttonx + 8 && prevPlayerPos[14:8] + 8 >= buttony && prevPlayerPos[14:8] < buttony + 8) begin
							buttonwren = 1;
							buttonwritedata = aButton[8:0];
						end
					end
					else buttonwren = 0;
					
					buttonAdr = buttonAdr + 1;
				end
				if (buttonAdr == 8) begin
					buttonAdr = 0;
				end
				
				if (rdCounter == 20'b11001011011100110110) begin
				
					// Later, add check for buttons, and if all buttons pressed, then change room
					if (prevPlayerPos[14:8] - 8 == 0 && moveState == MOVING_NORTH) atEdge = 1;
					else if (prevPlayerPos[14:8] + 8 + 8 == 120 && moveState == MOVING_SOUTH) atEdge = 1;
					else if (prevPlayerPos[7:0] - 8 == 0 && moveState == MOVING_WEST) atEdge = 1;
					else if (prevPlayerPos[7:0] + 8 + 8 == 160 && moveState == MOVING_EAST) atEdge = 1;
					else begin atEdge = 0; end
				
					if (!atEdge && moveCounter == 7'b0000100) begin
						case (moveState)
							MOVING_NORTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] - 1;
							MOVING_SOUTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] + 1;
							MOVING_EAST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] + 1;
							MOVING_WEST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] - 1;
							default: ;
						endcase
						
						playerx = 	curPlayerPos[7:0];
						playery = 	curPlayerPos[14:8];
						moveCounter = 0;
					end
					else begin 
						moveCounter = moveCounter + 1; 
						rdCounter= 0;
					end
				end
				else
					rdCounter = rdCounter + 1;
			end
		
		endcase
		
		loadState = nextLoadState;
	end

endmodule

// =========================================================================
//module datapath(
//	input [3:0] moveState,
//	input [3:0] gameState,
//	input clk,
//	input [14:0] prevPlayerPos,
//	input [1:0] roomType,
//	
//	input [9:0] buttonreaddata,
//	input [11:0] turretreaddata,
//	input [17:0] bulletreaddata,
//	
//	output reg [14:0] curPlayerPos,
//	output reg [7:0] playerx,
//	output reg [6:0] playery,
//	
//	output reg buttonwren,
//	output reg turretwren,
//	output reg bulletwren,
//	output reg [2:0] buttonAdr_out,
//	output reg [2:0] turretAdr_out,
//	output reg [6:0] bulletAdr_out,
//	
//	output reg [9:0] buttonwritedata,
//	output reg [11:0] turretwritedata,
//	output reg [17:0] bulletwritedata,
//	
//	output reg doneInit,
//	output reg aaaaa
//);
//	
//	// movement state parameters
//	parameter IDLE = 4'b0000;
//	parameter MOVING_NORTH = 4'b0001;
//	parameter MOVING_EAST = 4'b0010;
//	parameter MOVING_SOUTH = 4'b0011;
//	parameter MOVING_WEST = 4'b0100;
//	
//	// gamestate parameters
//	parameter INITIALIZATION = 4'b0000;			// Initialize room data 
//	parameter GAME_PROGRESSING = 4'b0010;		// playing game
//	parameter GAMEOVER = 4'b0100;				// if hit then game over
//	parameter WIN = 4'b0101;
//	parameter ENDPROGRAM = 4'b0110;
//	parameter CHANGE_ROOM = 4'b0111;
//	
//	// initialization states
//	parameter INIT_BUTTONS = 2'b00;
//	parameter INIT_TURRETS = 2'b01;
//	parameter INIT_BULLETS = 2'b10;
//	
//	parameter READ_BUTTONS = 3'b000;
//	parameter CHECK_BUTTONS = 3'b001;
//	parameter WRITE_BUTTONS = 3'b010;
//	
//	reg [6:0] moveCounter = 0;
//	
//	reg [19:0] rdCounter = 0;
//
//	reg [3:0] buttonAdr = 0;
//	reg [3:0] turretAdr = 4'b0000;
//	reg [7:0] bulletAdr = 0;
//
//	reg [1:0] loadState = INIT_BUTTONS;
//	reg [1:0] nextLoadState = INIT_BUTTONS;
//	reg readWriteToggle = 0;
//	reg [3:0] dataWait = 0;
//	
//	reg [3:0] dataState = 0;
//	reg [2:0] nextDataState = 0;
//	
//
//	reg [3:0] numButtonsPressed = 0; 
//	reg [2:0] buttonCount = 0;
//	reg registeringButton = 0;
//	reg writeToButton = 0;
//	reg [9:0] buttonReg;
//	
//	reg [9:0] buttons [0:7];
//	reg [11:0] turrets [0:7];
//	reg [19:0] bullets [0:127];
//	
//	reg atEdge = 0;
//	
//	parameter one = 1'b1;
//
//	always @ (posedge clk) begin
//		case (gameState) 
//			INITIALIZATION: begin
//				/*
//					write over all existing buttons, turrets to predefined values
//					write over all bullets to inactive
//					after finish writing init bullets, then doneInit = 1
//				*/
//				bulletwren = 1;
//				turretwren = 1;
//				bulletwren = 1;
//				
//				case (roomType)
//					2'b00: begin
//						// check which load state then check which address
//						case (loadState) 
//							INIT_BUTTONS: begin
//							
//							
//								if (readWriteToggle == 0) begin
//									case (buttonAdr) 
//										4'b0000: buttonwritedata = 9'b1011000110;
//										4'b0001: buttonwritedata = 9'b1111000111;
//										4'b0010: buttonwritedata = 9'b1111001000;
//										4'b0011: buttonwritedata = 9'b1111001001;
//										4'b0100: buttonwritedata = 9'b1110001010;
//										4'b0101: buttonwritedata = 9'b1011001011;
//										4'b0110: buttonwritedata = 9'b1111001100;
//										4'b0111: buttonwritedata = 9'b1111001101;
//										default: ;
//									endcase
//									buttonAdr_out = buttonAdr;
//								
//									readWriteToggle = 1;
//								end
//								else begin
//									buttonAdr = buttonAdr + 1;
//									readWriteToggle = 0;
//								end
//								
//								if (buttonAdr > 4'b0111) begin
//									buttonAdr = 0;
//									aaaaa = 1;
//									
//									nextLoadState = INIT_TURRETS;
//								end
//								else begin
//									nextLoadState = INIT_BUTTONS;
//								end
//								
//								doneInit = 0;
//							end
//							INIT_TURRETS: begin
//							
//							/*
//								takes only earliest turretwritedata value, that is the only ouptut turret
//									- all being set to the same thing, stacked
//									- only one is being set others are not set
//							*/
//						
////								if (dataWait == 0) begin
////										case (turretAdr) 
////											4'b0000: turretwritedata = 12'b110100010000;
////											4'b0001: turretwritedata = 12'b110100010100;
////											4'b0010: turretwritedata = 12'b110100011000;
////											4'b0011: turretwritedata = 12'b110100011100;
////											4'b0100: turretwritedata = 12'b110100100000;
////											4'b0101: turretwritedata = 12'b110100100100;
////											4'b0110: turretwritedata = 12'b110100101000;
////											4'b0111: turretwritedata = 12'b111000101100;
////											default: ;
////										endcase
////										turretAdr_out = turretAdr[2:0];
////								end
//
//								if (turretAdr <= 7) begin
//									case (turretAdr) 
//										0:
//										1:
//
//									endcase
//									
//									
//									turretAdr_out = turretAdr;
//									turretAdr = turretAdr + 1;
//								end
//								else if (turretAdr == 8) begin
//									turretAdr = 0;
//									nextLoadState = INIT_BULLETS;
//									doneInit = 0;
//								end
//								
//								
//							
//							end
//							INIT_BULLETS: begin
//								doneInit = 1;
//								nextLoadState = GAME_PROGRESSING;
//							end
//							default: ;
//						endcase
//					end
//					2'b01: begin
//						
//					end
//					2'b10: begin
//					
//					end
//					2'b11: begin
//					
//					end
//					default: ;
//				endcase
//			end
//			GAME_PROGRESSING: begin
//				doneInit = 0;
//				
//				if (playerx == 0 && playery == 0) begin
//					curPlayerPos = 15'b000100100001001;
//					playerx = 8'b00001001;
//					playery = 7'b0001001;
//				end
//				
//				case (dataState) 
//					READ_BUTTONS: begin
//						if (dataWait == 0) begin
//							buttonAdr_out = buttonAdr;
//							buttonwren = 0;
//						end
//						else if (dataWait < 4'b0100) begin
//							dataWait = dataWait + 1;
//						end
//						else begin
//							buttons[buttonAdr] = buttonreaddata;
//							buttonAdr = buttonAdr + 1;
//							dataWait = 0;
//						end
//						
//						if (buttonAdr > 4'b0111) begin
//							buttonAdr = 0;
//							dataWait = 0;
//							nextDataState = CHECK_BUTTONS;
//						end
//						else begin
//							nextDataState = READ_BUTTONS;
//						end
//					end
//					CHECK_BUTTONS: begin
//						if (buttons[buttonAdr][9] == 1) begin
//							// current button is active
//							if (prevPlayerPos[7:0] >= (buttons[buttonAdr][4:0]*8) + 8 && prevPlayerPos[7:0] < (buttons[buttonAdr][4:0]*8) + 8 + 8 && prevPlayerPos[14:8] >= (buttons[buttonAdr][8:5] * 8) + 8 && prevPlayerPos[14:8] < (buttons[buttonAdr][8:5] * 8) + 8 + 8) begin
//								buttons[buttonAdr] = {one, buttons[buttonAdr][8:0]};
//							end
//						end
//						else buttonAdr = buttonAdr + 1;
//						
//						if (buttonAdr > 4'b0111) begin
//							buttonAdr = 0;
//							dataWait = 0;
//							nextDataState = WRITE_BUTTONS;
//						end
//						else begin
//							nextDataState = CHECK_BUTTONS;
//						end
//					end
//					WRITE_BUTTONS: begin
//						if (dataWait == 0) begin
//							buttonAdr_out = buttonAdr;
//							buttonwren = 1;
//							buttonwritedata = buttons[buttonAdr];
//						end
//						else if (dataWait < 4'b0100) begin
//							dataWait = dataWait + 1;
//						end
//						else begin
//							buttonAdr = buttonAdr + 1;
//							dataWait = 0;
//						end
//						
//						if (buttonAdr > 4'b0111) begin
//							buttonAdr = 0;
//							dataWait = 0;
//							nextDataState = READ_BUTTONS;
//						end 
//						else begin
//							nextDataState = WRITE_BUTTONS;
//						end
//					end
//					default: ;
//				endcase
//				
//				dataState = nextDataState;
//				
//				if (rdCounter == 20'b11001011011100110110) begin
//				
//					// Later, add check for buttons, and if all buttons pressed, then change room
//					if (prevPlayerPos[14:8] - 8 == 0 && moveState == MOVING_NORTH) atEdge = 1;
//					else if (prevPlayerPos[14:8] + 8 + 8 == 120 && moveState == MOVING_SOUTH) atEdge = 1;
//					else if (prevPlayerPos[7:0]  - 8 == 0 && moveState == MOVING_WEST) atEdge = 1;
//					else if (prevPlayerPos[7:0] + 8 + 8 == 160 && moveState == MOVING_EAST) atEdge = 1;
//					else begin atEdge = 0; end
//				
//					if (!atEdge && moveCounter == 7'b0000100) begin
//						case (moveState)
//							MOVING_NORTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] - 1;
//							MOVING_SOUTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] + 1;
//							MOVING_EAST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] + 1;
//							MOVING_WEST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] - 1;
//							default: ;
//						endcase
//						
//						playerx = 	curPlayerPos[7:0];
//						playery = 	curPlayerPos[14:8];
//						moveCounter = 0;
//					end
//					else begin 
//						moveCounter = moveCounter + 1; 
//						rdCounter= 0;
//					end
//				end
//				else
//					rdCounter = rdCounter + 1;
//			end
//		
//		endcase
//		
//		loadState = nextLoadState;
//	end
//
//endmodule

//=================================================================================================================

//module datapath(
//	input [3:0] moveState,
//	input [3:0] gameState,
//	input clk,
//	input [14:0] prevPlayerPos,
//	input [1:0] roomType,
//	
//	input [9:0] buttonreaddata,
//	input [11:0] turretreaddata,
//	input [17:0] bulletreaddata,
//	
//	output reg [14:0] curPlayerPos,
//	output reg [7:0] playerx,
//	output reg [6:0] playery,
//	
//	output reg buttonwren,
//	output reg turretwren,
//	output reg bulletwren,
//	output reg [2:0] buttonAdr_out,
//	output reg [2:0] turretAdr_out,
//	output reg [6:0] bulletAdr_out,
//	
//	output reg [9:0] buttonwritedata,
//	output reg [11:0] turretwritedata,
//	output reg [17:0] bulletwritedata,
//	
//	output reg doneInit
//);
//	
//	// movement state parameters
//	parameter IDLE = 4'b0000;
//	parameter MOVING_NORTH = 4'b0001;
//	parameter MOVING_EAST = 4'b0010;
//	parameter MOVING_SOUTH = 4'b0011;
//	parameter MOVING_WEST = 4'b0100;
//	
//	// gamestate parameters
//	parameter INITIALIZATION = 4'b0000;			// Initialize room data 
//	parameter GAME_PROGRESSING = 4'b0010;		// playing game
//	parameter GAMEOVER = 4'b0100;				// if hit then game over
//	parameter WIN = 4'b0101;
//	parameter ENDPROGRAM = 4'b0110;
//	parameter CHANGE_ROOM = 4'b0111;
//	
//	parameter LOAD_BUTTONS = 2'b00;
//	parameter LOAD_TURRETS = 2'b01;
//	parameter LOAD_BULLETS = 2'b10;
//	
//	parameter READ_BUTTONS = 3'b000;
//	parameter READ_BULLETS = 3'b001;
//	parameter CHECK_BUTTONS = 3'b010;
//	parameter CHECK_BULLETS = 3'b011;
//	parameter WAIT = 3'b100;
//	parameter UPDATE = 3'b101;
//	
//	reg [6:0] moveCounter = 0;
//	
//	reg [19:0] rdCounter = 0;
//
//	reg [3:0] buttonAdr = 0;
//	reg [3:0] turretAdr = 4'b0000;
//	reg [7:0] bulletAdr = 0;
//
//	reg [1:0] loadState = LOAD_BUTTONS;
//	reg [1:0] nextLoadState = LOAD_BUTTONS;
//	reg readWriteToggle = 0;
//	
//	reg [2:0] dataState = 0;
//	reg [2:0] nextDataState = 0;
//	reg [3:0] numButtonsPressed = 0; 
//	reg [2:0] buttonCount = 0;
//	reg registeringButton = 0;
//	reg writeToButton = 0;
//	reg [9:0] buttonReg;
//	
//	reg [9:0] buttons [0:7];
//	reg [11:0] turrets [0:7];
//	reg [19:0] bullets [0:127];
//	
//	reg atEdge = 0;
//
//	always @ (posedge clk) begin
//		case (gameState) 
//			INITIALIZATION: begin
//				/*
//					write over all existing buttons, turrets to predefined values
//					write over all bullets to inactive
//					after finish writing init bullets, then doneInit = 1
//				*/
//				case (roomType)
//					2'b00: begin
//						// check which load state then check which address
//						case (loadState) 
//							LOAD_BUTTONS: begin
//							
////							
////								if (readWriteToggle == 0) begin
////									case (buttonAdr) 
////										4'b0000: buttonwritedata = 9'b1011000110;
////										4'b0001: buttonwritedata = 9'b1011000111;
////										4'b0010: buttonwritedata = 9'b1011001000;
////										4'b0011: buttonwritedata = 9'b1011001001;
////										4'b0100: buttonwritedata = 9'b1010001010;
////										4'b0101: buttonwritedata = 9'b1011001011;
////										4'b0110: buttonwritedata = 9'b1011001100;
////										4'b0111: buttonwritedata = 9'b1011001101;
////										default: ;
////									endcase
////									buttonAdr_out = buttonAdr[1:0];
////								
////									buttonwren = 1;
////									readWriteToggle = 1;
////								end
////								else begin
////									buttonAdr = buttonAdr + 1;
////									readWriteToggle = 0;
////								end
////								
////								if (buttonAdr > 7) begin
////									buttonAdr = 0;
////									
////									nextLoadState = LOAD_TURRETS;
////								end
////								else begin
////									nextLoadState = LOAD_BUTTONS;
////								end
//								
//								doneInit = 0;
//								nextLoadState = LOAD_TURRETS;
//							end
//							LOAD_TURRETS: begin
//								buttonwren = 0;
//								
////								if (readWriteToggle == 0) begin
//
//								//if (turretAdr == 4'b0000) turretAdr = 4'b0001;
//						
//									case (turretAdr) 
//										4'b0000: turretwritedata = 12'b110100010000;
//										4'b0001: turretwritedata = 12'b110100010100;
//										4'b0010: turretwritedata = 12'b110100011000;
//										4'b0011: turretwritedata = 12'b110100011100;
//										4'b0100: turretwritedata = 12'b110100100000;
//										4'b0101: turretwritedata = 12'b110100100100;
//										4'b0110: turretwritedata = 12'b110100101000;
//										4'b0111: turretwritedata = 12'b111000101100;
//										default: ;
//									endcase
//									turretAdr_out = turretAdr[2:0];
//								
//									turretwren = 1;
////									readWriteToggle = 1;
////								end
////								else begin
////									
////									readWriteToggle = 0;
////								end
//								
//									turretAdr = turretAdr + 1;
//								
//								if (turretAdr > 4'b0111) begin
//									turretAdr = 4'b000;
//									
//									nextLoadState = LOAD_BULLETS;
//								end
//								else begin
//									nextLoadState = LOAD_TURRETS;
//								end
//								
//								doneInit = 0;
//							
//							end
//							LOAD_BULLETS: begin
//								doneInit = 1;
//								nextLoadState = GAME_PROGRESSING;
//							end
//							default: ;
//						endcase
//					end
//					2'b01: begin
//						
//					end
//					2'b10: begin
//					
//					end
//					2'b11: begin
//					
//					end
//					default: ;
//				endcase
//			end
//			GAME_PROGRESSING: begin
//				doneInit = 0;
//				
//				
//				if (rdCounter == 20'b11001011011100110110) begin
//				
//					// Later, add check for buttons, and if all buttons pressed, then change room
//					if (prevPlayerPos[14:8] == 0 && moveState == MOVING_NORTH) atEdge = 1;
//					else if (prevPlayerPos[14:8] + 8 == 120 && moveState == MOVING_SOUTH) atEdge = 1;
//					else if (prevPlayerPos[7:0] == 0 && moveState == MOVING_WEST) atEdge = 1;
//					else if (prevPlayerPos[7:0] + 8 == 160 && moveState == MOVING_EAST) atEdge = 1;
//					else begin atEdge = 0; end
//				
//					if (!atEdge && moveCounter == 7'b0000100) begin
//						case (moveState)
//							MOVING_NORTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] - 1;
//							MOVING_SOUTH: 	curPlayerPos[14:8] = prevPlayerPos[14:8] + 1;
//							MOVING_EAST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] + 1;
//							MOVING_WEST: 	curPlayerPos[7:0] = prevPlayerPos[7:0] - 1;
//							default: ;
//						endcase
//						
//						playerx = 	curPlayerPos[7:0];
//						playery = 	curPlayerPos[14:8];
//						moveCounter = 0;
//					end
//					else begin 
//						moveCounter = moveCounter + 1; 
//						rdCounter= 0;
//					end
//				end
//				else
//					rdCounter = rdCounter + 1;
//			end
//		
//		endcase
//		
//		loadState = nextLoadState;
//	end
//
//endmodule

