//`timescale 1 ns / 100 ps
`timescale 10ns / 1ns

`define WIDTH 8

module sum_tb;

wire sclk_n;
wire cs_n;
reg rst_a;

// stimuls
reg clk;

// adder_signed addsig(
// .a(a), .b(b), 
// .c(c));
// logic
initial begin
	clk = 0;
	rst_a = 0;
	#10 rst_a = 1;
	#10 rst_a = 0;
end

always
	#10 clk = ~clk;

// $stop or $finish

splitter s0( 
	.clk( clk ), .rst_a( rst_a ), .ena( 1'b1 ), 
	.sclk_n(sclk_n), .cs_n( cs_n ) );

endmodule