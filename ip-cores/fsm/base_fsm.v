// FIXME: очень плохое APi

//синхронный ресет на дает создать ena триггер
//   синхронный ресет не отличим от других сигналов

// "eff sync only subset Verilog" как то так звучало

// детектировать сигнал нужно основным клоком, т.к. мы 
//   тактируем им напрямую, ширина стробирующий импльсов в один
//   такт основого клока
//
// Обойтись бы без детектирования 

// если отдельные блоки, то могут быть гонки
// fixme: async start is bad looks lime in fpga
// fIXME: если синхр. сброс, то ресет станет
//   триггером, т.е. входом триггера
// http://www.sunbustart-design.com/papers/CummingsSNUG2003Boston_Resets.pdf

// ресет добавляет довольно много логики!

`include "const.v"

module base_fsm( 
	clk, start, clk_scaler, 
	sclk_n, cs_n,

	from_device,
	just_test,
	just_test_bus
);

input clk, start;  // это не простые сигналы, нужно очень хорошо
	// понимать как с ними иметь дело
input [`W-1:0] clk_scaler;
output [7:0] just_test_bus;
output reg sclk_n;
output reg cs_n;
input from_device;  // нужно защелкнуть
output just_test;

reg curr_sclk_n;
reg nxt_sclk_n;
reg nxt_cs_n;
reg ena;
reg [`W-1:0] clk_scaler_cntr;
reg [5:0] curr_trans_cntr;
reg [5:0] nxt_trans_cntr;

reg [3:0] curr_state;
reg [3:0] nxt_state;

localparam IDLE = 2'b00, 
	CS_N_WAIT = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11;

always @(*) begin
	nxt_state = curr_state;
	nxt_cs_n = 1;
	nxt_sclk_n = curr_sclk_n;
	nxt_trans_cntr = curr_trans_cntr;
	case( curr_state )
		IDLE: begin
			nxt_cs_n = 1;
			nxt_sclk_n = 1;
			nxt_trans_cntr = 0;
			nxt_state = CS_N_WAIT;
		end
		CS_N_WAIT: begin
			if( nxt_trans_cntr < `PKG_SIZE*2 ) begin
				nxt_cs_n = 0;
			end
			else begin
				nxt_state = IDLE;
			end
						
			nxt_sclk_n = ~curr_sclk_n;
			nxt_trans_cntr = curr_trans_cntr + 1'b1;
		end
	endcase
end

always @( posedge clk ) begin
	if( start ) begin
		curr_state <= IDLE;
	end 
	else begin 
		if( ena ) begin
			curr_state <= nxt_state;
		end
	end
end

always @( posedge clk ) begin
	if( ena ) begin
		curr_trans_cntr <= nxt_trans_cntr;
		curr_sclk_n <= nxt_sclk_n;

		sclk_n <= ~(nxt_sclk_n & ~( cs_n & nxt_cs_n ));
		cs_n <= nxt_cs_n;
	end
end

initial begin
	ena <= 0;
	clk_scaler_cntr <= 0;
end

// scaler
// fixme: нужно в два раза быстрее
// fixme: ena сдвинут на такт, проблема ли это?
// не если без триггера то ена будет получена из большого
//   количества комбинационной логики
// fixme: счет с нуля! и еще сдвигаем
always @( posedge clk ) begin
	if( clk_scaler_cntr == clk_scaler ) begin  
		ena <= 1;
		clk_scaler_cntr <= 0;
	end
	else begin
		ena <= 0;
		clk_scaler_cntr <= clk_scaler_cntr + 1'b1;
	end
end

// assign just_test = ena;
// assign just_test_bus = nxt_trans_cntr;

endmodule