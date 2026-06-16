`timescale 1ns/1ps

// ECSE 318 lab3,q5 structural testbench
module structuralQ5_tb;
	// Inputs
  	reg clk;
  	reg reset;
  	reg enable;
  	reg E;
  	reg W;

  	// Outputs
  	wire out;

  	structuralQ5 dut (
    	.E(E),
    	.W(W),
    	.clk(clk),
    	.reset(reset),
    	.enable(enable),
    	.out(out)
	);

  	// Clock 10ns period - 5,5
  	always #5 clk = ~clk;
  	always @(posedge clk) begin
		$display("E=%b, W=%b, out=%b", E, W, out);
  	end

    	integer i;

    	initial begin
        clk = 0;
        reset = 1;
        enable = 0;
        E = 0;
        W = 0;

        #10 reset = 0;
        enable = 1;

	//#10;
        // Loop through all 16 combinations of E,W,QNa,QNb
        // E is MSB (leftmost)
        $display("\n Simulation Start: 4-bit counting sequence (E,W,QNa,QNb) ");
        $display("time | E W QNa QNb | out | count");
        $display("--------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
		// count up from 0000 to 1111
		// Qa and Qb values change internally --> shift bits instead?
		// cannot properly count up, Qa and Qb will never be 1 if E, W are 0...
            	E = (i >> 3) & 1'b1;   // bit[3]
            	W = (i >> 2) & 1'b1;   // bit[2]

            	@(posedge clk);
            	// current values
            	$strobe("%4t |  %b  %b   %b   %b  |  %b | %d",
                	$time, E, W, dut.QNa, dut.QNb, out, i);
        end

        $display("=== Simulation End ===\n");
        #10 $finish;
    end
endmodule