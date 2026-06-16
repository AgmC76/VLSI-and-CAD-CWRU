module RxFIFO (
	input PSEL, PWRITE, PCLK, CLEAR_B, 
	input [7:0] RXDATA,
	output [7:0] PRDATA,
	output SSPRXINTR
);

/*
 * 4 spots for 8 bit data, shift out one 8 bit word at a time
 * First in, first out 
 */ 
//parameter DATA_WIDTH = 8 // for 8 bit data, 8-1 = 7:0 
//parameter DEPTH = 4 // for a depth of 4, 4-1 = 3:0

reg [7:0] RxMem [0:3]; // 8 bit register with depth of 4
reg [4:0] readPtr; // Should check, but pointer size should exceed depth
reg [4:0] writePtr;
//reg emtpy; // 1 if empty
reg full;  // 1 if full, all slots of FIFO have data

/*
 * deriving the output: TXDATA
 * transmit control logic
 * 
 * transmit conditions:
 * CLEAR_B = 0
 * PSEL = 1, (only if needing to transfer in new PWDATA, internal data can still be processed)
 * SSPTXINTR = HIGH when the FIFO is full and should not accept more data from PWDATA
 * 
 * 
 */


// running the fifo:

/* 
 * Write procedure
 * in a queue (or FIFO), this is like pushing the data
 * data moves down the stream until it is in the last position 
 * where it is read (popped)
 */

// add in conditions for clear_B to be asserted for all always @ blocks - done
	always @(posedge PCLK or negedge CLEAR_B) begin
		// for resetting/clearing the FIFO
		if (!CLEAR_B) begin
			writePtr <= 0; // reset the pointer
			//empty <= 1; // assert true, shows that the pointer is empty, SSPTXINTR only shows full, not empty
		end else if (PSEL && !full) begin // new data can be written and the FIFO is NOT full
			writePtr <= writePtr + 1; // increment the pointer
		end
	end

/*
 * Read procedure
 * For a FIFO, this is the same as popping data 
 * conducted by the transmit logic, not the RxFIFO
 * data that is first out is popped and read
 */

	always @(posedge PCLK or negedge CLEAR_B) begin
		if (!CLEAR_B) begin
			readPtr <= 0;
			full <= 0; // the FIFO is not full upon resetting
		end else if (PSEL && (writePtr == readPtr)) begin// the write pointer has reached the end, the FIFO is full
			// could also use SSPTXINTR
			full <= 1; 
		end else if (PSEL && !full) begin// movement enabled and not full --> keep incrementing
			full <= 0;
			readPtr <= readPtr + 1; 
		end
	end 
		
/*
 * data assignment
 * For actually adding the data into the correct locations of the FIFO
 */

	always @(posedge PCLK or negedge CLEAR_B) begin
		if (!CLEAR_B) begin
			RxMem[0] <= 8'bz; // clear the data values
			RxMem[1] <= 8'bz; //L82
			RxMem[2] <= 8'bz; 
			RxMem[3] <= 8'bz;
		end else if (PSEL && !full) begin// movement allowed, and the register is not full, can push/pop to FIFO
			RxMem[writePtr] <= RXDATA; // incrementing the pointer mimics shifting 
		end
	end

/*
 * definging the output data 
 * TxDATA
 */
	assign PRDATA = RxMem[readPtr];

/*
 * outputs for the SP status
 */
	assign SSPRXINTR = full; // high if full

endmodule