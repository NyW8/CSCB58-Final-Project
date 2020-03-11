module drawSquare(S_X,
					S_Y,
					start,
					X,
					Y,
					Out_X,
					Out_Y,
					Done,
					clk
					);

	input clk, start;
	input [3:0] S_X, S_Y;
	input [7:0] X, Y;
	output [7:0] Out_X, Out_Y;
	output reg Done;
	
	reg [3:0] xCounter, yCounter;
	
	always@(posedge clk)
	begin
		if (!start || Done)
		begin //resets counters
			xCounter <= S_X;
			yCounter <= S_Y;
			if (start)
				Done <= 1'b0;
		end
		else	//start && not done
			begin
				if(yCounter == 3'b0) 	//set yCounter back to S_Y and decrement xCounter if not yet 0
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