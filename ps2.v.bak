module ps2(
    // Inputs
	input CLOCK_50,
	input reset,

	// Bidirectionals
	inout PS2_CLK,					// PS2 Clock
 	inout PS2_DAT,					// PS2 Data

	output reg [7:0] dataOut,
	output received_data_en			// If 1 - new data has been received
	
);

	reg [10:0] count = 0;
	wire [7:0] received_data;

    reg clk_reg = 1;
    reg prev_clk = 1;
    reg data_reg = 1;
    reg ps2_clk_posedge;


    reg cur_ps2_state = 0; // 2 states - idle (0) or read (1)
    reg next_ps2_state = 0;

    localparam IDLE = 0;
    localparam READ = 1;

    // Register ps2 values
    always @ (posedge CLOCK_50) begin
        if (reset) begin
            // Default is high
            clk_reg <= 1;
            prev_clk <= 1;
            data_reg <= 1;
        end
        else begin
            prev_clk <= clk_reg;
            clk_reg <= PS2_CLK;
            data_reg <= PS2_DAT;
        end
    end

    // Detect posedge of ps2 clock
    always @ (posedge CLOCK_50) begin
        if (clk_reg == 1 && prev_clk == 0) ps2_clk_posedge = 1;
        else ps2_clk_posedge = 0;
		
		
    end


    // Mini fsm - determine if reading or idle
    always @ (posedge CLOCK_50) begin
        case (cur_ps2_state)
            IDLE: begin
                if (ps2_clk_posedge == 1 && data_reg == 0) begin
                    // If clock is high and input data is start bit 0, then start reading
                    next_ps2_state = READ;
                end
                else begin
                    next_ps2_state = IDLE;
                end
            end
            READ: begin
                if (received_data_en) begin
                    // recieved_data_en is sent when reading is done
                    next_ps2_state = IDLE;
                end
                else begin
                    next_ps2_state = READ;
                end
			end
            default: next_ps2_state = IDLE;
        endcase
		
		
    end
	 

	reg [7:0] prev_data = 0;
	
	

// Module Instantiation ==================================
    altera_up_ps2_data_in a1(
        // Inputs
        .clk(CLOCK_50),
        .reset(reset),

        .wait_for_incoming_data(0), // Only for sending commands to kb, not used in this case
        .start_receiving_data(READ),

        .ps2_clk_posedge(ps2_clk_posedge),
        .ps2_clk_negedge(0),        // not used anywhere, so pass in 0
        .ps2_data(data_reg),

        // Bidirectionals

        // Outputs
        .received_data(received_data),
        .received_data_en(received_data_en)			// If 1 - new data has been received
    );

	 
	
	 
	always @ (posedge CLOCK_50) begin
		case (received_data) 
			8'hE2: dataOut = 8'h1C; // A
			8'hC4: dataOut = 8'h1C; // A
			8'h10: dataOut = 8'h1C; // A
			8'h21: dataOut = 8'h1C; // A
			8'h43: dataOut = 8'h1C; // A
			8'h87: dataOut = 8'h1C; // A
			8'h1C: dataOut = 8'h1C; // A
			8'h38: dataOut = 8'h1C; // A
			8'h71: dataOut = 8'h1C; // A
			
			// if prev is c4, then a, else it's d
			8'h88: dataOut = prev_data == 8'h1C ? 8'h1C : 8'h23;
			
			8'h8D: dataOut = 8'h23; // D
			8'h1A: dataOut = 8'h23; // D
			8'h34: dataOut = 8'h23; // D
			8'h68: dataOut = 8'h23; // D
			8'hD1: dataOut = 8'h23; // D
			8'hA2: dataOut = 8'h23; // D
			8'h44: dataOut = 8'h23; // D
			8'h23: dataOut = 8'h23; // D
			8'h46: dataOut = 8'h23; // D
			
			
			8'hC7: dataOut = 8'h1D; // W
			8'h1D: dataOut = 8'h1D; // W
			8'h3A: dataOut = 8'h1D; // W
			8'h75: dataOut = 8'h1D; // W
			8'hEB: dataOut = 8'h1D; // W
			8'hD6: dataOut = 8'h1D; // W
			8'hAC: dataOut = 8'h1D; // W
			8'h58: dataOut = 8'h1D; // W
			
			// if prev is 58, w, else s
			8'hB1: dataOut = prev_data == 8'h1D ? 8'h1D : 8'h1B; 
			8'h63: dataOut = prev_data == 8'h1D ? 8'h1D : 8'h1B;
			
			8'hDB: dataOut = 8'h1B; // S
			8'hB6: dataOut = 8'h1B; // S
			8'h6C: dataOut = 8'h1B; // S
			8'hD8: dataOut = 8'h1B; // S
			8'hC6: dataOut = 8'h1B; // S
			8'h1B: dataOut = 8'h1B; // S
			8'h36: dataOut = 8'h1B; // S
			8'h6D: dataOut = 8'h1B; // S
			
			default: dataOut = 0;
			
			
		endcase
		
		prev_data <= dataOut;
		
	 end
	 
endmodule