module dff (
// implementation of a d flip flop (dff)
	input clk, reset, d, enable,
	// add an enable later
	output reg q
);

	always @(posedge clk or posedge reset) begin
		if (reset)
			q <= 0;
		else if (enable)
			q <= d;
	end
endmodule
