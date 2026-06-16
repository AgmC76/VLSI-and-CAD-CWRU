module ssp(
// top level module containing the TX/RX FIFOs as well as the TXRX logic
	input PCLK, CLEAR_B, PSEL, PWRITE,
	input SSPCLKIN, SSPFSSIN, SSPRXD,
	input [7:0] PWDATA, 
	output SSPOE_B, SSPTXD, SSPCLKOUT, SSPTXINTR, SSPRXINTR, SSPFSSOUT,
	output [7:0] PRDATA
);

// internal signals

// submodules


TxFIFO txfifo_sub(
	.PSEL(PSEL),
	.PWRITE(PWRITE),
	.CLEAR_B(CLEAR_B),
	.PCLK(PCLK),
	.PWDATA(PWDATA),
	.TXDATA(),
	.SSPTXINTR(SSPTXINTR)
);


RxFIFO rxfifo_sub(
	.PSEL(PSEL),
	.PWRITE(PWRITE),
	.CLEAR_B(CLEAR_B),
	.PCLK(PCLK),
	.RXDATA(),
	.PRDATA(PRDATA),
	.SSPRXINTR(SSPRXINTR)
);


TxRx_Logic logic1(
	.PCLK(PCLK),
	.CLEAR_B(CLEAR_B),
	.SSPCLKIN(SSPCLKIN),
	.SSPFSSIN(SSPFSSIN),
	.SSPRXD(SSPRXD),
	.reset(),//
	.load(),//
	.enable(),//
	.TxData(), // received from the tx fifo
	.SSPOE_B(SSPOE_B),
	.SSPTXD(SSPTXD),
	.SSPFSSOUT(SSPFSSOUT),
	.SSPCLKOUT(SSPCLKOUT),
	.RxData()
);

endmodule
