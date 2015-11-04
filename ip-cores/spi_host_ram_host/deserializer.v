// fixme: clock gating - возможно делить частоту через ena плохо
//
// http://electronics.stackexchange.com/questions/73398/gated-clocks-and-clock-enables-in-fpga-and-asics
//
//
// learn
//

// fixme: syn 4 tgrs - why?
// https://www.altera.com/support/support-resources/design-examples/design-software/verilog/ver-state-machine.html

// Design:
//   1. принимаем пакет с заголовком и контрольной суммой через SPI
//   прерывание это не очень хорошая идея, хотя... 
//   в SPI линия все равно не входит

module in_fsm (
output reg gnt,
input dly, done, req, clk, rst_n);

// fixme: it's make hot?
parameter [1:0] IDLE = 2'b00,
				BBUSY = 2'b01,
				BWAIT = 2'b10,
				BFREE = 2'b11;

reg [1:0] state;
reg [1:0] next;  // fixme: во что синтезируется?

always @(posedge clk
	//or posedge rst_n
	) begin
	// always <= !!!
	//if (!rst_n) 
	// if (rst_n) 
	// 	state <= IDLE;
	// else 
		state <= next;
end

// "For combinational blocks 
//	(blocks that contain no registers or latches)"
// "the sensitivity list must include every 
//  signal that is !!!read by the process."
always @(state or dly or done or req) begin
	// intitialize outputs to avoid latches?
	next = 2'bx;
	gnt = 1'b0;

	case (state)
		IDLE: 
			if (req)
				next = BBUSY;
			else
				next = IDLE;
		BBUSY: begin
			gnt = 1'b1;
			if (!done)
				next = BBUSY;
			else begin
				if ( dly )
					next = BWAIT;
				else
					next = BFREE;
			end
		end
		BWAIT: begin
			gnt = 1'b1;
			if (!dly)
				next = BFREE;
			else begin
				next = BWAIT;
			end
		end
		BFREE: 
			if ( req )
				next = BBUSY;
			else 
				next = IDLE;
	endcase
end

endmodule

// bad
//always @(a)
	//c <= a or b;  // no in sensitive list
	
module in_fsm_(
	clk,
	rst_a,
	ena,

	// control signals
	ready,

	// data
	src,
	snk  // snk
);

`define BUS_SIZE 8

input clk;
input rst_a;
input ena;
output ready;
input [`BUS_SIZE-1:0] src;

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

endmodule

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

in_fsm_ U0 (
	.clk(clk),
	.rst_a(rst_a),
	.src(source),
	.snk(o_event)
);

endmodule

