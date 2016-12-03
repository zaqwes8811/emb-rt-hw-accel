// trick: сперва писать в тестбенче, а потом выделить модуль
// vlog *.v; vsim -t ns work.test; do waves.do

`timescale 10ns/1ps
//`default_nettype none

//=================== int ariphm 2001 ==============
// fixme: px to unsigned for calc? How?

// Verilog:
// http://www.uccs.edu/~gtumbush/published_papers/Tumbush%20DVCon%2005.pdf
// !!! http://amakersblog.blogspot.ru/2008/07/fixed-point-arithmetic-with-verilog.html
// fixme: похоже кодят в ручню, не надясь на Verilog

// Math:
// http://courses.cs.washington.edu/courses/cse467/08au/pdfs/lectures/11-FixedPointArithmetic.pdf
// http://www.superkits.net/whitepapers/Fixed%20Point%20Representation%20&%20Fractional%20Math.pdf
// https://groups.google.com/forum/#!topic/comp.lang.verilog/rRMKVkc8SjQ

// Other:
// http://stackoverflow.com/questions/28942318/16bit-fixed-point-arithmetic-multiplication

module fixed_convertof(
	input [5:-7] in,
	output signed [7:-7] out );
	assign out = {2'b0, in} ;
endmodule


module add_signed_2001 (
	input signed [2:0] A,
	input signed [2:0] B,
	output signed [3:0] Sum  // size !!
	);
	assign Sum = A + B;
endmodule

module add_carry_signed_final(
	input signed [2:0] A,
	input signed [2:0] B,
	input carry_in,
	output signed [3:0] Sum  // size !!
	);

	assign Sum = A + B + $signed({1'b0, carry_in});
endmodule

module mult_signed_2001 (
	input signed [2:0] a,
	input signed [2:0] b,
	output signed [5:0] prod  // size(a) + size(b) + 1
	);
	assign prod = a*b;
endmodule

// "However, recall the rule that if any operand of an operation 
// is unsigned the entire operation is unsigned. "
module mult_signed_unsigned_2001 (
		input signed [2:0] a,
		input [2:0] b,
		output signed [5:0] prod
	);
	assign prod = a*$signed({1'b0, b});
endmodule

// expr - "What is an expression? "

//Signed Shifting
//Signed Saturation

module test_math;
// Tasks:
// fixme: average - comb -> pipelining -> real mem access

always #1 clk=~clk;

initial begin
	clk = 0;
end

// Test bench only
real r1, r2;
real z_r;
`define F1 16
`define F2 14
reg [5:-`F1] x, y;
reg [8:-`F2] z;

// sum same size
reg [7:0] a, b, s, d;  // for good sum not enouth
reg ovf;  // !!!
reg unf;  // !!!

// mult
reg [2:0] x1;  // 3 bit
reg [2:0] y1;
reg [4 + 1/*3*/:0] p;  // ovf  / 6 bit
reg ovf_mul;

reg signed [ 7:0] x2;
reg signed [15:0] y2;

// sum
reg signed [11:0] v1, v2;
reg signed [12:0] sum;

reg signed [7:0] x3, y3, z3;
reg s_ovf;

// vec
reg signed [7:0] vec [7:0];

// Fixed-point
// http://my.ece.msstate.edu/faculty/reese/EE4743/lectures/fixed_point/fixed_point.pdf
// 1. For an unsigned saturating adder, 8 bit:
// 2. For a 2’s complement saturating adder, 8 bit:
//
// http://billauer.co.il/blog/2012/10/signed-arithmetics-verilog/
integer i;
initial begin // _try_name
	r1 = -9.6;
	r2 = -8.78;

	// r1 <= $itor(x)/2**16;
	// r2 <= r1 / ($itor(y)/2**16);
	z = $rtoi(r2 * 2**14);

	z_r = $itor($signed(z))/2**`F2;

	// Unsigned
	// Overflow detection + Saturation
	a = 250;
	b = 50;
	// unsigned => to 9 zero extended
	{ovf, s} = a + b;
	if (ovf == 1'b1)
		s = 8'hff;

	// substr with underflow
	{unf, d} = b - a;
	if (unf == 1'b1)
		d = 0;

	// compare unsigned
	// just > , < 

	// scaling by pow2

	// mult
	x1 = 3'h7;
	y1 = 3'h7;
	{ovf_mul, p} = x1 * y1;  // overflow? if size >= size(a) + size(b) no ovf

	// Signed
	// resize
	x2 = -7;
	y2 = {{8{x2[7]}}, x2};  // { n {...}} specifies n replications

	// negating

	// sum
	sum = {v1[11], v1} + {v2[11], v2};  // without detection
	//sum = v1 + v2; // or
	x3 = 124;
	y3 = 10;
	z3 = x3 + y3;
	s_ovf = ~x3[7] & ~y3[7] & z3[7] | x3[7] & y3[7] & ~z3[7];  // ovf | unf(?)

	// saturation

	$display("z3   = %0d", z3);
	$display("s_ovf   = %0d", s_ovf);

	// mult
	// ???

	// Mix Unsigned and Signed
	//???

	// Vector ops(?)
	for (i = 0; i < 10; i = i + 1) begin
  		vec[i] = i;
  		// $display("data_8bit   = %0d", -i);
  	end
end

endmodule





