module TxRx_Logic (
	input PCLK, CLEAR_B, SSPCLKIN, SSPFSSIN, SSPRXD,
	input reset, load, enable, // inputs for the shift registers, may need to split for PISO and SIPO
	input [7:0] TxData, // 8 bit word input
	output SSPOE_B, SSPTXD, SSPFSSOUT, SSPCLKOUT,
	output [7:0] RxData
);


// SSPCLKOUT should be twice as slow as PCLK
reg ssp_clk;
	always @(posedge PCLK or negedge CLEAR_B) begin
		if (CLEAR_B) begin
			ssp_clk <= 1'b0;
		end else begin
			ssp_clk <= ~ssp_clk; // divides by 2
		end
	end

assign SSPCLKOUT = ssp_clk;

// Temporary, for the frame control of the transmit
reg [2:0] tx_bit_count;
reg transmitting;
reg load_piso;

// for rx frame control
reg [2:0] rx_bit_count;
reg receiving;

reg sspoe_active;

/*
 * Transmit logic
 * Parallel to serial conversion
 */
PSReg transmit_reg(
	.clk(SSPCLKOUT), // check the clocks
	.reset(reset),
	.enable(enable),
	.load(load),
	.parallel_in(TxData),
	.serial_out(SSPTXD)
);


/*
 * Receive Logic
 * Serial to parallel conversion
 */
SPReg receive_reg(
	.clk(SSCLKOUT), // check the clocks so that they are synched properly
	.reset(reset),
	.load(load),
	.serial_in(SSPRXD),
	.parallel_out(RxData)
);


/*
 * Frame control signals
 * SSPFSSOUT
 * SSPFSSIN
 * theres more i'll add them in here
 */

// SSPFSSOUT
//	always @(posedge SSPCLKOUT or negedge CLEAR_B) begin
//    		if (!CLEAR_B) begin
//        		SSPFSSOUT <= 1'b0;
//        		transmitting <= 1'b0;
//        		tx_bit_count <= 3'b0;
//        		load_piso <= 1'b0;
//    		end else begin
//      
//        		SSPFSSOUT <= 1'b0;
//        		load_piso <= 1'b0;
//        
//        		if (!enable && !transmitting) begin
//
//            			SSPFSSOUT <= 1'b1;       
//            			load_piso <= 1'b1;       
//            			transmitting <= 1'b1;  
//            			tx_bit_count <= 3'b0;    
//        		end else if (transmitting) begin
//            			// Continue transmission
//            			if (SSPCLKOUT && tx_bit_count < 3'b111) begin
//                			tx_bit_count <= tx_bit_count + 1;  // Count bits
//            			end else if (tx_bit_count == 3'b111) begin
//                			// Transmission complete
//                			transmitting <= 1'b0;
//            			end
//        		end
//    		end
//	end

// SSPFSSIN
	always @(posedge PCLK or negedge CLEAR_B) begin
    		if (!CLEAR_B) begin
        		receiving <= 1'b0;
        		rx_bit_count <= 3'b0;
        		//rx_write_enable <= 1'b0;
    		end else begin

        		//rx_write_enable <= 1'b0;
        
        		// detect frame start (SSPFSSIN rising edge)
        		if (SSPFSSIN && !receiving) begin // fix this
            			receiving <= 1'b1;        // initiate receiving
            			rx_bit_count <= 3'b0;     // Reset bit counter
        		end else if (receiving) begin
            		// should shift in data on each SSPCLKIN
            			if (SSPCLKIN) begin
                			if (rx_bit_count < 3'b111) begin
                    			rx_bit_count <= rx_bit_count + 1;
                			end else begin
                    				// have receieved the whole byte here
                    				//rx_write_enable <= 1'b1;  // Write to RxFIFO
                    				receiving <= 1'b0;        // finished receiving
                			end
            			end
        		end
    		end
	end

/*
 * SSPOE_B
 * couldn't fix properly need to check and uncomment
 */
//
//	always @(negedge SSPCLKOUT or negedge CLEAR_B) begin // uses the negedge check again
//    		if (!CLEAR_B) begin
//        		sspoe_active <= 1'b0;
//        		SSPOE_B <= 1'b1;  // Inactive high by default
//    		end else begin
//        		if (transmitting && tx_bit_count == 3'b000) begin
//            			sspoe_active <= 1'b1;  // Start output enable
//        		end else if (transmitting && tx_bit_count == 3'b111) begin
//            			sspoe_active <= 1'b0;  // End output enable
//        		end
//        
//        		SSPOE_B <= !sspoe_active;  // Active low
//    		end
//	end



endmodule