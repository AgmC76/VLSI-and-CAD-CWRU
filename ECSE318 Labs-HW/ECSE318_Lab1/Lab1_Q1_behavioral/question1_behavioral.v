// ECSE 318 lab1,q1 behavioral
module serial_adder_behavioral(
	input[3:0] bit_A, bit_B,
	input clk, reset, load, enable,
	output reg cout,
	output reg [3:0] SUM
);

	reg[3:0] A, B; // shift registers for a/b inputs
	reg cin; // carry register
	
	always @(posedge clk or posedge reset) begin
		// case 1 - reset, set everything to zero 
		if (reset) begin
			A <= 0;
			B <= 0;
			SUM <= 0; 
			cout <= 0;
			cin <= 0; 
		end
		// case 2 - load in inputs, no sum or carry out yet
		else if (load) begin
			A <= bit_A;
			B <= bit_B;
			SUM <= 0;
			cin <= 0;
			cout <= 0; 
		end
		// case 3 - operations start
		else begin
			SUM <= {(A[0] ^ B[0] ^ cin), SUM[3:1]}; //  sum = A xor B xor carry
			cin <= (A[0] & B[0]) | (A[0] & cin) | (B[0] & cin); // c out = AB or ACin + BCin, this will be cin next cycle ignore naming fn
			// shifting the bits right by 1
			A <= A >> 1;
			B <= B >> 1;
			cout <= cin;	// cout = cin, and cin is the cin for the next cycle
		end
	end
endmodule