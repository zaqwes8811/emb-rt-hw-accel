// trick: сперва писать в тестбенче, а потом выделить модуль

`timescale 10ns/1ps
`default_nettype none
module test;

// $dump*
// http://www.referencedesigner.com/tutorials/verilog/verilog_62.php


// Outputs to DUT (DUT inputs)
reg clk = 0;
// Inputs from DUT (DUT outputs)
reg [7:0] tick;

// Data
reg [7:0] q;

// // Util
// reg uwr_ena;
// reg urd_ena;
// reg [7:0] urd_addr;
// reg [7:0] uwr_addr;

// // memcopy
// reg mmcpy_ena;
// wire [7:0] dest = 4;
// wire [7:0] src = 0;
// wire [7:0] num = 8;
// wire mmcpy_rd_ena;
// wire mmcpy_wr_ena;
// wire [7:0] mmcpy_addr;


// Instances
// ram_sp_sr_sv dut(clk, ddr_addr, q, ddr_out, ddr_wr_ena, ddr_rd_ena);
// memcpy mc(
// 	clk, 
// 	dest, src, num, mmcpy_ena,
// 	mmcpy_rd_ena, mmcpy_wr_ena, mmcpy_addr
// );

//=======================================================

always #1 clk=~clk;

initial
begin
	// uwr_ena = 0;
	tick = 0;
	// ddr_wr_ena = 0;
	// ddr_rd_ena = 0;

	// urd_addr = 0;
	// uwr_addr = 0;
	
	q = 0;
	// mmcpy_ena = 0;
end

//=======================================================

always @(posedge clk) begin
	tick <= tick + 1; 
	// uwr_addr <= tick;
	q <= $random;
end

// always @(posedge clk)
// 	if (tick == 0)
// 		uwr_ena <= 1;
// 	else if (tick == 4)
// 		uwr_ena <= 0;

// // fixme: for urd_ena

// always @(posedge clk)
//  	if (tick == 5)
//  		mmcpy_ena <= 1;
//  	else if (tick == 9)
//  		mmcpy_ena <= 0;

// always @(*) begin
// 	if(mmcpy_ena) begin
// 		// connect memcopy
// 		ddr_addr = mmcpy_addr;
// 		ddr_wr_ena = mmcpy_wr_ena;
// 		ddr_rd_ena = mmcpy_rd_ena;
// 	end
// 	else begin
// 		// for util ops
// 		ddr_addr = uwr_addr;
// 		ddr_wr_ena = uwr_ena;
// 		ddr_rd_ena = urd_ena;
// 	end

// end

//================== ddr ====================
// Mem interface
reg [7:0] ddr_addr;
reg ddr_rd_ena;
reg ddr_wr_ena;
wire [7:0] ddr_out;

ram_sp_sr_sv ddr(clk, ddr_addr, q, ddr_out, ddr_wr_ena, ddr_rd_ena);

//=============== copy fsm ==================

reg [1:0] state, next_state;
reg start;  // input
reg done;  // output
wire [7:0] src = 4;  // in
wire [7:0] dst = 7;  // in
wire [7:0] num = 5;  // in
reg hard_fault;  // fixme: higher level check?
reg [7:0] src_ptr;
reg [7:0] dst_ptr;
parameter IDLE = 2'b00, 
	WAIT_COPY_RES = 2'b01,
	READ_MEM = 2'b10;

initial
begin
	state = IDLE;
	next_state = IDLE;
	start = 0;
	done = 0;
	//src_ptr = 0;  // never mind

	hard_fault = 0;

	ddr_rd_ena = 1;
	ddr_wr_ena = 0;
end


always @(*) begin
	next_state = state;
	case ( state )
		IDLE: begin
			if( start ) begin
				src_ptr = src;
				dst_ptr = dst;
				done = 1'b0;
				next_state = WAIT_COPY_RES;
			end
		end

		WAIT_COPY_RES: begin
			if( src_ptr == src + num )
				done = 1'b1;

			if( done ) begin
				next_state = READ_MEM;
			end
		end
		READ_MEM: begin
			next_state = IDLE;
		end
	endcase
end

always @(*) begin
	if (tick == 3)
		start = 1;
	else
		start = 0;

	// when done	

	ddr_addr = src_ptr;
end

// transitions
always @ (posedge clk) 
	state <= next_state;

always @ (posedge clk)
	if ( !done ) begin
		src_ptr <= src_ptr + 1;
		dst_ptr <= dst_ptr + 1;
	end

//===========================================
// connect to memcopy

endmodule

// always @(posedge clk)
// 	if (tick == 4)
// 		ddr_rd_ena <= 1;
// 	else if (tick == 8)
// 		ddr_rd_ena <= 0;
// always @(posedge clk)
// 	if (ddr_rd_ena)
// 		urd_addr <= urd_addr + 1;
// 	else if(ddr_wr_ena)
// 		urd_addr <= 0;
// if( ddr_rd_ena && !ddr_wr_ena )
// 	ddr_addr = urd_addr;	