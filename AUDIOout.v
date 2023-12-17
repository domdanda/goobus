module AUDIOout (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	I2C_SCLK,
	
	gamestate
);

	//+--------------------+//
	//| Inputs and Outputs |//
	//+--------------------+//
	
	// Inputs
	input				CLOCK_50;
	input		[3:0]	KEY;

	input				AUD_ADCDAT;

	// Bidirectionals
	inout				AUD_BCLK;
	inout				AUD_ADCLRCK;
	inout				AUD_DACLRCK;

	inout				I2C_SDAT;

	// Outputs
	output				AUD_XCK;
	output				AUD_DACDAT;

	output				I2C_SCLK;
					
	input wire [1:0] gamestate;


	//+----------------+//
	//| Internal Wires |//
	//+----------------+//
	
	wire				audio_in_available;
	wire		[31:0]	left_channel_audio_in;
	wire		[31:0]	right_channel_audio_in;
	wire				read_audio_in;

	wire				audio_out_allowed;
	wire		[31:0]	left_channel_audio_out;
	wire		[31:0]	right_channel_audio_out;
	wire				write_audio_out;
	wire 		[3:0] 	SOUND_TO_PLAY;
	
	//this is used for the beat rate divider
	reg [26:0] beatcounter;
	

	//+-----------+//
	//| ROM-Clips |//
	//+-----------+//
	
	//top line of background music
	ROM #(
		.FILE("sound.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile (mem_addr, CLOCK_50, mem_data);
	
	reg [5:0] mem_addr;
	wire [19:0] mem_data;
	reg [20:0] delay_cnt;
	wire [20:0] delay;
	assign delay = {11'd0, mem_data};
	
	reg snd;
	
	//bottom line of background music
	ROM #(
		.FILE("sound2.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile2 (mem_addr2, CLOCK_50, mem_data2);
	
	reg [5:0] mem_addr2;
	wire [19:0] mem_data2;
	reg [20:0] delay_cnt2;
	wire [20:0] delay2;
	assign delay2 = {11'd0, mem_data2};
	
	reg snd2;

	//top line of winning music
	ROM #(
		.FILE("sound3.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile3 (mem_addr3, CLOCK_50, mem_data3);
	
	reg [5:0] mem_addr3;
	wire [19:0] mem_data3;
	reg [20:0] delay_cnt3;
	wire [20:0] delay3;
	assign delay3 = {11'd0, mem_data3};
	
	reg snd3;
	
	//bottom line of winning music
	ROM #(
		.FILE("sound4.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile4 (mem_addr4, CLOCK_50, mem_data4);
	
	reg [5:0] mem_addr4;
	wire [19:0] mem_data4;
	reg [20:0] delay_cnt4;
	wire [20:0] delay4;
	assign delay4 = {11'd0, mem_data4};
	
	reg snd4;
	
	initial begin
		mem_addr <= 0;
		mem_addr2 <= 0;
		mem_addr3 <= 0;
		beatcounter <= 0;
	end
	
	//top line of background music
	ROM #(
		.FILE("sound5.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile5 (mem_addr5, CLOCK_50, mem_data5);
	
	reg [5:0] mem_addr5;
	wire [19:0] mem_data5;
	reg [20:0] delay_cnt5;
	wire [20:0] delay5;
	assign delay5 = {11'd0, mem_data5};
	
	reg snd5;
	
	//top line of background music
	ROM #(
		.FILE("sound6.mif"),
		.WORDS(64),
		.BITS_PER_WORD(20),
		.ADDRESS_WIDTH(6)
	) soundFile6 (mem_addr6, CLOCK_50, mem_data6);
	
	reg [5:0] mem_addr6;
	wire [19:0] mem_data6;
	reg [20:0] delay_cnt6;
	wire [20:0] delay6;
	assign delay6 = {11'd0, mem_data6};
	
	reg snd6;
	
	

	 
	always @(posedge CLOCK_50) begin
		
		// change notes every beat, based on which audio file you are playing
		if(beatcounter == 12500000 - 1) begin
			beatcounter <= 0;
			case(gamestate)
			
				0: begin
					mem_addr <= mem_addr + 1;
					mem_addr2 <= mem_addr2 + 1;
					
					mem_addr3 <= 0;
					mem_addr4 <= 0;
					mem_addr5 <= 0;
					mem_addr6 <= 0;
				end
				
				1: begin
					mem_addr3 <= mem_addr3 + 1;
					mem_addr4 <= mem_addr4 + 1;
					
					mem_addr <= 0;
					mem_addr2 <= 0;
					mem_addr5 <= 0;
					mem_addr6 <= 0;
				end
				
				2: begin
					mem_addr5 <= mem_addr5 + 1;
					mem_addr6 <= mem_addr6 + 1;
					
					mem_addr <= 0;
					mem_addr2 <= 0;
					mem_addr3 <= 0;
					mem_addr4 <= 0;
				end
			
			endcase
			
		end else beatcounter <= beatcounter + 1;
			
		if(gamestate == 0) begin
		
			// snd will flip between 0 and 1, outlining a square wave
			if(delay_cnt == delay) begin
				delay_cnt <= 0;
				snd <= !snd;
			end else delay_cnt <= delay_cnt + 1;
			
			if(delay_cnt2 == delay2) begin
				delay_cnt2 <= 0;
				snd2 <= !snd2;
			end else delay_cnt2 <= delay_cnt2 + 1;
			
		end 
		
		if(gamestate == 1) begin
		
			// snd will flip between 0 and 1, outlining a square wave
			if(delay_cnt3 == delay3) begin
				delay_cnt3 <= 0;
				snd3 <= !snd3;
			end else delay_cnt3 <= delay_cnt3 + 1;
			
			if(delay_cnt4 == delay4) begin
				delay_cnt4 <= 0;
				snd4 <= !snd4;
			end else delay_cnt4 <= delay_cnt4 + 1;
			
		end
			
		if(gamestate == 2) begin
		
			// snd will flip between 0 and 1, outlining a square wave
			if(delay_cnt5 == delay5) begin
				delay_cnt5 <= 0;
				snd5 <= !snd5;
			end else delay_cnt5 <= delay_cnt5 + 1;
			
			if(delay_cnt6 == delay6) begin
				delay_cnt6 <= 0;
				snd6 <= !snd6;
			end else delay_cnt6 <= delay_cnt6 + 1;
			
		end

	end

	wire [31:0] sound = snd ? 32'd50000000 : -32'd50000000;
	wire [31:0] sound2 = snd2 ? 32'd50000000 : -32'd50000000;
	wire [31:0] sound3 = snd3 ? 32'd50000000 : -32'd50000000;
	wire [31:0] sound4 = snd4 ? 32'd50000000 : -32'd50000000;
	wire [31:0] sound5 = snd5 ? 32'd50000000 : -32'd50000000;
	wire [31:0] sound6 = snd6 ? 32'd50000000 : -32'd50000000;

	assign left_channel_audio_out = (gamestate == 0) ? left_channel_audio_in+sound :
											  (gamestate == 1) ? left_channel_audio_in+sound3 :
											  (gamestate == 2) ? left_channel_audio_in+sound5 :
											  0;
											  
	assign right_channel_audio_out = (gamestate == 0) ? right_channel_audio_in+sound2 :
											   (gamestate == 1) ? right_channel_audio_in+sound4 :
											   (gamestate == 2) ? right_channel_audio_in+sound6 :
											   0;

	
	assign read_audio_in			= audio_in_available & audio_out_allowed;
	assign write_audio_out			= audio_in_available & audio_out_allowed;

	/*****************************************************************************
	 *                              Internal Modules                             *
	 *****************************************************************************/

	Audio_Controller Audio_Controller (
		// Inputs
		.CLOCK_50						(CLOCK_50),
		.reset						(~KEY[0]),

		.clear_audio_in_memory		(),
		.read_audio_in				(read_audio_in),
		
		.clear_audio_out_memory		(),
		.left_channel_audio_out		(left_channel_audio_out),
		.right_channel_audio_out	(right_channel_audio_out),
		.write_audio_out			(write_audio_out),

		.AUD_ADCDAT					(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK					(AUD_BCLK),
		.AUD_ADCLRCK				(AUD_ADCLRCK),
		.AUD_DACLRCK				(AUD_DACLRCK),


		// Outputs
		.audio_in_available			(audio_in_available),
		.left_channel_audio_in		(left_channel_audio_in),
		.right_channel_audio_in		(right_channel_audio_in),

		.audio_out_allowed			(audio_out_allowed),

		.AUD_XCK					(AUD_XCK),
		.AUD_DACDAT					(AUD_DACDAT)

	);

	avconf #(.USE_MIC_INPUT(1)) avc (
		.I2C_SCLK					(I2C_SCLK),
		.I2C_SDAT					(I2C_SDAT),
		.CLOCK_50					(CLOCK_50),
		.reset						(~KEY[0])
	);

endmodule