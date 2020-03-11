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
	wire enPlot, loadX, loadY, loadC;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(enPlot),
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
    
	wire start, enMove;
	wire [3:0] directions;
	assign start = SW[17];
	assign directions = ~KEY[3:0];
	datapath d0(.directions(directions),
				.clk(CLOCK_50),
				.reset_N(resetn),
				.size(SW[2:0]),
				.inColour(SW[9:7]),
				.loadX(loadX),
				.loadY(loadY),
				.loadC(loadC),
				.enMove(enMove),
				.enDraw(enPlot),
				.outX(x),
				.outY(y),
				.outColour(colour));
				
	//output lights for testing, feel free to change			
	assign LEDR[17] = enMove;
	assign LEDR[16] = enPlot;
	assign LEDR[15] = loadC;
	assign LEDR [11:0] = {x[5:0], y[5:0]};
	assign LEDR [14:12] = colour;
	
	
   control c0(.start(start),
				  .reset_N(resetn),
			     .clk(CLOCK_50),
			     .loadX(loadX),
			     .loadY(loadY),
			     .loadC(loadC),
				  .enMove(enMove),
			     .enPlot(enPlot)
			     );
	
endmodule

module datapath(directions, clk, reset_N, size, inColour, loadX, loadY, loadC, enMove, enDraw, outX, outY, outColour);
	input [3:0] directions;
	input clk, reset_N, loadX, loadY, loadC, enMove, enDraw;
	input [2:0] size;
	input [2:0] inColour;
	output [7:0] outX;	//output to VGA adapter
	output [6:0] outY;
	output [2:0] outColour;

	reg [7:0] x;	//x and y location
	reg [6:0] y;
	reg [2:0] colour;
								
	wire [7:0] cursorX, cursorY;		//changes in movement module depending on directions input
	always @(posedge clk)
	begin
		if (reset_N == 1'b0)
		begin
			x <= 7'b0;
			y <= 6'b0;
			colour <= 3'b0;
		end
		else 
		begin
			if (loadX || enMove)
				x <= cursorX;
			if (loadY || enMove)
				y <= cursorY;
			if (loadC)
				colour <= inColour;
		end
	end
	wire doneSq;	//a signal to indicate the drawing is done
	drawSquare sq(.S_X(size),
					  .S_Y(size),
					  .X(x),
					  .Y(y),
					  .start(enDraw),
					  .Out_X(outX),
					  .Out_Y(outY),
					  .Done(doneSq),
					  .clk(clk));
					  
	movement_control movement(.inX(cursorX),
									  .inY(cursorY),
									  .directions(directions),
									  .enMove(enMove),
									  .outX(cursorX),
									  .outY(cursorY),
									  .clock(clk));
	assign outColour = colour;
	/*assign LEDR [9:0] = {outX[4:0], outY[4:0]};
	assign LEDR [14:11] = outColour;*/
endmodule

module control(start, reset_N, clk, loadX, loadY, loadC, enMove, enPlot);//, LEDR);
	input start, reset_N, clk;
	output reg loadX, loadY, loadC, enPlot, enMove;
	//output [14:0] LEDR;

	localparam WAIT = 4'b0000,
				SLOADX = 4'b0010,
			   SLOADY = 4'b0110,
			   SDRAW = 4'b1100;
	reg [3:0] state, next;

	reg [18:0] enDraw;
	/*assign LEDR[3:0] = state;
	assign LEDR[4] = (enDraw == 19'd524_286);
	assign LEDR[5] = ~reset_N;*/
	always @(posedge clk)
	begin
		if (reset_N == 1'b0)
			state <= WAIT;
		else
			state <= next;
	end

	always @(*)
	begin
		case (state)
			WAIT: next <= start ? SLOADX : WAIT;
			SLOADX: next <= start ? SLOADY : WAIT;
			SLOADY: next <= start ? SDRAW : WAIT;
			SDRAW: next <= (enDraw < 19'b011) ? WAIT : SDRAW;	//Add a wait state
		endcase 
	end

	always @(posedge clk)
	begin
		enMove <= 1'b0;
		loadX <= 1'b0;
		loadY <= 1'b0;
		loadC <= 1'b1;
		enPlot <= 1'b0;
		
		case (state)
			WAIT : begin
				enMove <= 1'b1;
				enDraw <= 19'd524_286;
				end
			SLOADX: 
				begin
				enDraw <= 19'd524_286;
				loadX <= 1'b1;
				end
			SLOADY:
				begin
				enDraw <= 19'd524_286;
				loadY <= 1'b1;
				end
			SDRAW: begin
				loadX <= 1'b0;
				loadY <= 1'b0;
				loadC <= 1'b0;
				enPlot <= 1'b1;
				enDraw <= enDraw - 19'b1;
			end
		endcase
	end
endmodule
