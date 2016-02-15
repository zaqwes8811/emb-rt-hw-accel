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

//ftp://ftp.altera.com/up/pub/Altera_Material/12.1/Tutorials/DE0-Nano/Using_DE0-Nano_ADC.pdf

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

wire [`W-1:0] half_scaler;
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
	WR_ADDR = 2'b10,
	RD_RESP = 2'b11;

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
			nxt_state = WR_ADDR;
		end
		// CS_N_WAIT: begin
		// 	nxt_state = WR_ADDR;
		// end

		WR_ADDR: begin
			nxt_cs_n = 0;		
			if( nxt_trans_cntr == `PKG_SIZE*2 ) begin
				nxt_state = RD_RESP;
			end
						
			nxt_sclk_n = ~curr_sclk_n;

			// fixme: может быть обнулять?
			nxt_trans_cntr = curr_trans_cntr + 1'b1;
		end
		RD_RESP: begin
			nxt_state = IDLE;
		end
	endcase
end

// fixme: Для чтения нужен положительный перепад - нормальный клок

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

assign half_scaler = clk_scaler[`W-1:1];
always @( posedge clk ) begin
	if( clk_scaler_cntr == half_scaler ) begin  
		ena <= 1;
		clk_scaler_cntr <= 0;
	end
	else begin
		ena <= 0;
		clk_scaler_cntr <= clk_scaler_cntr + 1'b1;
	end
end

assign just_test = ena;
assign just_test_bus = clk_scaler_cntr;

endmodule