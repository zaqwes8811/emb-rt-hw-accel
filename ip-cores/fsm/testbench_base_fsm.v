//`timescale 1 ns / 100 ps
`timescale 10ns / 1ns

`define WIDTH 8

module sum_tb;

wire sclk_n;
wire cs_n;
reg rst_a;
reg from_device;

// stimuls
reg clk;

initial begin
	clk = 0;
	rst_a = 0;
	from_device = 0;
	#10 rst_a = 1;
	#10 rst_a = 0;
end

always
	#10 clk = ~clk;

// $stop or $finish
always @( posedge clk ) begin
	from_device <= $random;  // можно просто генерить биты
	// а там как попадет
end
	
splitter s0( 
	.clk( clk ), .rst_a( rst_a ), .ena( 1'b1 ), 
	.sclk_n(sclk_n), .cs_n( cs_n ), 
	.from_device(from_device) );

endmodule