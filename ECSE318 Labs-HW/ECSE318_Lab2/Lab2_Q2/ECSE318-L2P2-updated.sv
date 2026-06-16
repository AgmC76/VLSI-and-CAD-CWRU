module processor (
    input wire clk,
    input wire reset,
    output reg halt_flag
);

    parameter DATA_WIDTH = 32;
    parameter REG_COUNT = 16;
    parameter MEM_SIZE = 4096;
    
    // Opcodes from the screenshot table
    parameter NOP = 4'd0, LOAD = 4'd1, STORE = 4'd2, BRANCH = 4'd3;
    parameter XOR = 4'd4, ADD = 4'd5, ROTATE = 4'd6, SHIFT = 4'd7;
    parameter HALT = 4'd8, COMPLEMENT = 4'd9;
    
    // Processor registers
    reg [DATA_WIDTH-1:0] PC;
    reg [DATA_WIDTH-1:0] IR;
    reg [4:0] PSR;
    reg fetch_cycle;
    
    // Register file and memory
    reg [DATA_WIDTH-1:0] reg_file [0:REG_COUNT-1];
    reg [DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];
    
    // Instruction decode - opcode in low 4 bits
    wire [3:0] opcode = IR[3:0];
    wire src_type = IR[27];
    wire [2:0] condition_code = IR[6:4]; 
    wire [11:0] src_addr = IR[23:12];
    wire [11:0] dest_addr = IR[11:4]; // Adjusted to avoid overlap with opcode
    
    // Initialize
    initial begin
        PC = 0;
        IR = 0;
        PSR = 0;
        halt_flag = 0;
        fetch_cycle = 0;
        
        for (integer i = 0; i < REG_COUNT; i = i + 1) begin
            reg_file[i] = 0;
        end
        
        for (integer i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = 0;
        end
    end

    // PSR update 
    function [4:0] update_psr;
    input [DATA_WIDTH-1:0] result;
    input carry;
    reg [4:0] psr_value;
    begin
        psr_value[0] = carry;  // Carry
        psr_value[1] = ^result; // Parity (odd number of 1s)
        psr_value[2] = ~(^result); // Even (opposite of parity)
        psr_value[3] = result[DATA_WIDTH-1]; // Negative
        psr_value[4] = (result == 0); // Zero
        update_psr = psr_value;
    end
endfunction
    
    // Branch condition check
    function check_condition;
        input [2:0] cc;
	reg condition_met;
        begin
            case (cc)
                3'd0: check_condition = 1'b1;  // Always
                3'd1: check_condition = PSR[1]; // Parity
                3'd2: check_condition = PSR[2]; // Even
                3'd3: check_condition = PSR[0]; // Carry
                3'd4: check_condition = PSR[3]; // Negative
                3'd5: check_condition = PSR[4]; // Zero
                3'd6: check_condition = ~PSR[0]; // No carry
                3'd7: check_condition = ~PSR[3] & ~PSR[4]; // Positive (not negative and not zero)
                default: check_condition = 1'b0;
            endcase
	    check_condition = condition_met;
        end
    endfunction
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
            IR <= 0;
            PSR <= 0;
            halt_flag <= 0;
            fetch_cycle <= 0;
            
            for (integer i = 0; i < REG_COUNT; i = i + 1) begin
                reg_file[i] <= 0;
            end
        end
        else if (!halt_flag) begin
            if (fetch_cycle == 0) begin
                // FETCH CYCLE
                IR <= memory[PC];
                PC <= PC + 1;
                fetch_cycle <= 1;
                $display("FETCH: PC=%0d, fetching instruction %h", PC, memory[PC]);
            end
            else begin
                // EXECUTE CYCLE
                fetch_cycle <= 0;
                
                $display("EXECUTE: opcode=%0d, IR=%h", opcode, IR);
                
                case (opcode)
                    LOAD: begin  // 1
                        if (src_type == 0) begin
                            reg_file[dest_addr] <= memory[src_addr];
                            $display("LOAD: R%0d = MEM[%0d] = %0d", dest_addr, src_addr, memory[src_addr]);
                        end else begin
                            reg_file[dest_addr] <= src_addr;
                            $display("LOAD: R%0d = #%0d", dest_addr, src_addr);
                        end
			PSR <= update_psr(reg_file[dest_addr], PSR[0]);
                    end
                    
                    STORE: begin // 2
                        memory[dest_addr] <= reg_file[src_addr];
			PSR[0] <= 1'b0; // Clear carry for STORE
                        $display("STORE: MEM[%0d] = R%0d = %0d", dest_addr, src_addr, reg_file[src_addr]);
                    end
                    
                    ADD: begin // 3
                        if (src_type == 0) begin
                            {PSR[0], reg_file[dest_addr]} <= reg_file[dest_addr] + reg_file[src_addr];
			    $display("ADD: R%0d = R%0d + R%0d = %0d", dest_addr, dest_addr, src_addr, reg_file[dest_addr] + reg_file[src_addr]);
                        end else begin
                            {PSR[0], reg_file[dest_addr]} <= reg_file[dest_addr] + src_addr;
			    $display("ADD: R%0d = R%0d + #%0d = %0d", dest_addr, dest_addr, src_addr, reg_file[dest_addr] + src_addr);
                        end
                        PSR[4:1] <= update_psr(reg_file[dest_addr], PSR[0])[4:1];
                    end
                    
                    COMPLEMENT: begin // 4
                        reg_file[dest_addr] <= ~reg_file[src_addr];
			PSR <= update_psr(reg_file[dest_addr], PSR[0]);
                        $display("COMPLEMENT: R%0d = ~R%0d = %0d", dest_addr, src_addr, ~reg_file[src_addr]);
                    end
                    
                    HALT: begin // 5
                        halt_flag <= 1;
                        $display("HALT executed");
                    end
		
		    BRANCH: begin // 6
                        if (check_condition(condition_code)) begin
                            PC <= src_addr;
                        end
                    end

		    XOR: begin // 7
                        if (src_type == 0) begin
                            reg_file[dest_addr] <= reg_file[dest_addr] ^ reg_file[src_addr];
                        end else begin
                            reg_file[dest_addr] <= reg_file[dest_addr] ^ src_addr;
                        end
                        PSR <= update_psr(reg_file[dest_addr], PSR[0]);
                    end

		    ROTATE: begin // 8
                        // Simple rotate right by count
                        if ($signed(src_addr) > 0) begin
                            reg_file[dest_addr] <= (reg_file[dest_addr] >> src_addr) | (reg_file[dest_addr] << (DATA_WIDTH - src_addr));
                        end else begin
                            reg_file[dest_addr] <= (reg_file[dest_addr] << (-src_addr)) | (reg_file[dest_addr] >> (DATA_WIDTH + src_addr));
                        end
                        PSR <= update_psr(reg_file[dest_addr], PSR[0]);
                    end

		    SHIFT: begin // 9
                        // Arithmetic shift
                        if ($signed(src_addr) > 0) begin
                            reg_file[dest_addr] <= $signed(reg_file[dest_addr]) >>> src_addr;
                        end else begin
                            reg_file[dest_addr] <= reg_file[dest_addr] << (-src_addr);
                        end
                        PSR <= update_psr(reg_file[dest_addr], PSR[0]);
                    end
                    
                    default: begin // nop 10
                        $display("Unknown instruction: opcode=%0d, IR=%h", opcode, IR);
                    end
                endcase
            end
        end
    end
    
endmodule