module SRLatch(S, CLK, R, Q);
	input S, CLK, R;
	output reg Q;
	
	reg notQ;
	
	always @(*) 
	begin
		if (CLK == 1'b1) 
		begin
			Q  =  ~(R | notQ); 
			notQ =  ~(S | Q); 
		end
	end
endmodule