module controller (Clock, SW);
	input Clock;
	input [17:0] SW;
    wire colour[2:0];
    setColour(SW[17:14],Clock, colour[2]);

endmodule

module setColour(muxSelect, Clock, colour);
	input muxSelect, Clock;
    output reg colour;
    always @ (posedge Clock)
    begin
        colour <= muxSelect;
        //case(muxSelect)
        //    3'b000 : colour 
    end

endmodule

module setSize();

endmodule

module setMode();

endmodule