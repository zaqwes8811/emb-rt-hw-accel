
// Аналог char buffer[N]
//
// fixme: how infere memory
//   http://quartushelp.altera.com/13.1/mergedProjects/hdl/vlog/vlog_pro_ram_inferred.htm
//
// fixme: стоит ли занимать целую ячейку памяти?
//
// fixme: интересно, а синтезируется ли?

// memory map
`define START_ADDR 0
`define MAX_ADDR 7

module my_avalon_mm(
	clk,

	// M->S
	// read,
	write,
	address,  // fixme: как разделить чтение и запись
	writedata,

	// S->M
	readdata
	);

input clk, write;
input [`MAX_ADDR-1:0] address;
input [7:0] writedata;

output reg [7:0] readdata;
 
reg [7:0] mem [127:0];

always @(posedge clk) begin
	if (write)
	    mem[address] <= writedata;
	// fixme: else?

	readdata <= mem[address];
end

endmodule

//
//
// Templ
//
//

module ram_single(q, a, d, we, clk);
	output reg [7:0] q;
	input [7:0] d;
	input [6:0] a;
	input we, clk;
	reg [7:0] mem [127:0];
	always @(posedge clk) begin
		if (we)
		    mem[a] <= d;
		q <= mem[a];
	end
endmodule