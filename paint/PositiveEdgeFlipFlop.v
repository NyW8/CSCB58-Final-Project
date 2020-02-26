module PositiveEdgeFlipFlop(D, CLK, Q);
	input D;
	input CLK;
	output Q;
	
	wire connector;
	SRLatch Dlatch(D, ~CLK, ~D, connector);
	SRLatch SRL1(connector, CLK, ~connector, Q);
endmodule