module handshake_checker_behavioral (
    input clk,
    input reset,
    input R, A,
    output reg E
);
// remember to update testbench to use with this model

    reg R_prev, A_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            R_prev <= 0;
            A_prev <= 0;
            E <= 0;
        end else begin
            R_prev <= R;
            A_prev <= A;
            
            // just going to see if detecting all invalid transitions and setting the error works
            if ((A && !A_prev && !R) ||        // A rises without R
                (!R && R_prev && !A) ||        // R falls before A rises  
                (!A && A_prev && R) ||         // A falls while R high
                (R && !R_prev && A)) begin     // R rises while A high
                E <= 1;
            end
            // Note: Error remains latched until reset
        end
    end

endmodule
