module behavioralQ5 (
	input E, W, clk, reset, enable,
	output out
);

wire Qa, Qb, QNa, QNb;
// ora --> Qa, Qa --> QNa

// OR gates to DFFs
assign QNa = E | (~E & ~W & Qa & ~Qb) | (Qa & W);
assign QNb = W | (Qb & ~Qa) | (Qb & E);


// DFFs for A and B
	dff DFFA (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.d(QNa), // input d should be equal to the desired next value --> QNa
		.q(Qa) // qa will be the next value
	);

	dff DFFB (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.d(QNb),
		.q(Qb)
	);

// output
assign out = (~E & W & Qa) | (E & ~W & Qb) | (E & W);

endmodule