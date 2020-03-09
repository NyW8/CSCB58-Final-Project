module controller (go, Clock, SW);
	input Clock, go;
	input [17:0] SW;
    wire colour[2:0];
    setColour(SW[17:14],Clock, colour[2]);

  //States
  wire freeForm, shape1, shape2, dontDraw;
  
  reg [5:0] current_state, next_state;
  
  localparam  WAIT        = 5'd0,
              LOAD_X      = 5'd1,
              LOAD_Y      = 5'd2,
              WAIT_2      = 5'd3,
              LOAD_X2     = 5'd4,
              LOAD_Y2     = 5'd5,
              DRAW        = 5'd6,
              FREEDRAW    = 5'd7,
              DONTDRAW    = 5'd8;
           
  //condition should be when the 
  always@(freeForm)
	begin
    case (current_state)
      WAIT    : next_state = go ? LOAD_X : WAIT;
      LOAD_X  : next_state = go ? LOAD_Y : LOAD_X;
      LOAD_Y  : next_state = go ? WAIT_2 : LOAD_Y;
      WAIT_2  : next_state = go ? LOAD_X2 : WAIT_2;
      LOAD_X2 : next_state = go ? LOAD_Y2 : LOAD_X2;
      LOAD_Y2 : next_state = go ? FREEDRAW : LOAD_Y2;
      FREEDRAW : next_state = go ? WAIT : FREEDRAW;
    default : next_state = WAIT;
    endcase
  end
  
  always@(shape1)
  begin
  
  end
  

  
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