// Attention!! Кеши важны и тут
// "FPGAs are very good at streaming models, 
// while GPUs are better at burst mode models."

// Choose:
// http://electronics.stackexchange.com/questions/56302/how-to-access-ram-for-use-with-an-fpga-for-high-performance-computing
// https://www.altera.com/en_US/pdfs/literature/hb/nios2/edh_ed51008.pdf - from Altera
// fixme: internal (small peaces(15k - 2M)? as cache?) external (ddr, big)

// !!! "For the money, it is hard to beat an Intel i7 
// based quad-core machine with a reasonable GPU card. Just warning you, in case all you really care about is math speed."


// DDR:
// https://docs.numato.com/kb/learning-fpga-verilog-beginners-guide-part-6-ddr-sdram/
// External RAM from Altera:
// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/hb/external-memory/emi.pdf
//
// Overview:
// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/wp/wp_ddr2.pdf
//
// ddr3: http://airccse.org/journal/jcsit/0811csit08.pdf
//


//================= Burst ====================

// "But when all you need it a single 8-bit byte, and the next 
// memory access is another 8-bit byte somewhere else in memory, you can
// never take advantage of SDRAM bursting. You will always have the 
// worst case access time (about 70ns in my case, based on the SDRAM I was using.)"

// https://www.altera.com/support/support-resources/knowledge-base/solutions/rd09182009_504.html
// "Understanding Avalon MM Bursting" youtube
// https://en.wikipedia.org/wiki/Burst_mode_(computing)

//================================= Impls =======================
// http://hackaday.com/2013/10/11/sdram-controller-for-low-end-fpgas/ - see comments
// https://people.ece.cornell.edu/land/courses/eceprojectsland/STUDENTPROJ/2007to2008/dp239/Denis-MEng-Final-nocode.pdf
//
// ddr3 arbiter
// https://web.wpi.edu/Pubs/E-project/Available/E-project-031212-183607/unrestricted/FPGA_Design_for_DDR3_Memory.pdf
// "Only one address and command is sent for every 512 bits sent." - 64 байта
//
// Q: записть куском, но если в блоке не наши данные?
// A: (?) "When the arbiter_block enters its Arbiter-to-Memory execution branch, 
// it first executes all buffered write commands."
// loop accel:
// http://cas.ee.ic.ac.uk/people/gac1/pubs/SamFPGA12.pdf
// "Considering only a single bank within the device, each memory address within that
//bank can be divided into three bit fields, corresponding to SDRAM
//Row, Burst, and Byte Within Burst, as shown in Fig. 2. These three
//fields can be represented as vectors in Z
//3"
//
// !! detailed Good!!
// http://codehackcreate.com/archives/444

//====================== Q ==================

// refrech cucle?

//====================================

//
// vlog *.v; vsim -t ns work.ram_tb; do waves.do
//

//=================== Ram inference ==========================
// http://quartushelp.altera.com/14.1/mergedProjects/hdl/vlog/vlog_pro_ram_inferred.htm
//
// " Altera recommends that you create RAM 
// blocks in separate entities or modules that contain only the RAM logic."
//


`timescale 10ns/1ps
//`default_nettype none

//============== Memories ===============================

// form all needs - on board ddr
// fixme: 64 байта(???) за раз? DATA - x32 - биты - prefetch может быть на 64 байта
// 8 * 2 * 4 = 64 - burst(8) ddr x32
// fixme: 32 bit - addr - 4 Gb (?) biiig
//
// http://frankdenneman.nl/2015/02/19/memory-deep-dive-memory-subsystem-bandwidth/
// data: 32 bytes = lines_per_clock * (bits_per_line / 8) * burst = (2 * 16 / 2) * 4
//
// addr: 256 / 32 = 8 = 2**3
`define DDR_ADDR_WIDTH 3
`define DDR_DATA_WIDTH 32
module on_board_ddr_controller(
		output reg [`DDR_DATA_WIDTH-1:0] q,
		input [`DDR_DATA_WIDTH-1:0] d,
		input [`DDR_ADDR_WIDTH-1:0] write_address, read_address,  // !! different !! 
		input we, clk);

// data size, count elems
reg [`DDR_DATA_WIDTH-1:0] mem [2**`DDR_ADDR_WIDTH-1:0];  

parameter MEM_INIT_FILE = "src.mif";

initial begin
	if (MEM_INIT_FILE != "") begin
		$readmemh(MEM_INIT_FILE, mem);
	end
end

always @ (posedge clk) begin
	if (we)
		mem[write_address] <= d;
	q <= mem[read_address]; // q doesn't get d in this clock cycle
end

endmodule

//================= on-chip ====================

// !!! диапазоны ширин и глубин зависят от чипа

// "Altera recommends that you use the Old Data Read-During-Write coding
// style for most RAM blocks as long as"
module single_clk_ram(
		output reg [15:0] q,
		input [15:0] d,
		input [6:0] write_address, read_address,  // !! different !! 
		input we, clk);

reg [15:0] mem [127:0];  // data size, count elems

parameter MEM_INIT_FILE = "src.mif";

initial begin
	if (MEM_INIT_FILE != "") begin
		$readmemh(MEM_INIT_FILE, ram);
	end
end

always @ (posedge clk) begin
	if (we)
		mem[write_address] <= d;
	q <= mem[read_address]; // q doesn't get d in this clock cycle
end
endmodule


//=====================================================

module ram_tb;

// Task0:
// read bunch -> write back this bunch

`define DELAY_SIZE 4  // fixme: -1?? сколько триггеров?

// $dump*
// http://www.referencedesigner.com/tutorials/verilog/verilog_62.php

reg clk = 0;
reg [7:0] tick;
reg [`DDR_ADDR_WIDTH-1:0] ddr_rd_addr;
reg [`DDR_ADDR_WIDTH-1:0] ddr_wr_addr;
wire [`DDR_DATA_WIDTH-1:0] ddr_q;
reg [`DDR_DATA_WIDTH-1:0] ddr_d;
wire [7:0] ddr_byte0_q;  // fixme: to array !!
wire we = 0;

//=======================================================

assign ddr_byte0_q = ddr_q[7:0];

on_board_ddr_controller i0__on_board_ddr_controller (
  	ddr_q, ddr_d,  ddr_wr_addr, ddr_rd_addr, we, clk );

always #1 clk=~clk;

initial
begin
	tick = 0;
	ddr_rd_addr = 0;
	ddr_wr_addr = 0;
end

always @(posedge clk) begin
	tick <= tick + 1; 
end

always @(posedge clk) begin
	ddr_rd_addr <= ddr_rd_addr + 1; 
end


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




