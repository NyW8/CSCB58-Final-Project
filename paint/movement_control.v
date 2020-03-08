module movement_control (inX, inY, directions, outX, outY, clock);
	input [7:0] inX, inY;
	input [3:0] directions;	//clockwise from left: left, up, right, down
	output reg [7:0] outX, outY;
	input clock;
	
	always @(posedge clock)
	begin
		outX <= inX;
		outY <= inY;
		if (directions[3] == 1'b1)			//left
			outX <= inX - 1;
		else if (directions[1] == 1'b1)	//right
			outX <= inX + 1;
		if (directions[2] == 1'b1)			//up
			outY <= inY - 1;
		else if (directions[0] == 1'b1)	//down
			outY <= inY + 1;
	end
endmodule