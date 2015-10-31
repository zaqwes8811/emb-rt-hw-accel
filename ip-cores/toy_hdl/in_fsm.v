module in_fsm(
	clk,
	rst_a,
	ena,

	// control signals
	ready,

	// data
	src,
	snk  // snk
);

input clk;
input rst_a;
input [7:0] src;

output snk;

// fixme: можно же память заюзать? но нужно подумать,т.к. она будет одна(?)

// descriptor
// 1. узнаваемый заголовок
// 2. длина
// fixme: как проверить контрольную сумму

// about fsm:
//   http://www.asic-world.com/verilog/memory_fsm3.html
//   http://web.mit.edu/6.111/www/f2012/handouts/L05.pdf
// fixme: split logic!
// http://www.sunburst-design.com/papers/CummingsICU2002_FSMFundamentals.pdf

// data queue

endmodule;

//
//
// Test
//
//

module in_fsm_testbench;
reg clk, rst_a;
wire o_event;
reg [7:0] source;

initial begin
	clk = 0;
	rst_a = 0;
	source = 0;
end

always begin
	#5 clk = !clk;
end

// fixme: нужно сгенерировать более менее внятный поток
always @(posedge clk) begin
	source <= source + 1;
end

in_fsm U0 (
	.clk(clk),
	.rst_a(rst_a),
	.src(source),
	.snk(o_event)
);

endmodule;