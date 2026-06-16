module structuralQ5 (
	input E, W, clk, reset, enable,
	output out
);

// Da --> QNa: output of o1, the next value for dff A
// Db --> QNb: output of o2, the next value for dff B
// Ao: output dff A to and gate
// Bo: output dff B to and gate
// u1o, u2o, u3o, u4o: outputs of the AND gates
wire Qa, Qb;
// wire Qa_not, Qb_not;
wire QNa, QNb;
// wire Ao, Bo;
wire u1o, u2o, u3o;
wire a1o, a2o, b1o, b2o;


//assign Qa_not = ~Qa;
//assign Qb_not = ~Qb;


/*
 * DFF
 */
	dff DFFA (
		.clk(clk), 
		.reset(reset), 
		.enable(enable),
		.d(QNa), // change to output of O1
		.q(Qa) // change to a wire leading to final AND gate, this was Ao, changed to Qa, verify
	);

	dff DFFB (
		.clk(clk), 
		.reset(reset), 
		.enable(enable),
		.d(QNb), // change to output of O2
		.q(Qb) // change to a wire leading to final AND gate
	);


// deriving next Q value:
	// for DFF A
	and A1 (a1o, W, Qa);
	and A2 (a2o, ~E, ~W, Qa, ~Qb);
	
	// QA next = E + WQa + ~E~WQa~Qb
	or A0 (QNa, E, a1o, a2o);

	// for DFF B
	and B1 (b1o, Qb, E);
	and B2 (b2o, Qb, ~Qa);

	// QB next = W + QbE + Qb~Qa
	or B0 (QNb, W, b1o, b2o);

// using minimal sum: ~EWQa + E~WQb + EW = output
	and U1 (u1o, ~E, W, Qa);
	and U2 (u2o, E, ~W, Qb);
	and U3 (u3o, E, W);

	or O1 (out, u1o, u2o, u3o);

endmodule
