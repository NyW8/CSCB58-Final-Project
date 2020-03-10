module controller(start, selector, reset_N, Clock, loadX, loadY, loadX2, loadY2, loadC, enable, alu_select1);
	input Clock;
	//input [17:0] SW;
  //wire colour[2:0];
  //setColour(SW[17:14],Clock, colour[2]);

  //States
  reg freeForm, square, shape2, dontDraw;

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
  end
  
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
  wire go;
  assign go = start;

  always@()
	begin
    if (dontDraw || reset_N)
      begin
        case (current_state)
          default : next_state = WAIT;
        endcase
      end
    else if (square)
      begin
        case (current_state)
          WAIT    : next_state = go ? LOAD_X : WAIT;
          LOAD_X  : next_state = go ? LOAD_Y : LOAD_X;
          LOAD_Y  : next_state = go ? WAIT_2 : LOAD_Y;
          WAIT_2  : next_state = go ? LOAD_X2 : WAIT_2;
          LOAD_X2 : next_state = go ? LOAD_Y2 : LOAD_X2;
          LOAD_Y2 : next_state = go ? DRAW : LOAD_Y2;
          DRAW : next_state = go ? WAIT : DRAW;
          default : next_state = WAIT;
        endcase
      end
    else if (shape2)
      begin
      end
    else if (freeForm)
      begin
        case (current_state)
          WAIT : next_state = go ? FREEDRAW : WAIT;
          FREEDRAW : next_state = go ? WAIT : FREEDRAW
        endcase
      end
    else
      begin
      end
  end
  
  always@(posedge Clock)
  begin
    if (reset_N == 1'b0)
			current_state <= WAIT;
		else
      current_state <= next_state;
  end // state_FFS
  
  always @(*)
	begin
		loadX <= 1'b0;
		loadY <= 1'b0;
		loadC <= 1'b1;
		enable <= 1'b0;
		case (current_state)
			LOAD_X: loadX <= 1'b1;
			LOAD_Y: loadY <= 1'b1;
      LOAD_2X: loadX2 <= 1'b1;
			LOAD_2Y: loadY2 <= 1'b1;
			DRAW : begin
				loadX <= 1'b0;
				loadY <= 1'b0;
				loadC <= 1'b0;
				enable <= 1'b1;
        alu_select1 <= 1'b0;
			end
      FREEDRAW: begin
				loadX <= 1'b0;
				loadY <= 1'b0;
				loadC <= 1'b0;
				enable <= 1'b1;
        alu_select1 <= 1'b1;
			end
		endcase
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