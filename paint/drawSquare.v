module drawSquare(X2,
					Y2,
					X,
					Y,
					start,
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
	reg [7:0] S_X, S_Y;
	
	always@(X2 | X | Y2 | Y)
	begin
		tLX = (X2 <= X) ? X2 : X;
		S_X = (X2 <= X) ? X - X2 : X2 - X;
		tLY = (Y2 <= Y) ? Y2 : Y;
		S_Y = (Y2 <= Y) ? Y - Y2 : Y2 - Y;
	end
	
	
	reg [7:0] xCounter, yCounter;
	always@(posedge clk)
	begin
		if (!start || Done)
		begin //resets counters
			xCounter <= S_X;
			yCounter <= S_Y;
			if (start)
				Done <= 1'b0;
		end
		else
			begin
				if(yCounter == 7'b0) 
				begin //While block not filled
					if (xCounter == 7'b0)
						Done <= 1'b1;
					else 
						xCounter <= xCounter - 7'b1;
					yCounter <= S_Y;
				end
				else
					yCounter <= yCounter - 7'b1;
			end
	end	
	assign Out_X = tLX + xCounter;
	assign Out_Y = tLY + yCounter;
endmodule 