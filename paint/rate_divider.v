module rate_divider (clock, resetN, enableOut, divide);
    input clock;
    input resetN;
    input [27:0] divide;
    output enableOut;

    reg [27:0] RateDivider;
    reg [27:0] OldSpeed;

    always @(posedge clock)
    begin
        if (resetN == 1'b0 || RateDivider == 28'b0)    //If we reset or it's counted down, reset to val
				RateDivider <= divide;
        else if (divide != OldSpeed)                    //Parallel load new signal
            begin
                RateDivider <= divide;
                OldSpeed <= divide;
            end
        else
            RateDivider <= RateDivider - 28'b1;         //otherwise, just subtract from it
	 end
    assign enableOut = (RateDivider == 28'b0) ? 1'b1 : 1'b0;
endmodule 