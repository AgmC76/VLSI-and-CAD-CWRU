module SPReg (
// a serial to parallel shift register
	input reset, clk, load,
	input serial_in,
	output reg [7:0] parallel_out
);

// should also consider the SSPCLKIN and SSPCLKOUT

reg [7:0] shift; // check if size of register is correct
reg [2:0] bit_count;  // temporary counter: 3 bits can count 0-7 (8 values)

	always @(posedge clk) begin
    		if (reset) begin
        		shift <= 8'b0;
        		parallel_out <= 8'b0;
        		bit_count <= 3'b0; 
    		end else if (load) begin
        		shift <= {shift[6:0], serial_in};
        		bit_count <= bit_count + 1;
        
        		// Check for complete byte after 8 shifts (count 0-7)
        		if (bit_count == 3'b111) begin  // After 8 bits received
            			parallel_out <= {shift[6:0], serial_in};
            			bit_count <= 3'b0;  // Reset counter for next byte
        		end
    		end
	end

endmodule

