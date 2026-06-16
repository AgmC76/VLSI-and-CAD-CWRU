// ECSE 318 Lab 1 - Problem 2
// 4-bit CLA testbench

`timescale 1ns/10ps

module cla_adder_tb;
    reg  [3:0] a, b;
    reg        c_in;
    wire [3:0] s;
    wire       c_out;

    // DUT
    cla_adder uut (
        .a(a),
        .b(b),
        .c_in(c_in),
        .s(s),
        .c_out(c_out)
    );

    initial begin
        $monitor("T=%0t | a=%b b=%b c_in=%b | s=%b c_out=%b",
                 $time, a, b, c_in, s, c_out);

        // Test 1: no carry
        a = 4'b0101; b = 4'b0011; c_in = 0;  // 5 + 3 = 8 (1000)
        #100;
	if (s == 4'b0000) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        // Test 2: with carry-in only
        a = 4'b0000; b = 4'b0000; c_in = 1;  // 0 + 0 + 1 = 1
        #100;
	if (s == 4'b0001) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        // Test 3: generate carry at LSB
        a = 4'b0001; b = 4'b0001; c_in = 0;  // 1 + 1 = 2
        #100;
	if (s == 4'b0010) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        // Test 4: all ones + carry in
        a = 4'b1111; b = 4'b1111; c_in = 1;  // 15 + 15 + 1 = 31 (11111)
        #100; 
	if (s == 4'b1111) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        // Test 5: random values (no carry)
        a = 4'b1010; b = 4'b0110; c_in = 0;  // 10 + 6 = 16
        #100;
	if (s == 4'b0000) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        // Test 6: Worst-case propagate chain, carry in at the MSB
        a = 4'b1111; b = 4'b0000; c_in = 1;  // forces full propagation, expect 16
        #200;
	if (s == 4'b0000) begin
    		$display("At time %t: Correct Result: Sum = %b, Cout = %b", $time, s, c_out);
	end

        $finish;
    end
endmodule
