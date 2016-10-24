`timescale 1ns/1ps
`default_nettype none
module test;


// Outputs to DUT (DUT inputs)
reg clk = 0;
reg reset = 0;
// Inputs from DUT (DUT outputs)
reg [7:0] count;
reg [7:0] addr;
reg [7:0] rd_addr;
reg [7:0] wr_addr;
reg [7:0] q;
wire [7:0] rd_q;

reg oe;
reg we;

ram_sp_sr_sv dut(clk, addr, q, rd_q, we, oe);

always #1 clk=~clk;

initial
begin
	count = 0;
	we = 0;
	oe = 0;
	rd_addr = 0;
	wr_addr = 0;
	q = 0;
end

always @(posedge clk) begin
	count <= count + 1; 
	wr_addr <= count;
	q <= q + 2;
end

always @(posedge clk) begin
	if (count == 0)
		we <= 1;
	else if (count == 4)
		we <= 0;
end
always @(posedge clk)
	if (count == 4)
		oe <= 1;
	else if (count == 12)
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

endmodule