module game(
		CLOCK_50,						//	On Board 50 MHz
		
		// ON-BOARD INPUTS AND OUTPUTS
		KEY,								// Keys
		SW,								// Switches
		LEDR,
		
		PS2_CLK,
		PS2_DAT,
		
		
		// VGA OUTPUT PORTS
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC 
		VGA_BLANK_N,						//	VGA BLANK (*CHANGE TO VGA_BLANK_N FOR DE1-SOC)
		VGA_SYNC_N,						//	VGA SYNC (*CHANGE TO VGA_SYNC_N FOR DE1-SOC)
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,
		
		// AUDIO INPUTS AND OUTPUTS
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		FPGA_I2C_SDAT,						// (*CHANGE TO FPGA_I2C_SDAT FOR DE1-SOC)
		AUD_XCK,
		AUD_DACDAT,
		FPGA_I2C_SCLK,							// (*CHANGE TO FPGA_I2C_SCLK FOR DE1-SOC)
		HEX0,
        HEX1,
        HEX2
);

	// CLOCK INPUT DECLARATION
	input			CLOCK_50;
	output [9:0] LEDR;
	
	inout PS2_CLK;
	inout PS2_DAT;
	
	// VGA OUTPUT DECLARATIONS
	output			VGA_CLK;
	output			VGA_HS;
	output			VGA_VS;
	output			VGA_BLANK_N;
	output			VGA_SYNC_N;
	output	[7:0]	VGA_R;
	output	[7:0]	VGA_G;
	output	[7:0]	VGA_B;
	output [6:0] HEX0;
    output [6:0] HEX1;
    output [6:0] HEX2;
	
	// AUDIO INPUT AND OUTPUT DECLARATIONS
	input				AUD_ADCDAT;
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;
	inout				FPGA_I2C_SDAT;
	output				AUD_XCK;
	output				AUD_DACDAT;
	output				FPGA_I2C_SCLK;
	
	// ON-BOARD INPUT AND OUTPUT DECLARATIONS
	input	[3:0]	KEY;					
	input [9:0] SW;
	
	//+------+//
	//| RAMs |//
	//+------+//
	
	//TURRETS (max 8) 
	wire [2:0] turretDPaddress; //address input for datapath
	wire [2:0] turretVGAaddress; //address input for vga controller
	//clock 50 for input
	wire [11:0] turretwritedata; //write data for turret from datapath
	//set data b to 0, it will never be used
	wire turretwrEN; //set high if writing turret data
	//set wrEN b to 0, it will never be used
	wire [11:0] turretDPoutput;
	wire [11:0] turretVGAoutput;
	
	turretRAM turretRAM(
		turretDPaddress,
		turretVGAaddress,
		CLOCK_50,
		turretwritedata,
		0,
		turretwrEN,
		0,
		turretDPoutput,
		turretVGAoutput
	);

	hexCode startTimer(
    .CLOCK_50(CLOCK_50),
    .reset(0),
    .HEX0(HEX0[6:0]),
    .HEX1(HEX1[6:0]),
    .HEX2(HEX2[6:0])
    );
	
	//BUTTONS (max 8)
	wire [2:0] buttonDPaddress; //address input for datapath
	wire [2:0] buttonVGAaddress; //address input for vga controller
	//clock 50 for input
	wire [9:0] buttonwritedata; //write data for turret from datapath
	//set data b to 0, it will never be used
	wire buttonwrEN; //set high if writing button data
	//set wrEN b to 0, it will never be used
	wire [9:0] buttonDPoutput;
	wire [9:0] buttonVGAoutput;
	
	buttonRAM buttonRAM(
		buttonDPaddress,
		buttonVGAaddress,
		CLOCK_50,
		buttonwritedata,
		0,
		buttonwrEN,
		0,
		buttonDPoutput,
		buttonVGAoutput
	);
	
	//BULLETS (max 128)
	wire [6:0] bulletDPaddress; //address input for datapath
	wire [6:0] bulletVGAaddress; //address input for vga controller
	//clock 50 for input
	wire [17:0] bulletwritedata; //write data for bullet from datapath
	//set data b to 0, it will never be used
	wire bulletwrEN; //set high if writing bullet data
	//set wrEN b to 0, it will never be used
	wire [17:0] bulletDPoutput;
	wire [17:0] bulletVGAoutput;
	
	bulletRAM bulletRAM(
		bulletDPaddress,
		bulletVGAaddress,
		CLOCK_50,
		bulletwritedata,
		0,
		bulletwrEN,
		0,
		bulletDPoutput,
		bulletVGAoutput
	);
	
	//+----------------+//
	//| Internal Wires |//
	//+----------------+//
	
	wire [7:0] playerx;
	wire [6:0] playery; 
	
	
	VGAout VGA(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,
		playerx,
		playery,
		turretVGAaddress,
		turretVGAoutput,
		bulletVGAaddress,
		bulletVGAoutput,
		buttonVGAaddress,
		buttonVGAoutput,
		SW[1:0]
	);
	

	wire [7:0] ps2data;
	wire received_data_en;
	wire [3:0] moveState;
	wire a, b, c, d;
	wire [14:0] prevPlayerPos;
	wire [14:0] curPlayerPos;
	wire [14:0] buttonOut;
	wire [3:0] gameState;
	wire doneInit;
	wire [3:0] prevGameState;
	
	ps2 p2(
		CLOCK_50,
		0,
		PS2_CLK,
		PS2_DAT,
		ps2data,
		received_data_en,
	);
	
	GameFSM g1(
		CLOCK_50,
		reset,
		0,
		0,
		doneInit,
		0,
		prevGameState,
		gameState
	);
	
	assign prevGameState = gameState;
	
	PlayerFSM p1(
		CLOCK_50,
		0, 
		ps2data,
		received_data_en,
		0,
		moveState,
		a, b, c, d
	);
	
	
	/*
		input [3:0] moveState,
		input [3:0] gameState,
		input clk,
		input [14:0] prevPlayerPos,
		input [1:0] roomType,
		
		input [9:0] buttonreaddata,
		input [11:0] turretreaddata,
		input [19:0] bulletreaddata,
		
		output reg [14:0] curPlayerPos,
		output reg [7:0] playerx,
		output reg [6:0] playery,
		
		output buttonwren,
		output turretwren,
		output bulletwren,
		output [2:0] buttonAdr_out,
		output [2:0] turretAdr_out,
		output [6:0] bulletAdr_out,
		
		output [9:0] buttonwritedata,
		output [11:0] turretwritedata,
		output [19:0] bulletwritedata,
		
		output doneInit
	*/
	
	datapath d1(
		.moveState(moveState),
		.gameState(gameState),
		.clk(CLOCK_50),
		.prevPlayerPos(prevPlayerPos),
		.roomType(0),
		.buttonreaddata(buttonDPoutput),
		.turretreaddata(turretDPoutput),
		.bulletreaddata(bulletDPoutput),
		
		.curPlayerPos(curPlayerPos),
		.playerx(playerx),
		.playery(playery),
		
		.buttonwren(buttonwrEN),
		.turretwren(turretwrEN),
		.bulletwren(bulletwrEN),
		.buttonAdr_out(buttonDPaddress),
		.turretAdr_out(turretDPaddress),
		.bulletAdr_out(bulletDPaddress),
		
		.buttonwritedata(buttonwritedata),
		.turretwritedata(turretwritedata),
		.bulletwritedata(bulletwritedata),
		.doneInit(doneInit),
		//.aaaaa(LEDR[0])
	);
	
	assign prevPlayerPos = curPlayerPos;
	
	
	
	AUDIOout AUDIO(
			// Inputs
		CLOCK_50,
		KEY,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		FPGA_I2C_SDAT,

		// Outputs
		AUD_XCK,
		AUD_DACDAT,

		FPGA_I2C_SCLK,
		SW[1:0]
	);

endmodule