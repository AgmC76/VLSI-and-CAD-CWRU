module test_problem4;
    reg clk, reset;
    wire halt_flag;
    
    processor uut (.clk(clk), .reset(reset), .halt_flag(halt_flag));
    
    initial begin
        clk = 0;
        reset = 1;
        
        // Initialize test values (A=14, B=3)
        uut.memory[0] = 32'd14;  // Dividend
        uut.memory[1] = 32'd3;   // Divisor
        
        #10 reset = 0;
        
        // Division program
        uut.memory[2] = {4'd1, 1'b0, 1'b0, 10'd0, 12'd0, 12'd1};  // LD R1, MEM[0] (A)
        uut.memory[3] = {4'd1, 1'b0, 1'b0, 10'd0, 12'd1, 12'd2};  // LD R2, MEM[1] (B)
        uut.memory[4] = {4'd1, 1'b1, 1'b0, 10'd0, 12'd0, 12'd3};  // LD R3, #0 (Q)
        uut.memory[5] = {4'd1, 1'b0, 1'b0, 10'd0, 12'd0, 12'd4};  // LD R4, R1 (R)
        
        // Division loop
        uut.memory[6] = {4'd5, 1'b0, 1'b0, 10'd0, 12'd2, 12'd5};  // SUB R5, R4, R2 (R - B)
        uut.memory[7] = {4'd3, 1'b4, 1'b0, 10'd0, 12'd4, 12'd0};  // BRA +4 if negative (done)
        uut.memory[8] = {4'd1, 1'b0, 1'b0, 10'd0, 12'd5, 12'd4};  // LD R4, R5 (R = R - B)
        uut.memory[9] = {4'd1, 1'b1, 1'b0, 10'd0, 12'd1, 12'd3};  // LD R3, R3 + 1 (Q++)
        uut.memory[10] = {4'd3, 1'b0, 1'b0, 10'd0, 12'd6, 12'd0}; // BRA -6 (always, back to loop)
        
        // Store results
        uut.memory[11] = {4'd2, 1'b0, 1'b0, 10'd0, 12'd3, 12'd2}; // STR MEM[2], R3 (Q)
        uut.memory[12] = {4'd2, 1'b0, 1'b0, 10'd0, 12'd4, 12'd3}; // STR MEM[3], R4 (R)
        uut.memory[13] = {4'd8, 1'b0, 1'b0, 10'd0, 12'd0, 12'd0}; // HALT
        
        #500 $display("Q = MEM[2] = %d, R = MEM[3] = %d", uut.memory[2], uut.memory[3]);
        $display("14 / 3 = 4 rem 2");
        $finish;
    end
    
    always #5 clk = ~clk;
endmodule