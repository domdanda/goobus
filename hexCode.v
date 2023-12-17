module hex_decoder(c, display);

input [3:0] c;
output [6:0] display;

assign display[0] = ~((~c[0]|c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|c[2]|~c[3])&(~c[0]|c[1]|~c[2]|~c[3]));

assign display[1] = ~((~c[0]|c[1]|~c[2]|c[3])&(c[0]|~c[1]|~c[2]|c[3])&(~c[0]|~c[1]|c[2]|~c[3])&(c[0]|c[1]|~c[2]|~c[3])&(c[0]|~c[1]|~c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3]));

assign display[2] = ~((c[0]|~c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|~c[3])&(c[0]|~c[1]|~c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3]));

assign display[3]= ~((~c[0]|c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(c[0]|~c[1]|c[2]|~c[3])&(~c[0]|~c[1]|~c[2]|~c[3]));

assign display[4] = ~((~c[0]|c[1]|c[2]|c[3])&(~c[0]|~c[1]|c[2]|c[3])&(c[0]|c[1]|~c[2]|c[3])&(~c[0]|c[1]|~c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(~c[0]|c[1]|c[2]|~c[3]));

assign display[5] = ~((~c[0]|c[1]|c[2]|c[3])&(c[0]|~c[1]|c[2]|c[3])&(~c[0]|~c[1]|c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(~c[0]|c[1]|~c[2]|~c[3]));

assign display[6] = ~((c[0]|c[1]|c[2]|c[3])&(~c[0]|c[1]|c[2]|c[3])&(~c[0]|~c[1]|~c[2]|c[3])&(c[0]|c[1]|~c[2]|~c[3]));

endmodule

module score_counter(
    input wire clk,
    input wire reset,
    output reg [3:0] HEX0,
    output reg [3:0] HEX1,
    output reg [3:0] HEX2
);
reg [25:0] counter_1s = 1'd0;
reg [9:0] score = 1'd0;

always @(posedge clk) begin

    if (reset) begin
        score <= 1'd0;
        HEX0 <= 4'b0000;
        HEX1 <= 4'b0000;
        HEX2 <= 4'b0000;
    end else begin
	 	if(counter_1s == 26'd49999999) begin
		counter_1s <= 0;
        if (score == 10'd999) begin
            score <= 10'd999;
        end else begin
            score <= score + 1;
        end
        // Splitting the score into separate digits
        //HEX0 <= score[3:0];
        //HEX1 <= score[7:4];
        //HEX2 <= score[9:8];
		  HEX0 <= score%10;
		  HEX1 <= (score/10)%10;
		  HEX2 <= (score/100)%10;
		  
    end else begin
		counter_1s <= counter_1s +1;
	end
end
end

//hex_decoder hex_decoder_0(.c(HEX0), .display(HEX0));
//hex_decoder hex_decoder_1(.c(HEX1), .display(HEX1));
//hex_decoder hex_decoder_2(.c(HEX2), .display(HEX2));

endmodule

module part(input clk, input reset, output [3:0]counterval1, output[3:0]counterval2,output[3:0]counterval3);

	score_counter score_counter_inst (
    .clk(clk),
    .reset(reset),
    .HEX0(counterval1[3:0]),
    .HEX1(counterval2[3:0]),
    .HEX2(counterval3[3:0])
);

endmodule

module hexCode(
    input wire CLOCK_50,
    input wire reset,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2
);

wire [3:0] counter1;
wire [3:0] counter2;
wire [3:0] counter3;

part A0 (
    .clk(CLOCK_50),
    .reset(0),
    .counterval1(counter1[3:0]),
    .counterval2(counter2[3:0]),
    .counterval3(counter3[3:0])
);

hex_decoder hex_decoder_0(.c(counter1[3:0]), .display(HEX0[6:0]));
hex_decoder hex_decoder_1(.c(counter2[3:0]), .display(HEX1[6:0]));
hex_decoder hex_decoder_2(.c(counter3[3:0]), .display(HEX2[6:0]));

endmodule
