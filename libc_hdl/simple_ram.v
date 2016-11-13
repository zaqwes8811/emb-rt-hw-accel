// How do better:
// http://stackoverflow.com/questions/7630797/better-way-of-coding-a-ram-in-verilog

`define _ADDR_WITH 8


module ram_sp_sr_sv(
	clk,
	addr,
	q,
	rd_q,
	we,
	oe);

parameter DATA_WITH = 8;
parameter ADDR_WITH = 8;
parameter RAW_DEPTH = 1 << ADDR_WITH;

input clk;
input [ADDR_WITH-1:0] addr;
input we, oe;

// //
input [DATA_WITH-1:0] q;
output reg [DATA_WITH-1:0] rd_q;

//
reg [DATA_WITH-1:0] ram [0:RAW_DEPTH-1]; // change order

parameter MEM_INIT_FILE = "ddr.mif";

initial begin
  if (MEM_INIT_FILE != "") begin
    $readmemh(MEM_INIT_FILE, ram);
  end
end

// почему пишет сразу? похоже не сразу а по заднему фронту данных
always @(posedge clk)
	if ( we )
		ram[addr] <= q;  // => ?

always @(posedge clk)
	if (!we && oe)
		rd_q <= ram[addr];  // => ?
	else 
		rd_q <= 8'bz;

endmodule

//=======================================
// void *memcpy(void *dest, const void *src, int num);
// return ptr to dest

module memcpy(
	input clk,
	//input clear,  // ???
	input [`_ADDR_WITH-1:0] dest,
	input [`_ADDR_WITH-1:0] src,
	input [8-1:0] num,
	input mmcpy_ena,

	// fixme: похоже нужен импльс старта

	// how connect memory
	output mmcpy_rd_ena,
	output mmcpy_wr_ena,
	output [7:0] addr


	// result
	// output error,
	// output done
	);

assign mmcpy_wr_ena = 1;
assign mmcpy_rd_ena = 0;
assign addr = dest;

//reg [7:0] addr_ptr;

always @(*) begin
	//addr_ptr = 0;

end

endmodule

