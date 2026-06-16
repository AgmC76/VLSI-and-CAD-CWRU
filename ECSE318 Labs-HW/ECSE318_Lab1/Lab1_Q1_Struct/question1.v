// ECSE 318 lab1,q1 structural
module serial_adder(
	input[3:0] bit_A, bit_B,
	input clk, reset, load, enable,
	output cout,
	output[3:0] SUM
);
/*
 * two input registers; A, B
 * a carry in for the full adder = q from the dff
 * a clock for the dff and registeres
 * a carry out for the full adder = d (input) of the dff
 * the sum of the full adder, is the output of the serial adder
 */


	wire wa, wb, s, co, cin, so;
	wire[3:0] ao_wire, bo_wire; // temporary wire to observe the shifting of A 



	// instantiate a shift register for the A and B inputs

	shift_reg sa(
		.clk(clk),
		.reset(reset),
		.load(load),
		.data_in(bit_A),
		.data_out(ao_wire),
		.shift_in(1'b0),
		.serial_out(wa)
	);

	shift_reg sb(
		.clk(clk),
		.reset(reset),
		.load(load), // load on 1
		.data_in(bit_B),
		.data_out(bo_wire),
		.shift_in(), // no shift in 1'b0?
		.serial_out(wb) 
	);

	full_adder FA(
		.a(wa), 
		.b(wb), 
		.cin(cin), 
		.co(co), 
		.sum(s)
	);

	dff DF(
		.clk(clk), 
		.reset(reset), 
		.enable(enable),
		.d(co), 
		.q(cin)
	);

	// a result register to store the output
	
	shift_reg sumresult(
		.clk(clk),
		.reset(reset),
		.load(1'b0), // no load 
		.data_in(4'b0000), 
		.data_out(SUM),
		.shift_in(s),
		.serial_out(so) // filler output, expect no serial out with the sum, illegal output
	);

	assign cout = cin;

endmodule


	
