// читаем тактовой частотой, а потом выдает сигналы реже
//   тогда такт на spi будет прямой

// нужно поймать данные? а если они нулевые?
// это слейву нужно посстанавливать клок

//localparam 

// Нужен инверсный сигнал такта, но буфферизовывать 
//   основной такт не стоит. Сделаю регист на выходе.

module splitter( 
	clk, rst_a, ena, 
	sclk_n, cs_n );

input clk, ena, rst_a;
output reg sclk_n;
output reg cs_n;

wire sclk_n_w;
wire cs_n_w;  // frames по 16 бит
wire rst_a = 1'b1;

reg [3:0] state;
reg [3:0] next_state;
reg [3:0] iter;  // wr bit iter
reg [11:0] sample;  // shift reg

localparam IDLE = 2'b00, 
	CS_N_WAIT = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11;

assign sclk_n_w = !clk;
always @(*) begin
	next_state = state;
	case( state )
		IDLE: begin
			// хотя важно только после ресета
			next_state = CS_N_WAIT;
		end
		CS_N_WAIT: begin
			next_state = IDLE;
		end
	endcase
end

always @(posedge clk or posedge rst_a) begin
	if (rst_a) begin
		sclk_n <= 1;
		cs_n <= 1;
		state <= IDLE;		
	end 
	else begin
		if( ena ) begin
			sclk_n <= sclk_n_w;	
			cs_n <= cs_n_w;
			state <= next_state;
		end
		// fixme: ветка не нужна? похоже нет
	end
end

// in one
//always @ (posedge clk or posedge rst_a) begin
//	//if( rst_a )  // fixme: need done
//end

// output fsm

endmodule

//////////////////////////////////////////

module shift (clk, si, so);
input        clk,si;
output       so;
reg    [7:0] tmp;
always @(posedge clk) begin
   tmp    <= tmp << 1;
   tmp[0] <= si;
end
assign so = tmp[7];
endmodule