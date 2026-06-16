module tb_handshake_checker;
    reg clk, reset, R, A;
    wire E;
    
    // Instantiate the handshake checker
    handshake_checker uut (
        .clk(clk),
        .reset(reset),
        .R(R),
        .A(A),
        .E(E)
    );
    
    // Clock generation
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end
    
    // Test sequence
    initial begin
        $monitor("Time=%0t: R=%b, A=%b, E=%b", $time, R, A, E);
        
        // Initialize
        reset = 1; R = 0; A = 0;
        #20;
        reset = 0;
        
        // Test 1: Valid handshake sequence
        $display("=== Test 1: Valid handshake ===");
        #10; R = 1;  // Request
        #20; A = 1;  // Acknowledge  
        #20; R = 0;  // Release request
        #20; A = 0;  // Release acknowledge
        #20;
        
        // Test 2: Error - A before R
        $display("=== Test 2: Error - A before R ===");
        #10; A = 1;  // ERROR: A before R!
        #20; R = 1;  // Try to recover (should stay in error)
        #20; A = 0;
        #20; R = 0;
        #20;
        
        // Reset to clear error
        reset = 1;
        #20;
        reset = 0;
        
        // Test 3: Error - R drops before A
        $display("=== Test 3: Error - R drops before A ===");
        #10; R = 1;
        #20; R = 0;  // ERROR: R drops before A rises!
        #20; A = 1;
        #20;
        
        // Reset to clear error
        reset = 1;
        #20;
        reset = 0;
        
        // Test 4: Error - A drops before R in acknowledge phase
        $display("=== Test 4: Error - A drops before R ===");
        #10; R = 1;
        #20; A = 1;
        #20; A = 0;  // ERROR: A drops before R!
        #20; R = 0;
        #20;
        
        $display("=== Simulation Complete ===");
        $finish;
    end
    
endmodule
