`timescale 1ns/1ps
`default_nettype none
module test;

// $dump*
// http://www.referencedesigner.com/tutorials/verilog/verilog_62.php


// Outputs to DUT (DUT inputs)
reg clk = 0;
reg reset = 0;
// Inputs from DUT (DUT outputs)
reg [7:0] tick;
reg [7:0] addr;
reg [7:0] rd_addr;
reg [7:0] wr_addr;
reg [7:0] q;
wire [7:0] rd_q;

wire [7:0] dest = 4;
wire [7:0] src = 0;
wire [7:0] num = 8;

reg oe;
reg we;

ram_sp_sr_sv dut(clk, addr, q, rd_q, we, oe);

always #1 clk=~clk;

initial
begin
	tick = 0;
	we = 0;
	oe = 0;
	rd_addr = 0;
	wr_addr = 0;
	q = 0;
end

always @(posedge clk) begin
	tick <= tick + 1; 
	wr_addr <= tick;
	q <= $random;
end

always @(posedge clk) begin
	if (tick == 0)
		we <= 1;
	else if (tick == 4)
		we <= 0;
end
always @(posedge clk)
	if (tick == 4)
		oe <= 1;
	else if (tick == 8)
		oe <= 0;

always @(posedge clk)
	if (oe)
		rd_addr <= rd_addr + 1;
	else if(we)
		rd_addr <= 0;

always @(*) begin
	addr = wr_addr;
	if( oe && !we )
		addr = rd_addr;	
end

//===========================================
// connect to memcopy

endmodule