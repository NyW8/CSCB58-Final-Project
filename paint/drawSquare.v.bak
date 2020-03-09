module drawSquare(	S_X,
					S_Y,
					X,
					Y,
					Out_X,
					Out_Y,
					Done,
					clk
					);

	input clk;
	input [4:0] S_X, S_Y, X, Y;
	output reg [4:0] Out_X, Out_Y;
	output reg Done;
	
	reg [4:0] xCounter, yCounter;
	
	always@(posedge clk)
	begin
		if (Done) begin //resets out_x and out _y
			Out_X <= 4'b0;
			Out_Y <= 4'b0;
		end 
		else begin //Displace out_x and out_y by their respective counter amounts
			Out_X <= X + xCounter; 
			Out_Y <= Y + yCounter;
		end
		
	end
	
	always@(posedge clk)
	begin
		if (Done) begin //resets counters
			xCounter <= 4'b0;
			yCounter <= 4'b0;
		end
		else
			if(yCounter != S_Y && xCounter != S_Y) begin //While block not filled
				xCounter <= xCounter + 1'b1; //Increments xCounnter 
			
				if (xCounter == (S_X + 1'b1) && yCounter != S_Y)begin //Increments yCounter when xCounter is out of bounds, resets xCounter
					xCounter <= 1'b0;
					yCounter <= yCounter + 1'b1;
					end
			end
			else
				Done <= 1'b1;
				 
	end	
	
endmodule 