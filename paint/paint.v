module paint(SW, KEY, LEDR, HEX0, HEX1, HEX2, HEX3);
	input [17:0] SW;
	input [4:0] KEY;
	output [17:0] LEDR;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	
	wire [17:0] testingOutput;
	
	/*
	This is a top-level module, please don't add code here except for testing!
	*/
	
	//Testing movementControl:
	//this current implementation works, feel free to copy/paste!
	/*wire [9:0] x, y;
	movement_control movement(.inX(x),
									  .inY(y),
									  .directions(~KEY[4:0]),
									  .outX(x),
									  .outY(y),
									  .clock(SW[17]));*/
									  
									  
	assign LEDR = testingOutput;
endmodule