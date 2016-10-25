`timescale 1ns/1ps
`default_nettype none
module test;

// $dump*
// http://www.referencedesigner.com/tutorials/verilog/verilog_62.php


// Outputs to DUT (DUT inputs)
reg clk = 0;
// Inputs from DUT (DUT outputs)
reg [7:0] tick;


// Mem interface
reg [7:0] gaddr;
reg grd_ena;
reg gwr_ena;
reg [7:0] q;
wire [7:0] rd_q;

// Util
reg uwr_ena;
reg urd_ena;
reg [7:0] urd_addr;
reg [7:0] uwr_addr;

// memcopy
reg mmcpy_ena;
wire [7:0] dest = 4;
wire [7:0] src = 0;
wire [7:0] num = 8;
wire mmcpy_rd_ena;
wire mmcpy_wr_ena;
wire [7:0] mmcpy_addr;


// Instances
ram_sp_sr_sv dut(clk, gaddr, q, rd_q, gwr_ena, grd_ena);
memcpy mc(
	clk, 
	dest, src, num, mmcpy_ena,
	mmcpy_rd_ena, mmcpy_wr_ena, mmcpy_addr
);

//=======================================================

always #1 clk=~clk;

initial
begin
	uwr_ena = 0;
	tick = 0;
	gwr_ena = 0;
	grd_ena = 0;

	urd_addr = 0;
	uwr_addr = 0;
	
	q = 0;
	mmcpy_ena = 0;
end

//=======================================================

always @(posedge clk) begin
	tick <= tick + 1; 
	uwr_addr <= tick;
	q <= $random;
end

always @(posedge clk)
	if (tick == 0)
		uwr_ena <= 1;
	else if (tick == 4)
		uwr_ena <= 0;

// fixme: for urd_ena

always @(posedge clk)
 	if (tick == 5)
 		mmcpy_ena <= 1;
 	else if (tick == 9)
 		mmcpy_ena <= 0;

always @(*) begin
	if(mmcpy_ena) begin
		// connect memcopy
		gaddr = mmcpy_addr;
		gwr_ena = mmcpy_wr_ena;
		grd_ena = mmcpy_rd_ena;
	end
	else begin
		// for util ops
		gaddr = uwr_addr;
		gwr_ena = uwr_ena;
		grd_ena = urd_ena;
	end

end

//===========================================
// connect to memcopy

endmodule

// always @(posedge clk)
// 	if (tick == 4)
// 		grd_ena <= 1;
// 	else if (tick == 8)
// 		grd_ena <= 0;
// always @(posedge clk)
// 	if (grd_ena)
// 		urd_addr <= urd_addr + 1;
// 	else if(gwr_ena)
// 		urd_addr <= 0;
// if( grd_ena && !gwr_ena )
// 	gaddr = urd_addr;	