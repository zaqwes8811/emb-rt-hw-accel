// How do better:
// http://stackoverflow.com/questions/7630797/better-way-of-coding-a-ram-in-verilog

`define _ADDR_WITH 8


module ram_sp_sr_sv(
	clk,
	addr,
	q,
	rd_q,
	we,
	oe
	);

parameter DATA_WITH = 8;
parameter ADDR_WITH = 8;
parameter RAW_DEPTH = 1 << ADDR_WITH;

input clk;
input [ADDR_WITH-1:0] addr;
input we, oe;

//
input [DATA_WITH-1:0] q;
output reg [DATA_WITH-1:0] rd_q;

//
reg [DATA_WITH-1:0] mem [0:RAW_DEPTH-1]; // change order

// почему пишет сразу? похоже не сразу а по заднему фронту данных
always @(posedge clk)
	if ( we )
		mem[addr] <= q;  // => ?

always @(posedge clk)
	if (!we && oe)
		rd_q <= mem[addr];  // => ?
	else 
		rd_q <= 8'bz;

endmodule

//=======================================
// void *memcpy(void *dest, const void *src, int num);
// return ptr to dest

module memcpy(
	input clk,
	input [`_ADDR_WITH-1:0] dest,
	input [`_ADDR_WITH-1:0] src,
	input [8-1:0] num,

	// how connect memory

	// result
	output error
	);

endmodule

