// читаем тактовой частотой, а потом выдает сигналы реже
//   тогда такт на spi будет прямой

// нужно поймать данные? а если они нулевые?
// это слейву нужно посстанавливать клок

//localparam 

// Нужен инверсный сигнал такта, но буфферизовывать 
//   основной такт не стоит. Сделаю регист на выходе.

// сигнал от микросхемы будет асинхронный, так что нужнен 
//   синхронизатор для предоптвр. метастабильности

// Art of Hardware....

// Не нужно изгяляться над клоком
// выход счетчика и регистр на выходе, чтобы не дребезжал
// нужно защелкнуть выход

// Multiply always blocks
//   http://electronics.stackexchange.com/questions/29601/why-cant-regs-be-assigned-to-multiple-always-blocks-in-synthesizable-verilog
//   http://electronics.stackexchange.com/questions/29553/how-are-verilog-always-statements-implemented-in-hardware

//"One important restriction that pops up is that every reg variable 
//can only be assigned to in at most one always 
//statement. In other words, regs have affinity to always blocks."
//
// Т.е. писать можно только в одном, но читать в любом?

module splitter( 
	clk, rst_a, ena, 
	sclk_n, cs_n,

	from_device
);

input clk, ena, rst_a;  // это не простые сигналы, нужно очень хорошо
	// понимать как с ними иметь дело
output reg sclk_n;
output reg cs_n;
input from_device;  // нужно защелкнуть

reg clk_n_work;
reg cs_n_work;
reg clk_tmp;
wire clk_mask;


// state
reg [4:0] cntr_curr;
reg [4:0] cntr_next;
reg [3:0] state_curr;
reg [3:0] state_next;
// state

localparam IDLE = 2'b00, 
	CS_N_WAIT = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11;

always @(*) begin
	state_next = state_curr;
	cntr_next = cntr_curr;
	cs_n_work = 1;
	case( state_curr )
		IDLE: begin
			cs_n_work = 1;
			cntr_next = 0;
			state_next = CS_N_WAIT;
		end
		CS_N_WAIT: begin
			if( cntr_curr < 16 ) begin
				cs_n_work = 0;				
				cntr_next = cntr_next + 1'b1;
			end
			else begin
				state_next = IDLE;
			end
		end
	endcase
end

// если отдельные блоки, то могут быть гонки
always @(posedge clk or posedge rst_a) begin
	if (rst_a) begin
		state_curr <= IDLE;	
		clk_n_work <= 1;
	end 
	else begin
		state_curr <= state_next;

		cntr_curr <= cntr_next;
		// кажется так нельзя
		clk_n_work <= clk_n_work + 1'b1;  // ??
	end
end

always @( posedge clk or posedge rst_a ) begin
	if( rst_a ) begin
		sclk_n <= 1;
		cs_n <= 1;
	end
	else begin
		sclk_n <= ~(clk_n_work & ~(cs_n & cs_n_work));
		cs_n <= cs_n_work;
	end
end

endmodule