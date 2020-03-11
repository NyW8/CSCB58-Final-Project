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
	input   [17:0]   SW;					// [2:0] size, [9:7] colour, 16 resetn
	input   [3:0]   KEY;					// directions(3 == left, 2 == up, 1 == right, 0 == down)
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
	wire writeEn, loadX, loadY, loadC, loadX2, loadY2;

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
		defparam VGA.RESOLUTION = "160x120";
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
	wire [7:0] cursorX, cursorY;
	wire [3:0] directions;
	assign directions = ~KEY[3:0];
	rate_divider movement_divider(.clock(CLOCK_50),
								.resetN(resetn),
								.enableOut(checkMovement),
								.divide(28'd15_999_999));
	movement_control movement(.inX(cursorX),
									  .inY(cursorY),
									  .directions(directions),
									  .outX(cursorX),
									  .outY(cursorY),
									  .clock(checkMovement));
									  
	//assign LEDR [16:0] = {cursorX, cursorY};	//cursorX in 16:9, cursorY in 8:0
	//assign LEDR[17] = ~cursorX[0];
	
	wire start;
	assign start = SW[17];
	/*drawSquare sq(.S_X(4'b0010),
					  .S_Y(4'b0010),
					  .X(8'b00111111),
					  .Y(8'b00111111),
					  .start(start),
					  .Out_X(outX),
					  .Out_Y(outY),
					  .Done(doneSq),
					  .clk(clk));
	assign LEDR [14:0] = {outX, outY};*/
			
	wire doneSq;
	
	datapath d0(.xloc(cursorX),
				.yloc(cursorY),
				.clk(CLOCK_50),
				.reset_N(resetn),
				.size(SW[2:0]),
				.inColour(SW[9:7]),
				.loadX(loadX),
				.loadY(loadY),
				.loadX2(loadX2),
				.loadY2(loadY2),
				.loadC(loadC),
				.outX(x),
				.outY(y),
				.outColour(colour),
				.selector(SW[15:14]),
				.doneSq(doneSq),
				.LEDR(LEDR[14:0])
				);
	//assign LEDR[14:0] = {x, y};
    // Instansiate FSM control
    // control c0(...);
	 wire checkControl;
	rate_divider movement_divider2(.clock(CLOCK_50),
								.resetN(resetn),
								.enableOut(checkControl),
								.divide(28'd999_999));
   controller c0(
				.start(SW[13]),
				.startPrime(SW[12]),
			  .selector(SW[15:14]),
			  
   		      .reset_N(resetn),
			  .Clock(checkControl),
			  .doneSq(doneSq),
			  .loadX(loadX),
			  .loadY(loadY),
			  .loadX2(loadX2),
			  .loadY2(loadY2),
			  .loadC(loadC),
			  .enable(writeEn),
			  .led(LEDR[15])
			  );
			  
	//assign LEDR [11:0] = {x[5:0], y[5:0]};
	//assign LEDR [14:12] = size;
	
endmodule
// added an input called size, if you need it for rectangle, you might want to modify it
module datapath(alu_selector, xloc, yloc, clk, reset_N, size, inColour, loadX, loadY, loadX2, loadY2, loadC, outX, outY, outColour, selector, doneSq, LEDR);

	reg freeForm, square, shape2, dontDraw;
	
	output [14:0] LEDR;
	
	input [1:0] alu_selector;
	input [7:0] xloc, yloc;
	input clk, reset_N, loadX, loadY, loadC, loadX2, loadY2;
	input [2:0] size;
	input [2:0] inColour;
	output [7:0] outX;
	output [7:0] outY;
	output [2:0] outColour;
	input [1:0] selector;
	output doneSq;
	
	reg [7:0] x, x2;
	reg [7:0] y, y2;
	reg [2:0] colour;
	//reg [3:0] count;	//2 bits each since we want a 2x2 square
	//reg [2:0] countX;	//size of square depends on size input, so requires separate count
	//reg [2:0] countY;

	assign LEDR [14:0] = {x[6:0], x2};
	
	/*
  	always@(selector)
  	begin
    freeForm = 1'b0;
    square = 1'b0;
    shape2 = 1'b0;
    dontDraw = 1'b0;
    case (selector)
      2'b00 : dontDraw = 1'b1;
      2'b01 : freeForm = 1'b1;
      2'b10 : square = 1'b1;
      2'b11 : shape2 = 1'b1;
   endcase
  	end
	*/

	wire [7:0] newXloc, newYloc;
	reg startDrawSquare;

	always @(posedge clk)
	begin
		if (reset_N == 1'b0)
		begin
			x <= 7'b0;
			y <= 7'b0;
			x2 <= 7'b0;
			y2 <= 7'b0;
			colour <= 3'b0;
			//countX <= size;	//if size = n, coordinates move at most n-1
			//countY <= size;
		end
		else 
		begin
			if (loadX)
			begin
				x <= xloc;
				x2 <= xloc + size;
			end
			if (loadY)
			begin
				y <= yloc;
				y2 <= yloc + size;
			end
			if (loadC)
				colour <= inColour;
			if (loadX2)
				x2 <= xloc;
			if (loadY2)
				y2 <= yloc;
		end
	end

	always@(*)
	begin
		case (alu_selector)
			2'b01 : startDrawSquare = 1'b1;
			2'b11 : startDrawSquare = 1'b1;
			default : startDrawSquare = 1'b0;
			//2'b11 : ;
		endcase
	end
	
	drawSquare sq(.X2(x2),
					  .Y2(y2),
					  .X(x),
					  .Y(y),
					  .start(startDrawSquare),
					  .Out_X(outX),
					  .Out_Y(outY),
					  .Done(doneSq),
					  .clk(clk));
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
			SLOADX: next <= SLOADY;
			SLOADY: next <= start ? SDRAW : SLOADX;
			SDRAW: next <= start ? SLOADX : SDRAW;	//Add a wait state
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
			SLOADY: loadY <= 1'b1;
			SDRAW: begin
				loadX <= 1'b0;
				loadY <= 1'b0;
				loadC <= 1'b0;
				enable <= 1'b1;
			end
		endcase
	end
endmodule
