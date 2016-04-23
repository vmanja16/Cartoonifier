// $Id: $
// File name:   rcu.sv
// Created:     4/19/2016
// Author:      Russell Doctor
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: RCU

module rcu
(
input logic clk,
input logic n_rst,
input logic start,
//nput logic stop,
input logic pixel_done,
input logic block_done,
input logic full_block_done,
input logic image_done,
input logic done_read24,
input logic done_shift8,
input logic done_load_read_buffer,
input logic done_write,
input logic master_readdatavalid,
input logic master_writeresponsevalid,
output logic pixel_enable,
output logic master_writedata,
output logic master_address,
output logic master_read,
output logic master_write,
output logic shift_enable8,
output logic shift_enable24,
output logic shift_enable_write,
output logic load_read_buffer
);

logic [9:0] read_row, write_row;
logic [8:0] read_col, write_col;
logic [6:0] read_col_const, write_col_const;
logic read_row_enable, read_col_enable, write_row_enable, write_col_enable;

//--------------------------read-----------------------------
flex_counter #(5) read_count_row
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(read_row_enable),
	.rollover_val(640),
	.rollover_flag(read_col_enable),
	.count_out(read_row)
);

flex_counter #(4) read_count_col
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(read_row_enable),
	.count_enable(master_readdatavalid),
	.rollover_val(4'd8),
	.rollover_flag(read_row_enable),
	.count_out(read_col)
);

flex_counter #(4) read_count_const
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(read_col_enable),
	.rollover_val(4'd80),
	.rollover_flag(),
	.count_out(read_col_const)
);

//--------------------------write----------------------------
flex_counter #(5) write_count_row
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(write_row_enable),
	.rollover_val(640),
	.rollover_flag(write_col_enable),
	.count_out(write_row)
);

flex_counter #(4) write_count_col
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(master_writeresponsevalid),
	.rollover_val(4'd8),
	.rollover_flag(write_row_enable),
	.count_out(write_col)
);

flex_counter #(4) write_count_const
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(write_col_enable),
	.rollover_val(4'd80),
	.rollover_flag(),
	.count_out(write_col_const)
);

//address
assign master_address = master_read ? 640*read_row+(read_col+ read_col_const*6): master_write ? 640*write_row+(write_col+write_col_const*6) : 0;

typedef enum bit [4:0] {idle, read_24, read_filter, shift_write_full_block, write_full_block, 
	shift_write_block, write_block, shift_write, filter, wait_filter, wait_read_block,
	wait_read_full_block, read_shift_write, last_write, shift_read_buffer, done} stateType;
stateType state;
stateType next_state;

always_ff@(posedge clk, negedge n_rst)
begin
	if (1'b0 == n_rst)
		state <= idle;
	else
		state <= next_state;
end

always_comb
begin
	next_state = state;
	case(state)
	idle:
		next_state = start ? read_24 : idle;
	read_24:
		next_state = done_read24 ? read_filter : read_24;
	read_filter:
	begin
		if (image_done)
			next_state = last_write;
		else
			if (done_load_read_buffer) 
			begin
				if (full_block_done)
					next_state = shift_write_full_block;
				else if (block_done)
					next_state = shift_read_buffer;
				else if (pixel_done)
					next_state = shift_write;
				else
					next_state = wait_filter;
			end
			else begin
				if (full_block_done)
					next_state = wait_read_full_block;
				else if (block_done)
					next_state = wait_read_block;
				else if (pixel_done)
					next_state = read_shift_write;
				else
					next_state = read_filter;
			end
	end
	shift_write_full_block:
		next_state = write_full_block;
	write_full_block:
		next_state = done_write ? read_24 : write_full_block;
	shift_read_buffer:
		next_state = done_shift8 ? shift_write_block : shift_read_buffer;
	shift_write_block:
		next_state = write_block;
	write_block:
		next_state = done_write ? read_filter : write_block;
	shift_write:
		next_state = filter;
	filter:
		next_state = block_done ? shift_read_buffer : pixel_done ? shift_write : filter;
	wait_filter:
	begin
		if (full_block_done)
			next_state = shift_write_full_block;
		else if (block_done)
			next_state = shift_read_buffer;
		else if (pixel_done)
			next_state = shift_write;
		else
			next_state = wait_filter;
	end
	wait_read_block:
		next_state = done_load_read_buffer ? shift_read_buffer : wait_read_block;
	wait_read_full_block:
		next_state = done_load_read_buffer ? shift_write_full_block : wait_read_full_block;
	read_shift_write:
		next_state = done_load_read_buffer ? shift_write : read_shift_write;
	last_write:
		next_state = done;
	done:
	begin

	end
	endcase
end

always_comb
begin
	master_read = 0;
	shift_enable8 = 0;
	shift_enable24 = 0;
	master_write = 0;
	pixel_enable = 0;
	case(state)
	idle:
	begin
		master_read = 0;
		shift_enable8 = 0;
		shift_enable24 = 0;
		master_write = 0;
		pixel_enable = 0;
	end
	read_24:
	begin
		master_read = 1;
		shift_enable24 = 1;
	end
	read_filter:
	begin
		master_read = 1;
		load_read_enable = 1;
		pixel_enable = 1;
		//intensity_enable = 1;
	end
	shift_write_full_block:
	begin
		//pass
	end	
	write_full_block:
	begin
		master_write = 1;
	end	
	shift_read_buffer:
	begin
		shift_enable8 = 1;
	end		
	shift_write_block:
	begin
		//pass
	end		
	write_block:
	begin
		master_write = 1;
	end		
	shift_write:
	begin
		//pass
	end		
	filter:
	begin
		pixel_enable = 1;
	end		
	wait_filter:
	begin
		pixel_enable = 1;
	end
	wait_read_block:
	begin
		master_read = 1;
	end		
	wait_read_full_block:
	begin
		master_read = 1;
	end		
	read_shift_write:
	begin
		master_read = 1;
	end		
	last_write:
	begin
		master_write = 1;
	end		
	endcase
end

endmodule