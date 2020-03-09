module drawSquare(S_X,
					S_Y,
					start,
					X,
					Y,
					Out_X,
					Out_Y,
					Done,
					clk, LEDR
					);

	input clk, start;
	input [3:0] S_X, S_Y;
	input [7:0] X, Y;
	output [7:0] Out_X, Out_Y;
	output reg Done;
	output [17:0] LEDR;
	
	reg [3:0] xCounter, yCounter;
	reg [5:0] counter;
	assign LEDR [5:0] = counter;
	assign LEDR [6] = Done;
	assign LEDR [7] = start;
	assign LEDR [8] = !start;
	always@(posedge clk)
	begin
		if (!start || Done)
		begin //resets counters
			xCounter <= S_X;
			yCounter <= S_Y;
			counter [5:3] <= S_X;
			counter [2:0] <= S_Y;
			if (start)
				Done <= 1'b0;
		end
		else
			begin
				if(yCounter == 3'b0) 
				begin //While block not filled
					if (xCounter == 3'b0)
						Done <= 1'b1;
					else 
						xCounter <= xCounter - 3'b1;
					yCounter <= S_Y;
				end
				else
					yCounter <= yCounter - 3'b1;
			end
	end	
	assign Out_X = X + xCounter;
	assign Out_Y = Y + yCounter;
endmodule 