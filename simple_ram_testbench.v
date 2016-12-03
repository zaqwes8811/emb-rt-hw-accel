// trick: сперва писать в тестбенче, а потом выделить модуль
// vlog *.v; vsim -t ns work.test; do waves.do

`timescale 10ns/1ps
//`default_nettype none


//============== Memories ===============================

// fixme: можно добавить параметры в args
// #(
// 	//Parameterized values
// 	parameter Q = 15,
// 	parameter N = 32
// 	)
module Mats(
	clk, addr, q, rd_q,	we,	oe);

parameter ADDR_WITH = 8;
parameter RAW_DEPTH = 1 << ADDR_WITH;

input clk;
input [ADDR_WITH-1:0] addr;
input we, oe;

// //
input [8-1:0] q;
output reg [8-1:0] rd_q;

//
reg [8-1:0] ram [0:RAW_DEPTH-1]; // change order

parameter MEM_INIT_FILE = "src.mif";

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


//=====================================================

module test;

`define DELAY_SIZE 4  // fixme: -1?? сколько триггеров?

// $dump*
// http://www.referencedesigner.com/tutorials/verilog/verilog_62.php

// reg clk = 0;
// reg [7:0] tick;
// reg [7:0] q;
// reg [7:0] q0;

// // Vars
// wire [7:0] store_time = 5;
// // Mats
// // fixme: image shape - cols, rows
// reg [7:0] src [0 : (1 << 8) - 1];
// reg [7:0] dst [0 : (1 << 8) - 1];
// reg [7:0] src_addr;
// reg [7:0] dst_addr;
// reg data_valid;
// reg [7:0] tapped_line0[`DELAY_SIZE-1:0];
// reg [8:0] sum;  // fixme: signed?

// //=======================================================

// always #1 clk=~clk;

// initial
// begin
// 	tick = 0;
// 	q = 0;
// 	$readmemh("src.mif", src);
// 	src_addr = 0;
// 	dst_addr = 0;
// 	data_valid = 0;
// end

// //=======================================================

// always @(posedge clk) begin
// 	// fixme: как быть с переполнениями?
// 	tick <= tick + 1; 
// 	// q <= $random;
// 	data_valid <= 1;
	
// 	if (data_valid)
// 		dst_addr <= dst_addr + 1;
// end

// always @(posedge clk) begin
// 	if (data_valid)
// 		dst[dst_addr] <= q;  

// 	q0 <= src[src_addr];
// end

// always @ (posedge clk) begin
// 	if (dst_addr == store_time) begin
// 		$writememh("dst.mif",dst);
// 	end
// end

// always @(*) begin
// 	// dst_addr = tick;
// 	src_addr = tick;
// 	q = tapped_line0[`DELAY_SIZE-1];
// 	//q0 = 

// 	tapped_line0[0] = q0;
// end

// //=====================================================

// // Gotchas:
// //http://www.sutherland-hdl.com/papers/2007-SNUG-SanJose_gotcha_again_presentation.pdf
// integer i;
// always @ (posedge clk) begin
// 	for(i = 1; i < `DELAY_SIZE; i = i+1)
// 		tapped_line0[i] <= tapped_line0[i-1];
// end

// integer j;
// integer tmp;
// always @(*) begin
// 	// for(j = 0; j < 3; j = j + 1) begin
// 	// 	tmp = tmp + tapped_line0[j];
// 	// end
// 	sum = tapped_line0[0] + tapped_line0[1] + tapped_line0[2];
// end

endmodule




