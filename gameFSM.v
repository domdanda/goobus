module GameFSM (
    input wire clk,                 // Clock signal
    input wire reset,               // Reset signal
    input playerHit,
	input player_won,
	input doneInit,
	input playerChangeRoom,
	input [3:0] prevState,
	

    output reg [3:0] currentState  
);

//data path is responsible for sending if the player has been hit (1 or 0),
// if the player is in the correct room (1 or 0), if player has press P (1 or 0),
// the datapath can call again to see if we have ended the program or else,
//instead of using the end program here, they can end program in the datapath,
// 

//open game, press start->go to the first room, player can pause (game freeze),
//if gameover or win, exit the program(exit state)
// Define states for the overall gameplay FSM

//newstates: 
parameter INITIALIZATION = 4'b0000;			// Initialize room data 
parameter GAME_PROGRESSING = 4'b0010;		// playing game
parameter GAMEOVER = 4'b0100;				// if hit then game over
parameter WIN = 4'b0101;
parameter ENDPROGRAM = 4'b0110;
parameter CHANGE_ROOM = 4'b0111;

reg [3:0] nextState = INITIALIZATION;
//reg [21:0] pause_counter;


always @(*) begin //change to posedge of the input if need
    //state <= nextState;
    case(prevState)
        INITIALIZATION: begin
            if (doneInit) begin					// doneInit will be sent after initializing all turrets, buttons, and bullets
				nextState = GAME_PROGRESSING;
			end
			else begin
				nextState = INITIALIZATION;
			end
        end
        GAME_PROGRESSING: begin
            if (playerHit) begin
                nextState = GAMEOVER;
            end 
			else if (player_won) begin
                nextState = WIN;
			end
			else if (playerChangeRoom) begin
				nextState = INITIALIZATION;
			end
			else begin
                nextState = GAME_PROGRESSING;
            end
        end
        GAMEOVER, WIN: begin
            nextState = ENDPROGRAM;
        end
        ENDPROGRAM: begin
            nextState = ENDPROGRAM;
        end
        default: nextState = INITIALIZATION;
    endcase
end

always @ (posedge clk or posedge reset)
begin
    if (reset)
    begin
        currentState <= INITIALIZATION;
        //pause_counter <= 22'b0;
    end
    else
        currentState <= nextState;
end

endmodule