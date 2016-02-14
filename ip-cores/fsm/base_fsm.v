// FIXME: очень плохое APi

`include "const.v"

module splitter( 
	clk, rst, div, 
	sclk_n, cs_n,

	from_device,
	just_test,
	just_test_bus
);

input clk, rst;  // это не простые сигналы, нужно очень хорошо
	// понимать как с ними иметь дело

input [`W-1:0] div;
output [7:0] just_test_bus;
output reg sclk_n;
output reg cs_n;
input from_device;  // нужно защелкнуть
output just_test;

reg clk_n_w;
reg cs_n_w;
reg clk_tmp;
wire clk_mask;
reg internal_enable;
reg [`W-1:0] div_cntr;
reg [`W-1:0] div_cntr_nxt;

reg [7:0] cntr_curr;
reg [7:0] cntr_next;
reg [3:0] state_curr;
reg [3:0] state_next;

localparam IDLE = 2'b00, 
	CS_N_WAIT = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11;

always @(*) begin
	// can declare 'reg' here
	state_next = state_curr;
	cntr_next = cntr_curr;
	cs_n_w = 1;
	case( state_curr )
		IDLE: begin
			cs_n_w = 1;
			cntr_next = 0;
			state_next = CS_N_WAIT;
		end
		CS_N_WAIT: begin
			if( internal_enable ) begin
				if( cntr_curr < `PKG_SIZE * 2 ) begin
					cs_n_w = 0;				
					cntr_next = cntr_next + 1'b1;
				end
				else begin
					state_next = IDLE;
				end
			end
		end
	endcase
end

// детектировать сигнал нужно основным клоком, т.к. мы 
//   тактируем им напрямую, ширина стробирующий импльсов в один
//   такт основого клока
//
// Обойтись бы без детектирования 

// если отдельные блоки, то могут быть гонки
// fixme: async rst is bad looks lime in fpga
always @( posedge clk ) begin
	// fIXME: если синхр. сброс, то ресет станет
	//   триггером, т.е. входом триггера
	// http://www.sunburst-design.com/papers/CummingsSNUG2003Boston_Resets.pdf
	if( rst ) begin
		state_curr <= IDLE;	
	end 
	else if( internal_enable ) begin
		state_curr <= state_next;
	end
end

always @( posedge clk ) begin
	if ( rst ) begin
		cntr_curr <= 0;
		clk_n_w <= 1;
	end
	else if( internal_enable ) begin
		cntr_curr <= cntr_next;
		clk_n_w <= clk_n_w + 1'b1;	
	end
end

// output
always @( posedge clk ) begin
	if( rst ) begin
		sclk_n <= 1;
		cs_n <= 1;
	end
	else if( internal_enable ) begin
		sclk_n <= ~(clk_n_w & ~(cs_n & cs_n_w));
		cs_n <= cs_n_w;
	end
end

// divider
// fixme: Это clk-gating и правильно ли это вообще?
always @( * ) begin
	internal_enable = 0;
	div_cntr_nxt = div_cntr;
	if( div_cntr == 3'b11-1 ) begin  // счет с нуля!
		internal_enable = 1;
		div_cntr_nxt = 0;
	end
	else begin
		div_cntr_nxt = div_cntr + 1'b1;
	end
end

// нужно в два раза быстрее
always @( posedge clk ) begin
	if( rst )begin
		div_cntr <= 0;		
	end
	else begin	
		div_cntr <= div_cntr_nxt;
	end
end

assign just_test = internal_enable;
assign just_test_bus = div_cntr;

endmodule