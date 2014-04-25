`include "vconst.v"

module client_my_fec
	(
	// asynchronous reset     
	reset,
	// direct connection to the Ethernet core's transmitter client interface.
	tx_data_fec,
	tx_data_fec_valid_del,
	tx_data_start,
	tx_data_stop,
	
	tx_ack,
	tx_clk,

	//transport stream input
	TS_CLK,
	ts_parallel,
	ts_parallel_strobe_fec,
	strobe_47,
	
	fec_number
	);
	
	`define FOUR_UDP_PACKETS 24'd5263

	`define FEC_PACKET 24'd1386
	`define FIRST_UDP_PACKET 24'd1315

	parameter PAYLOAD_OFFSET = 70;
	parameter D_FEC = 8'h04;
	parameter OFFSET = 8'h01;

	// COLUMN_FEC
	parameter PORT_FEC = 16'd8198;// Destination UDP port(if column fec=2006h=8198)
	parameter TYPE_FEC = 8'h00;// X=0; D=0 if column;type=0(XOR);index=0 for XOR

	// create a synchronous reset in the transmitter clock domain
	reg tx_pre_reset; initial tx_pre_reset = 0;
	reg tx_reset; initial tx_reset = 0;

	input        reset;
	input        tx_ack;
	input        tx_clk;
	output [7:0] tx_data_fec;
	output       tx_data_fec_valid_del;
	output		 tx_data_start;
	output   	 tx_data_stop;
	input        TS_CLK;//input, will bó strobed (1/8) for parallel output
	input [7:0]  ts_parallel;
	input		 	 ts_parallel_strobe_fec;
	input        strobe_47;
	input	[15:0] fec_number;
	
	always@(posedge tx_clk, posedge reset)
	begin
		if (reset == 1) begin
			tx_pre_reset <= 1'b1;
			tx_reset <= 1'b1;
		end
		else begin
			tx_pre_reset <= 1'b0;
			tx_reset <= tx_pre_reset;
		end
	end
		
	// adress 
	
	reg [10:0] ts_wr_byte;
	initial ts_wr_byte <= 11'd1201;
	wire clk_ena;
	wire [10:0] ts_wr_byte_C = PAYLOAD_OFFSET-1;

	assign clk_ena = ts_parallel_strobe_fec;
	always@(posedge TS_CLK /*or posedge reset*/) begin 
		if(clk_ena) begin 
			if (strobe_47 & (ts_wr_byte > 11'd1200)) begin //more then 6 but less than 7 TS packet
				ts_wr_byte <= ts_wr_byte_C; //after Eth,IP,UDP,RTP usw.- for next writing
			end
			else ts_wr_byte <= ts_wr_byte + 1;
		end
	end

	//sum
	
	reg [7:0] ts_parallel_r; initial ts_parallel_r = 0;
	reg [7:0] ts_parallel_r1; initial ts_parallel_r1 = 0;
	reg frame_written, frame_written_del1, frame_written_del2; initial frame_written = 0;
	reg ts_parallel_strobe_del; initial ts_parallel_strobe_del = 0;
	reg ts_parallel_strobe_del1; initial ts_parallel_strobe_del1 = 0;
	reg ts_wr_bank; initial ts_wr_bank = 0;

	always@(posedge TS_CLK) begin
		ts_parallel_strobe_del <= ts_parallel_strobe_fec;
		ts_parallel_strobe_del1 <= ts_parallel_strobe_del;
		ts_parallel_r <= ts_parallel;
		ts_parallel_r1 <= ts_parallel_r;
	end
	
	reg [15:0] ip_identification; initial ip_identification = 16'd0;
	reg [15:0] sequence_number; initial sequence_number = 16'd0;
	reg [23:0] clk_ena_divider; initial clk_ena_divider <= 24'd0;
	wire ts_valid_strobe;
	wire [7:0] ts_parallel_out;
	wire [7:0] ts_parallel_in;
	
	assign ts_valid_strobe = (clk_ena_divider > `FIRST_UDP_PACKET);
	always@(posedge TS_CLK or posedge reset) begin
		if(reset == 1)begin
			clk_ena_divider <= 24'd0;
			frame_written<= 1'b0;
		end
		else begin
			if(clk_ena) begin
				if(clk_ena_divider == `FOUR_UDP_PACKETS) begin
					clk_ena_divider <= 24'd0;
					ip_identification <= ip_identification + 1;
					sequence_number <= sequence_number + 1;
					ts_wr_bank <= ~ts_wr_bank;
					frame_written <= 1;
				end	
				else clk_ena_divider <= clk_ena_divider+1;		
			end
		if(frame_written_del1) frame_written <= 0;
		end
	end
	assign ts_parallel_in = (ts_valid_strobe) ? ts_parallel_r1^ts_parallel_out : ts_parallel_r1;	
	
	// delay
	wire tx_clk_ena = 1;
	wire fr_domen_tx_clk = frame_written_del1 & ~frame_written_del2; // !!! 
	always@(posedge tx_clk) begin
		frame_written_del1 <= frame_written;
		frame_written_del2 <= frame_written_del1;
	end 
	
	// gen. address
	reg [23:0] tx_clk_divider_addrd;  // if no input signal, generate 1 packet pro second as test, can be DISABLED if no USE_ONE_SECOND_TEST_PACKETS
	initial tx_clk_divider_addrd <= 24'd0;
	assign waiting_ack = (tx_clk_divider_addrd == 0) & ~tx_reset & ~tx_ack;
	always@(posedge tx_clk) begin
		if(~tx_data_fec_valid_del) 
		  tx_clk_divider_addrd <= 0;
		else if(~waiting_ack & tx_data_fec_valid_del)  // !! 
		  tx_clk_divider_addrd <= tx_clk_divider_addrd+1;
	end 
	
	
	// valid_fec
	reGenerator #(.DEL_PACK(`FEC_PACKET*2), .COUNTER_WIDTH(13)) rg1 (
	  .clk(tx_clk),
	  .clk_ena(tx_clk_ena),
	  .src(fr_domen_tx_clk),
	  .sink(dffExpand),
	  .control(0));
	
	reGenerator #(.DEL_PACK(`FEC_PACKET), .COUNTER_WIDTH(11)) rg2 (
	  .clk(tx_clk),
	  .clk_ena(tx_clk_ena),
	  .src(dffExpand),
	  .sink(tx_data_fec_vd_start),
	  .control(0));
	  
	reGenerator #(.DEL_PACK((`FEC_PACKET)-1), .COUNTER_WIDTH(11)) rg_wa (
	  .clk(tx_clk),
	  .clk_ena(tx_clk_ena),
	  .src(tx_ack),
	  .sink(tmp0),	
	  .control(1),
	  .tx_data_start(tx_data_start),
	  .tx_data_stop(tx_data_stop));
	  
	assign tx_data_fec_valid_del = tmp0 | tx_data_fec_vd_start;	
	
  /*ts_dpram*/ 
	wire [7:0] doutb;
	fec2_dpram fec2_dpram (
		.clka(TS_CLK),	  //input clka;
		.addra({ts_wr_bank, ts_wr_byte[10:0]}),  //input [11 : 0] write addra;
		.dina(ts_parallel_in),	  //input [7 : 0] dina;
		.douta(ts_parallel_out),	//output [7 : 0] douta]
		.wea(ts_parallel_strobe_del1),  //input wea;

		.clkb(tx_clk),	  //input clkb;
		.addrb({~ts_wr_bank, tx_clk_divider_addrd[10:0]}),  //input [11 : 0] read addrb;
		.doutb(doutb)  //output [7 : 0] doutb;
	);		

	reg[7:0] pkt [(PAYLOAD_OFFSET-1):0];
	assign tx_data_fec =  (tx_clk_divider_addrd < PAYLOAD_OFFSET) ? pkt[tx_clk_divider_addrd] : doutb;

	wire [15:0] ip_checksum = checksum(0);

	always @(*) begin
	//FEC  header 1386
	// MAC header
	pkt[0] <= 		8'h01;// MAC destination 1	multicast
	pkt[1] <= 		8'h00;// MAC destination 2	multicast
	pkt[2] <= 		8'h5e;// MAC destination 3	multicast	- 5e from 239. ...
	pkt[3] <= 		8'h7f;// MAC destination 4	multicast	- 7f for energia (IP[2] = 255)
	pkt[4] <= 		8'h00;// MAC destination 5	multicast	- 00 for energia (IP[3] = 0)
	pkt[5] <= 		8'h01;// MAC destination 6	multicast	- 01 for energia (IP[4] = 1)
	pkt[6] <= 		8'h00;// MAC source 1 00
	pkt[7] <= 		8'hc0;// MAC source 2 c0
	pkt[8] <= 		8'hdf;// MAC source 3 df
	pkt[9] <= 		8'hfa;// MAC source 4 fa
	pkt[10] <= 		8'h41;// MAC source 5 8f
	pkt[11] <= 		8'h41;// MAC source 6 2b
	pkt[12] <= 		8'h08;//Type (IP)
	pkt[13] <= 		8'h00;

	//IP header
	pkt[14] <= 		8'h45;//Version and header length
	pkt[15] <= 		8'h00;//Type of service
	pkt[16] <= 		8'h05;
	pkt[17] <= 		8'h5c;//055c Total length = 1372 bytes = 1352(UDP) + 20(IP)
	pkt[18] <= 		ip_identification[15:8];//8'hc7;
	pkt[19] <= 		ip_identification[7:0];//8'h74;// c774 identification
	pkt[20] <= 		8'h40;
	pkt[21] <= 		8'h00;//0000 - flags
	pkt[22] <= 		8'd254;//TTL = 254
	pkt[23] <= 		8'd17;//Protocol = 17 UDP
	pkt[24] <= 		ip_checksum[15:8];
	pkt[25] <= 		ip_checksum[7:0];
	pkt[26] <= 		8'd10;//Source IP[1]
	pkt[27] <= 		8'd2;//Source IP[2]
	pkt[28] <= 		8'd20;//Source IP[3]
	pkt[29] <= 		8'd2;//Source IP[4]
	pkt[30] <= 		8'd239;//Destination multicast IP[1]
	pkt[31] <= 		8'd255;//Destination multicast IP[2]
	pkt[32] <= 		8'd0;//Destination multicast IP[3]
	pkt[33] <= 		8'd1;//Destination multicast IP[4]

	//UDP header
	pkt[34] <= 		8'h04;
	pkt[35] <= 		8'ha1;//Source UDP port = 0xF88 = 3976
	pkt[36] <= 		PORT_FEC[15:8];
	pkt[37] <= 		PORT_FEC[7:0];//Destination UDP port (2004h=8196, if column fec=2006h=8198, row fec=2008h=8200)
	pkt[38] <= 		8'h05;
	pkt[39] <= 		8'h48;//Length 1352(0548) bytes = 1344 (payload) + 8 (UDP header)
	pkt[40] <= 		8'h00;
	pkt[41] <= 		8'h00;//Checksum, if not used can be set to 0x0000

	//RTP header
	pkt[42] <= 		8'h80;//ver=2, p,x,cc=0
	pkt[43] <= 		8'h60;//M=0,Mpeg-II transport streams(33), 60h=96
	pkt[44] <= 		sequence_number[15:8]; 
	pkt[45] <= 		sequence_number[7:0];
	pkt[46] <= 		8'h00;
	pkt[47] <= 		8'h00;
	pkt[48] <= 		8'h00;
	pkt[49] <= 		8'h00;//timestamp 
	pkt[50] <= 		8'h00;
	pkt[51] <= 		8'h00;
	pkt[52] <= 		8'h00;
	pkt[53] <= 		8'h00;//SSRC

	//FEC header
	pkt[54] <= 		fec_number[15:8];
	pkt[55] <= 		fec_number[7:0];//SNBase low 
	pkt[56] <= 		8'h00; 
	pkt[57] <= 		8'h00;//length recovery
	pkt[58] <= 		8'h80;//E=1 The heading is prolonged, PT=0
	pkt[59] <= 		8'h00;
	pkt[60] <= 		8'h00;
	pkt[61] <= 		8'h00;//mask=0
	pkt[62] <= 		8'h00;
	pkt[63] <= 		8'h00;
	pkt[64] <= 		8'h00;
	pkt[65] <= 		8'h00;//TS_Recovery
	pkt[66] <= 		TYPE_FEC;//X=0; D=0 if column, D=1 if row;type=0(XOR);index=0 for XOR
	pkt[67] <= 		OFFSET;//offset=L=1 for my column FEC or offset = 1 for row FEC
	pkt[68] <= 		D_FEC;//NA=4
	pkt[69] <= 		8'h17;//8'h00;//SNbase=0
	end

	function [19:0] checksum;
	input dummy;
	begin
		checksum = 0;
		checksum = checksum + {pkt[14],pkt[15]};//14-begin of IP header
		checksum = checksum + {pkt[16],pkt[17]};
		checksum = checksum + {pkt[18],pkt[19]};
		checksum = checksum + {pkt[20],pkt[21]};
		checksum = checksum + {pkt[22],pkt[23]};
		//24 and 25 are checksum
		checksum = checksum + {pkt[26],pkt[27]};
		checksum = checksum + {pkt[28],pkt[29]};
		checksum = checksum + {pkt[30],pkt[31]};
		checksum = checksum + {pkt[32],pkt[33]};//33 is end of IP header
		checksum = {4'h0, checksum[15:0]} + {16'b0,checksum[19:16]};
		checksum = {4'h0, checksum[15:0]} + {16'b0,checksum[19:16]};		
		checksum = ~checksum;
	end
	endfunction
endmodule
