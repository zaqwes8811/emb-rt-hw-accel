// всетаки мыслить 76 серией похоже стоит так уже строго
//   это ограничивает

// fixme: = and <=
//   = - blocked assign - comb. logic
//   = - ...
//   <= - non-bloc
//   http://svo.2.staticpublic.s3-website-us-east-1.amazonaws.com/verilog/assignments/

//
module arbiter (
	clock,
	reset,
	req_0,
	gnt_0,
	gnt_1,
	gnt_1,
	);

input clock;
input reset;
input req_0;
input req_1;

output gnt_0;
output gnt_1;

reg gnt_0, gnt_1;

always @(posedge clock or posedge reset)
if (reset) begin
	gnt_0 <= 0;
	gnt_1 <= 0;
end
else if (req_0) begin
	gnt_0 <= 1;
	gnt_1 <= 0;
end
else if (req_1) begin
	gnt_0 <= 0;
	gnt_1 <= 1;

// fixme: else ???
end

endmodule

//
module counter(clk, rst, enable, count);
input clk, rst, enable;
output [3:0] count;
reg [3:0] count;

always @ (posedge clk or posedge rst)
if (rst) begin
	count <= 0;
end else begin: COUNT 
	while (enable) begin
		count <= count + 1
		disable COUNT;
	end
end

// next
always @(a or b or sel)
begin
	y = 0;  // fixme: why?
	if (sel == 0) begin
		y = a;
	end 
	else begin
		y = b;
	end
end

always @ (posedge clk)
if (reset == 0) begin
	y <= 0;
end
else if (sel == 0) begin
	y <= a;
end
else begin
	y <= b;
end

endmodule;

module assigns ();

reg reg_a;
reg reg_b;
wire swap_en;

always @ (posedge clk) begin
	// all <= выполняются параллельно
	//
	// Неблокирующее присваивание обозначает, что ко 
	// входу регистра в левой части присваивания 
	// подключается выход комбинаторной схемы, 
	// описываемой в правой части выражения. 
	if (swap_en) begin
		reg_a <= reg_b;
		reg_b <= reg_a;
	end
end


input strobe;
reg strobe_sampled;

reg[7:0] count;

always @(posedge clk) begin
	strobe_sampled <= strobe;  // запись текущего значения
	if (strobe & ~strobe_sampled) begin
		count <= count + 1
	end

	// fixme: присвоение по концу такта?
end

wire strobe_posedge = strobe & ~strobe_sampled;
wire[7:0] count_incr = count + 1;
always @(posedge clk) begin
	strobe_sampled <= strobe;
	if (strobe_posedge)
		count <= count_incr;
end

// bad
always @(posedge clk) begin
	count <= count + 1;
	// if (count == 10) 
	if (count + 1 == 10) 
		count <= 0;
end

// block assign
always @(posedge clk) begin
	x = x + 1;
	y = y + 1;
	// пока операции не зависимы, назницы нет = or <=
end

// лучше не пользоваться RMM
// in alw all <=
always @(posedge clk) begin
	x = x + 1;  
	y = x;  // цепочка как одно выражение

	//x <= x + 1
	//y <= x + 1
end

endmodule;

module other();
// http://www.asic-world.com/verilog/vbehave1.html
// http://www.nandland.com/vhdl/tutorials/tutorial-process-part1.html

//#1
//#2 for loop

endmodule

////////////// RMM ///////////////////////

// sigle clk and single rst

// Poor
assign clk_p1 = clk and p1_gate;
always @(posedge clk_p1) begin
end

