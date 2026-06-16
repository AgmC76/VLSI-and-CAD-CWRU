module shift_reg(
// 
	input clk, reset, load, 
	input[3:0] data_in,
	input shift_in,
	output reg[3:0] data_out,
	output serial_out
);

	// parallel load, shift out, for the input registers
	always @ (posedge clk or posedge reset) begin
		if (reset)
			data_out <= 0; // empty the register
		else if (load)
			data_out <= data_in;	// parallel load, 4 bit data in, for the A, B registers
		else 
		// serial in, parallel out for the sum registers
			data_out <= {shift_in, data_out[3:1]};	// shift the bits right and output (serially, one at a time)
	end

	assign serial_out = data_out[0]; 

endmodule
	
