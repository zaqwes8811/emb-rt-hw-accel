module top_nios_de0
(
input CLOCK_50,
output [7:0] LED
);

wire [15:0] tmp;

assign LED=1;//tmp[7:0];
ni2 ni2_inst(
	.clk_clk(CLOCK_50)//,
	//.to_hex_readdata (tmp),
);
endmodule