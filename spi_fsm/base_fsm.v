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
	// Ins
	input clk, start,  // это не простые сигналы, нужно очень хорошо
		// понимать как с ними иметь дело
	input [`W-1:0] clk_scaler,
	input from_device,  // нужно защелкнуть

	// Outs
	output reg sclk_n,
	output reg cs_n,
	output reg [11:0] data,
	output reg irq,
	output test0,
	output test1
);

reg sclk_cntr_q;
reg sclk_cntr_d;
reg cs_n_d;
reg ena, enadelayed, rd_ena;
reg irq_d;
reg irq_q;
reg irq_2q;
reg [`W-1:0] clk_dvdr_cntr;
reg [5:0] iter_q;
reg [5:0] iter_d;

reg addr;
reg [2:0] addr_reg;

reg [3:0] state_q;
reg [3:0] state_d;
reg [11:0] data_d;

localparam IDLE = 2'b00, 
	WAIT_WR_ADDR = 2'b01,
	WR_ADDR = 2'b10,
	RD_RESP = 2'b11;

initial begin
	ena <= 0;
	clk_dvdr_cntr <= 0;
end

wire sclk_n_d = ~(sclk_cntr_d & ~( cs_n & cs_n_d ));
wire [`W-1:0] half_scaler = clk_scaler[`W-1:1];

always @(*) begin
	state_d = state_q;
	cs_n_d = 1;
	sclk_cntr_d = sclk_cntr_q;
	iter_d = iter_q;
	rd_ena = 0;
	irq_d = 0;
	addr = 0;
	case( state_q )
		IDLE: begin
			cs_n_d = 1;
			sclk_cntr_d = 1;
			iter_d = 0;
			state_d = WAIT_WR_ADDR;
		end
		WAIT_WR_ADDR: begin
			cs_n_d = 0;	
			if( iter_d == 2*2 ) begin
				state_d = WR_ADDR;
			end
		end
		WR_ADDR: begin
			cs_n_d = 0;		
			if( iter_d == 5*2 ) begin
				rd_ena = 1;
				state_d = RD_RESP;
			end

			// fixme: не очень ясно как
			addr = 1;	// fixme: make normal
		end
		RD_RESP: begin
			rd_ena = 1;
			if( iter_d == `PKG_SIZE*2 ) begin
				cs_n_d = 1;
				irq_d = 1;
				state_d = IDLE;
			end
			else begin
				cs_n_d = 0;
			end
		end
	endcase

	if( state_q == WAIT_WR_ADDR ||
			state_q == WR_ADDR ||
			state_q == RD_RESP ) begin
		iter_d = iter_q + 1'b1;
		sclk_cntr_d = ~sclk_cntr_q;
	end
end

always @( posedge clk ) begin
	if( start ) begin
		state_q <= IDLE;
	end 
	else begin 
		if( ena ) begin
			state_q <= state_d;
		end
	end
end

always @( posedge clk ) begin
	if( start ) begin  // sclk & ena ? and wr_ena
		addr_reg <= 7; // fixme: не очень ясно что дальше делать?
	end

	if( ena ) begin
		iter_q <= iter_d;
		sclk_cntr_q <= sclk_cntr_d;

		sclk_n <= sclk_n_d;
		cs_n <= cs_n_d;
	end

	// rd
	enadelayed <= ena & sclk_n_d & rd_ena;
	if( enadelayed ) begin
		// fixme: bad! need synchronizer
		data_d <= { data_d[10:0], from_device };
	end

	irq_q <= irq_d;
	irq_2q <= irq_q & enadelayed;
	if( irq_2q ) begin
		data <= data_d;
	end
	irq <= irq_2q;

	// div
	if( clk_dvdr_cntr == half_scaler ) begin  
		ena <= 1;
		clk_dvdr_cntr <= 0;
	end
	else begin
		ena <= 0;
		clk_dvdr_cntr <= clk_dvdr_cntr + 1'b1;
	end
end

assign test0 = addr;
assign test1 = enadelayed;
endmodule