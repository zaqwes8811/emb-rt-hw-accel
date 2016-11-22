// Mem interface
reg [7:0] ddr_addr;
reg ddr_rd_ena;
reg ddr_wr_ena;
wire [7:0] ddr_out;
reg [1:0] state, next_state;
reg start;  // input
reg done;  // output
wire [7:0] src = 4;  // in
// wire [7:0] dst = 7;  // in
wire [7:0] num = 5;  // in
reg hard_fault;  // fixme: higher level check?
reg [7:0] src_ptr;
reg [7:0] dst_ptr;
parameter IDLE = 2'b00, 
	WAIT_COPY_RES = 2'b01,
	READ_MEM = 2'b10;
	
//=============== copy fsm ==================

initial
begin
	state = IDLE;
	next_state = IDLE;
	start = 0;
	done = 0;
	//src_ptr = 0;  // never mind

	hard_fault = 0;

	ddr_rd_ena = 1;
	ddr_wr_ena = 0;
end


always @(*) begin
	next_state = state;
	case ( state )
		IDLE: begin
			if( start ) begin
				src_ptr = src;
				dst_ptr = 0;//dst;
				done = 1'b0;
				next_state = WAIT_COPY_RES;
			end
		end

		WAIT_COPY_RES: begin
			if( src_ptr == src + num )
				done = 1'b1;

			if( done ) begin
				next_state = READ_MEM;
			end
		end
		READ_MEM: begin
			next_state = IDLE;
		end
	endcase
end

always @(*) begin
	if (tick == 3)
		start = 1;
	else
		start = 0;

	// when done
	ddr_addr = src_ptr;
end

// transitions
always @ (posedge clk)
	state <= next_state;

always @ (posedge clk)
	if ( !done ) begin
		src_ptr <= src_ptr + 1;
		dst_ptr <= dst_ptr + 1;
	end