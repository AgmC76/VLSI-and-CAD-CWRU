module full_adder (
// structurual description for a full adder 
	input a, b, cin, // change a, b, and sum to [3:0] if a 4 bit adder is necessary
	output co, sum
);

	// defining the connections
	wire w1, w2, w3;
	// sum = a xor b xor cin
	xor(w1, a, b);
	xor(sum, w1, cin);

	
	// co = w2 + w3
	and(w2, w1, cin);
	and(w3, a, b);
	or(co, w2, w3);

endmodule