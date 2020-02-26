module TFlipFlop(T, CLK, CLR_B, Q);
	input T, CLK, CLR_B;
	output Q;
	
	wire D;
	assign D = (T&& ~Q) || (~T && Q);
	PositiveEdgeFlipFlop PEFF1(D, CLK, Q);
endmodule
