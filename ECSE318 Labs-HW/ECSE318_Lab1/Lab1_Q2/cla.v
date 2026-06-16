// ECSE 318 Lab 1 - Problem 2
// 4-bit CLA with 10ns gate delays

`timescale 1ns/10ps

module cla_adder (
    input  [3:0] a, b,
    input        c_in,
    output [3:0] s,
    output       c_out
);

    wire [3:0] p, g;  // propagate, generate
    wire [4:0] c;     // carries

    assign c[0] = c_in;


    // Propagate (pi = ai ? bi)
    // Generate  (gi = ai · bi)
    xor #10 px0 (p[0], a[0], b[0]);
    xor #10 px1 (p[1], a[1], b[1]);
    xor #10 px2 (p[2], a[2], b[2]);
    xor #10 px3 (p[3], a[3], b[3]);

    and #10 gx0 (g[0], a[0], b[0]);
    and #10 gx1 (g[1], a[1], b[1]);
    and #10 gx2 (g[2], a[2], b[2]);
    and #10 gx3 (g[3], a[3], b[3]);


    // Carry Lookahead Equations
    // Ci = gi + (pi · Ci-1) + ... --> lab instructions
    assign #10 c[1] = g[0] | (p[0] & c[0]);

    assign #10 c[2] = g[1]
                    | (p[1] & g[0])
                    | (p[1] & p[0] & c[0]);

    assign #10 c[3] = g[2]
                    | (p[2] & g[1])
                    | (p[2] & p[1] & g[0])
                    | (p[2] & p[1] & p[0] & c[0]);

    assign #10 c[4] = g[3]
                    | (p[3] & g[2])
                    | (p[3] & p[2] & g[1])
                    | (p[3] & p[2] & p[1] & g[0])
                    | (p[3] & p[2] & p[1] & p[0] & c[0]);


    // Sum bits (Si = pi ? Ci)
    xor #10 sx0 (s[0], p[0], c[0]);
    xor #10 sx1 (s[1], p[1], c[1]);
    xor #10 sx2 (s[2], p[2], c[2]);
    xor #10 sx3 (s[3], p[3], c[3]);

    // Final carry out
    assign c_out = c[4];

endmodule