// Rec
always @(posedge clk) begin
	if( p1_gate == 1'b1 ) begin
		
	end
end

// Poor
always @( posedge clk or posedge rst or posedge a) begin
	if( rst || a ) begin
		reg_sigs <= 1'b0;
	else begin
		
	end 
end

// Rec
assign z_rst = rst || a;
always @( posedge clk or posedge z_rst ) begin
	if( z_rst ) begin
		reg_sigs <= 1'b0;
	end
end


// async rst
always @(posedge clk or posedge rst_a) begin
	if( rst_a == 1'b1 ) begin
		
	end
end

// avoid latches
always @( a or b ) begin
	if( a == 1'b1 )
		q <= b;
	// no else
end

// VHDL
process( c )
begin
	case c is
		when '0' => q <= '1'; z <= '0';
		when others => q <= '0';  // no z in this branch
	end case
end process

always @(d) begin
	case ( d )
		2'b00: z <= 1'b1;
		2'b01: z <= 1'b0;
		2'b10: z <= 1'b1; s <= 1'b1;  // no s in all branches
		// miss variant (?)
	endcase
end

// Assign default values at the beginning of a process
// Assign outputs for all input conditions
// For VHDL, use else (instead of elsif ) for the final priority branch

// poor
always @( g or a or b) begin
	if( g == 1'b1 )
		q <= 0;
	else if ( a == 1'b1 )
		q <= b;
end

// rec
always @( g1 or g2 or a or b ) begin
	q <= 1'b0;  // !!!
	if( g1 == 1'b1 )
		q <= a;
	else if( g2 == 1'b1 )
		q <= b;
end

// Specify Complete Sensitivity Lists
process (a)
begin
	c <= a or b;  // wrong
end

always @(a) 
	c <= a or b;


// combination
// !!! sensitivity list must include every 
//   signal that is read by the process
always @( a or inc_dec ) begin
	if( inc_dec == 0 )
		sum = a+1;
	else begin
		sum = a - 1;
	end
end

// seq
always @(posedge clk) begin
	q <= d;
end

// block/nonbl
//When writing synthesizable code, always use nonblocking
//assignments in always@ (posedge clk) blocks
always @( posedge clk ) begin
	b <= a;
	a <= b;
end

// Code sequential logic, including state machines, with !!!one sequential
//sequential process. Improve readability by generating complex intermediate variables
//outside of the sequential process with assign statements

// State machine

reg [1:0] state;
parameter S0 = 2'b00, 
	S1 = 2'b01,
	S2 = 2'b10,
	S3 = 2'b11

// intermediate
assign rdy = in_rdy && !wait_1 && ( state == S3 )

always @( negedge rst_n or posedge clk ) begin
	if( !rst_n ) begin
		state <= S0;
		out1 <= 1'b0;
	end else begin
		case ( state )
			S0: if( input1 ) begin
				state <= S2;
				out1 <= 1'b1;
			end else begin
				state <= S1;
				out1 <= 1'b0;
			end
			S1: if( rdy ) state <= S2;
			S2: state <= S3;
			S3: state <= S0;
		endcase
	end
end
assign out2 = (state == S1) || ( state == S2 );

// Не лучший вариант кодирования

// a)
... combination
// b)
always @ (posedge clk) state <= next_state;

//!!! keep fsm and non fsm logic in sep. modules

// !!! Locate Related Combinational Logic in a Single Module


Design example ( MIT )
http://csg.csail.mit.edu/6.375/6_375_2006_www/handouts/lectures/L03-Verilog-Design-Examples.pdf



// http://inst.eecs.berkeley.edu/~cs150/sp12/resources/FSM.pdf
//
// always@( * ) blocks are used to describe Combinational Logic, or Logic Gates. Only = (blocking)
//assignments should be used in an always@( * ) block. Never use <= (non-blocking) assignments in
//always@( * ) blocks. Only use always@( * ) block when you want to infer an element(s) that changes
//its value as soon as one or more of its inputs change.

//
Specifying an FSM’s transition behavior is done in 3 steps. 
- First, we must choose how to store the
information that will tell the FSM what the next state should be on 
the next rising edge. 
- Second, we
must create a physical means of transitioning from the CurrentState to the next state. 
- Third, we must
implement the conditional-transitioning mechanism that will choose 
what the next state should be and
under what conditions a transition should be made.

назначены должны быть все - и в блок и неблок

// !!! это прямо типы блоков!!
always @(*)  // comb.
	// все к чему присваиваем должно быть во всех ветках!
	// Тут важно чтобы не было триггеров, в послед. они должны быть
	// Так а нерегистрам похоже можно присваивать и так?
always @(posedge clk or posedge rst_a)  // seq.
	// все к чему присваиваем должно быть во всех ветках!? не уверен

могут быть race conditions