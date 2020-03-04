module paint
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;
	output [17:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[16];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, loadX, loadY, loadC;

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
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    
    // Instansiate datapath
	// datapath d0(...);
	
	
	//Testing movementControl:
	//this current implementation works, feel free to copy/paste!
	wire checkMovement, resetClock;
	wire [8:0] cursorX, cursorY;
	wire [3:0] directions;
	assign directions = ~KEY[3:0];
	rate_divider movement_divider(.clock(CLOCK_50),
								.resetN(resetn),
								.enableOut(checkMovement),
								.divide(28'd599_999));
	movement_control movement(.inX(cursorX),
									  .inY(cursorY),
									  .directions(directions),
									  .outX(cursorX),
									  .outY(cursorY),
									  .clock(checkMovement));									  
	assign LEDR [16:0] = {cursorX, cursorY};	//cursorX in 16:9, cursorY in 8:0
	
	datapath d0(.xloc(cursorX),
				.yloc(cursorY),
				.clk(CLOCK_50),
				.reset_N(resetn),
				.inColour(SW[9:7]),
				.loadX(loadX),
				.loadY(loadY),
				.loadC(loadC),
				.outX(x),
				.outY(y),
				.outColour(colour) 
				);
    // Instansiate FSM control
    // control c0(...);
   control c0(.start(SW[17]),
			  //.haveX(!KEY[3]),
   		  .reset_N(resetn),
			  .clk(CLOCK_50),
			  .loadX(loadX),
			  .loadY(loadY),
			  .loadC(loadC),
			  .enable(writeEn)
			  );
	
endmodule

module datapath(xloc, yloc, clk, reset_N, loadX, loadY, loadC, inColour, outX, outY, outColour);
	input [8:0] xloc, yloc;
	input clk, reset_N, loadX, loadY, loadC;
	input [2:0] inColour;
	output [7:0] outX;
	output [6:0] outY;
	output [2:0] outColour;

	reg [7:0] x;
	reg [6:0] y;
	reg [3:0] count;	//2 bits each since we want a 2x2 square
	reg [2:0] colour;

	always @(posedge clk)
	begin
		if (reset_N == 1'b0)
		begin
			x <= 8'b0;
			y <= 7'b0;
			colour <= 3'b0;
			count <= 4'b0;
		end
		else 
		begin
			if (loadX)
				x <= xloc;
			if (loadY)
				y <= yloc;
			if (loadC)
				colour <= inColour;
			if (count == 4'b1111)
				count <= 4'b0;
			else
				count <= count + 4'b1;
		end
	end

	assign outX = x + count[1:0];
	assign outY = y + count[3:2];
	assign outColour = colour;
endmodule

module control(start, reset_N, clk, loadX, loadY, loadC, enable);
	input start, reset_N, clk;
	output reg loadX, loadY, loadC, enable;

	localparam SLOADX = 3'b000,
			   SWAITX = 3'b001,
			   SLOADY = 3'b011,
			   SWAITY = 3'b010,
			   SDRAW = 3'b110;
	reg [2:0] state, next;

	always @(posedge clk)
	begin
		if (reset_N == 1'b0)
			state <= SLOADX;
		else
			state <= next;
	end

	always @(*)
	begin
		case (state)
			SLOADX: next <= SWAITX;
			SWAITX: next <= SLOADY;
			SLOADY: next <= start ? SWAITY : SLOADY;
			SWAITY: next <= start ? SWAITY : SDRAW;
			SDRAW: next <= start ? SLOADX : SDRAW;
		endcase 
	end

	always @(*)
	begin
		loadX <= 1'b0;
		loadY <= 1'b0;
		loadC <= 1'b1;
		enable <= 1'b0;
		case (state)
			SLOADX: loadX <= 1'b1;
			SWAITX: loadX <= 1'b1;
			SLOADY: loadY <= 1'b1;
			SWAITY: loadY <= 1'b1;
			SDRAW: begin
				loadX <= 1'b0;
				loadY <= 1'b0;
				loadC <= 1'b0;
				enable <= 1'b1;
			end
		endcase
	end

endmodule
