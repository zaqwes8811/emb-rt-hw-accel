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
	// подключается выход комбинаторной схемы, описываемой в правой части выражения. 
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


