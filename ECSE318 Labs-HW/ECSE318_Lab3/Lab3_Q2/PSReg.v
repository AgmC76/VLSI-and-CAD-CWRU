module PSReg (
// a parallel in serial out shift register
	input clk, reset, load,
	input enable, // acts as an enable
	input [7:0] parallel_in, // 8 bit input
	output reg serial_out // 1 bit output
);
reg [7:0]shift; // temporary register for shifting the data

	always @(posedge clk) begin
		if (load) begin
			shift <= parallel_in; // set the temporary shift register to the inputted data
			serial_out <= parallel_in[7];
		end else if (reset) begin
			shift <= 8'b0; // empty the register
			serial_out <= 1'b0;
		end else if (enable) begin
			serial_out <= shift[6];
			shift <= {shift[6:0], 1'b0};
		end
	end

endmodule