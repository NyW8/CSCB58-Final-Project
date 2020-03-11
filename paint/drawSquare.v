module drawSquare(X2,
					Y2,
					start,
					X,
					Y,
					Out_X,
					Out_Y,
					Done,
					clk
					);

	input clk, start;
	input [7:0] X2, Y2;
	input [7:0] X, Y;
	output [7:0] Out_X, Out_Y;
	output reg Done;
	
	//looks of comments, just for you Artina && Nyah. U r welcomee!
	//topLeft X , topLeft Y, bottomRight X, bottomLeft Y
	reg [7:0] tLX, tLY;
	reg [3:0] S_X, S_Y;
	
	always@(X2 | X | Y2 | Y)
	begin
		tLX = (Y2 <= Y) ? X2 : X;
		S_X = (X2 <= X) ? X - X2 : X2 - X;
		tLY = (Y2 <= Y) ? Y2 : Y;
		S_Y = (Y2 <= Y) ? Y - Y2 : Y2 - Y;
	end
	
	
	reg [3:0] xCounter, yCounter;
	reg [5:0] counter;
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