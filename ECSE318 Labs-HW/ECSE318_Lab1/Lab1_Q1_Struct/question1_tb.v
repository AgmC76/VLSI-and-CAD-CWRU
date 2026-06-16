`timescale 1ns/1ps

// ECSE 318 lab1,q1 structural testbench
module serial_adder_tb;
	// Inputs
  	reg clk;
  	reg reset;
  	reg load;
  	reg enable;
  	reg [3:0] A;
  	reg [3:0] B;

  	// Outputs
  	wire cout;
  	wire [3:0] SUM;

  	serial_adder dut (
    	.bit_A(A),
    	.bit_B(B),
    	.clk(clk),
    	.reset(reset),
    	.load(load),
    	.enable(enable),
    	.cout(cout),
    	.SUM(SUM)
);

  // Clock 10ns period - 5,5
  always #5 clk = ~clk;
  always @(posedge clk) begin
	$display("the carry is %b and the sum is %b", cout, SUM);
  end

  initial begin

    	// Initial signals
    	clk = 0;
    	reset = 1;
    	load = 0;
    	enable = 1;
    	A = 4'b0000;
    	B = 4'b0000;

    	#10 reset = 0;

    	// case 1: load A=5 (0101), B=3 (0011)
    	A = 4'b0101;
    	B = 4'b0011;
	$display("loading A = %b, and B = %b", A, B);
    	load = 1;
    	#10;               // apply for one clock
    	load = 0; // reset the load 

    	// run for 4 cycles to complete addition
    	#50;

    	$display("A=%b, B=%b, SUM=%b, cout=%b", A, B, SUM, cout);


    	// case 2: load A=7, B=6
    	A = 4'b0111;
    	B = 4'b0110;
    	$display("loading A = %b, and B = %b", A, B);
    	load = 1;
    	#10 load = 0;
    	#50;
    	$display("A=%b, B=%b, SUM=%b, cout=%b", A, B, SUM, cout);

    	$finish;
  end
endmodule
