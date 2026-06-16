module handshake_checker (
    input clk,
    input reset,
    input R,      // Request
    input A,      // Acknowledge  
    output reg E  // Error
);

    // State definitions
    parameter [1:0] S0 = 2'b00,    // idle state: R=0, A=0
                    S1 = 2'b01,    // request: R=1, A=0
                    S2 = 2'b10,    // acknowledge request: R=1, A=1
                    S3 = 2'b11,    // release: R=0, A=1
                    ERROR = 2'bxx; // error state

    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin // defines the reset, if 1, then always goes to S0 and E = 0
            current_state <= S0;
            E <= 1'b0;
        end else begin
            current_state <= next_state;
            
            // Output logic - error is 1 only in error state
            E <= (next_state === ERROR) ? 1'b1 : 1'b0;
        end
    end

    // Next state
    always @(*) begin
        case (current_state)
            S0: begin // idle: R=0, A=0
                case ({R, A})
                    2'b00: next_state = S0;    // Stay in idle
                    2'b01: next_state = ERROR; // A before R = error
                    2'b10: next_state = S1;    // R rises - valid
                    2'b11: next_state = ERROR; // Both high from idle = error
                    default: next_state = ERROR;
                endcase
            end
            
            S1: begin // request: R=1, A=0
                case ({R, A})
                    2'b00: next_state = ERROR; // R drops before A = error
                    2'b01: next_state = ERROR; // A rises but R=0? Shouldn't happen
                    2'b10: next_state = S1;    // Stay waiting for A
                    2'b11: next_state = S2;    // A rises - valid acknowledge
                    default: next_state = ERROR;
                endcase
            end
            
            S2: begin // acknowledge: R=1, A=1
                case ({R, A})
                    2'b00: next_state = ERROR; // Both drop = error
                    2'b01: next_state = ERROR; // R drops but A stays = error
                    2'b10: next_state = ERROR; // A drops but R stays = error
                    2'b11: next_state = S3;    // R drops - valid release
                    default: next_state = ERROR;
                endcase
            end
            
            S3: begin // release: R=0, A=1
                case ({R, A})
                    2'b00: next_state = ERROR; // A drops but sequence wrong
                    2'b01: next_state = S0;    // A drops - valid completion
                    2'b10: next_state = ERROR; // R rises before A drops - ERROR!
                    2'b11: next_state = S3;    // Stay in release
                    default: next_state = ERROR;
                endcase
            end
            
            ERROR: begin
                next_state = ERROR; // Stay in error state until reset
            end
            
            default: begin
                next_state = ERROR;
            end
        endcase
    end

endmodule
