//`timescale 1 ns / 100 ps
`timescale 10ns / 1ns

`include "const.v"

module sum_tb;

wire sclk_n;
wire cs_n;
reg start;
reg from_device;
wire just_test;
wire [7:0] just_test_bus;

wire [`W-1:0] clk_scaler;

// stimuls
reg clk;

// fixme: пока просто по модулю 8 
assign clk_scaler = 6;//`DIV_MAX - 1;

initial begin
	clk = 0;
	// rst = 0;
	from_device = 0;
	// #10 rst = 1;
	// #10 rst = 0;

// fixme: понять и возможно переделать
// http://www.sunburst-design.com/papers/CummingsSNUG2003Boston_Resets.pdf
// !!!
	start <= 1; // time 0 nonblocking assignment
 	@(posedge clk); // Wait to get past time 0
 	@(negedge clk) start = 0; // rst_n low for one clock cycle

end

always
	#10 clk = ~clk;

// $stop or $finish
always @( posedge clk ) begin
	from_device <= $random;  // можно просто генерить биты
	// а там как попадет
end


base_fsm s0( 
	.clk( clk ), .start( start ), .clk_scaler( clk_scaler ), 
	.sclk_n(sclk_n), .cs_n( cs_n ), 
	.from_device(from_device), .just_test( just_test ),
	.just_test_bus( just_test_bus ) );

endmodule