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
input logic [7:0] start,
input logic pixel_done,
input logic done_read24,
input logic done_shift8,
input logic done_load_read_buffer,
input logic done_write,
input logic master_readdatavalid,
output logic master_write_enable,
output logic master_read_enable,
output logic [31:0] master_address,
output logic pixel_enable,
output logic shift_enable8,
output logic shift_enable24,
output logic load_read_buffer
);

logic [9:0] read_row, write_row;
logic [3:0] read_col, write_col;
logic [7:0] read_col_const, write_col_const;
logic read_row_enable, read_col_enable, write_row_enable, write_col_enable;
logic block_done, full_block_done, image_done;
logic wait_pd1, wait_pd2, delay_pd, wait_bd1, delay_bd, delay_fb;

//--------------------------read-----------------------------
flex_counter #(10) read_count_row
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(read_row_enable),
	.rollover_val(10'd640),
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

flex_counter #(8) read_count_const
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(read_col_enable),
	.rollover_val(8'd80),
	.rollover_flag(),
	.count_out(read_col_const)
);

//--------------------------write----------------------------
flex_counter #(10) write_count_row
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(write_row_enable),
	.rollover_val(10'd638),
	.rollover_flag(write_col_enable),
	.count_out(write_row)
);

flex_counter #(4) write_count_col
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(master_writeresponsevalid),
	.rollover_val(4'd6),
	.rollover_flag(write_row_enable),
	.count_out(write_col)
);

flex_counter #(8) write_count_const
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(write_col_enable),
	.rollover_val(8'd80),
	.rollover_flag(),
	.count_out(write_col_const)
);

//--------------------------block_done full_block_done and image_done--------------------------

flex_counter #(8) count_image_done
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(),
	.count_enable(full_block_done),
	.rollover_val(8'd80),
	.rollover_flag(image_done)
);

flex_counter #(10) count_full_block_done
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(full_block_done),
	.count_enable(block_done),
	.rollover_val(10'd640),
	.rollover_flag(full_block_done)
);

flex_counter #(4) count_block_done
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(block_done),
	.count_enable(pixel_done),
	.rollover_val(4'd6),
	.rollover_flag(block_done),
);

//address
assign master_address = master_read_enable ? 9'd480*read_row+(read_col+ read_col_const*6): master_write_enable ? 9'd480*write_row+(write_col+write_col_const*6) : 0;

typedef enum bit [4:0] {idle, read_24, read_pulse, read_filter, shift_write_full_block, write_full_block, shift_read_buffer,
	shift_write_block, write_block, shift_write, pulse, filter, wait_filter, wait_read_block, last_write, done} stateType;
stateType state;
stateType next_state;
logic next_pixel_done;

always_ff@(posedge clk, negedge n_rst)
begin 
	if (1'b0 == n_rst) begin
		state <= idle;
		wait_pd1 <= 0; wait_pd2 <= 0; wait_pd3 <= 0;
		wait_bd1 <= 0; wait_bd2 <= 0; wait_fb1 <= 0;
	end
	else begin
		state <= next_state;
		wait_pd1 <= pixel_done; wait_pd2 <= wait_pd1; delay_pd <= wait_pd2;
		wait_bd1 <= block_done; delay_bd <= wait_bd1; delay_fbd <= full_block_done;
	end
end

always_comb
begin
	next_state = state;
	case(state)
		idle:
			next_state = start ? read_24 : idle;
		read_24:
			next_state = done_read24 ? read_pulse : read_24;
		read_pulse:
			next_state = read_filter;
		read_filter:
		begin
			if (image_done)
				next_state = last_write;
			else if (delay_fbd)
				next_state = shift_write_full_block;
			else
				if (done_load_read_buffer)
				begin
					if (delay_bd)
						next_state = shift_read_buffer;
					else if (delay_pd)
						next_state = pulse;
					else
						next_state = wait_filter;
				end
				else begin
					if (delay_bd)
						next_state = wait_read_block;
					else if (delay_pd)
						next_state = pulse;
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
			next_state = done_write ? read_pulse : write_block;
		pulse:
			next_state = filter;
		filter:
			next_state = delay_fbd ? shift_write_full_block : delay_bd ? shift_read_buffer : delay_pd ? pulse : filter;
		wait_filter:
		begin
			if (delay_fbd)
				next_state = shift_write_full_block;
			else if (delay_bd)
				next_state = shift_read_buffer;
			else if (delay_pd)
				next_state = pulse;
			else
				next_state = wait_filter;
		end
		wait_read_block:
			next_state = done_load_read_buffer ? shift_read_buffer : wait_read_block;
		last_write:
			next_state = done;
	endcase
end

always_comb
begin
	master_read_enable = 0;
	shift_enable8 = 0;
	shift_enable24 = 0;
	master_write_enable = 0;
	pixel_enable = 0;
	case(state)
		idle:
		begin
			master_read_enable = 0;
			shift_enable8 = 0;
			shift_enable24 = 0;
			master_write_enable = 0;
			pixel_enable = 0;
			read_row_enable = 0;
			read_col_enable = 0;
			write_row_enable = 0;
			write_col_enable = 0;
			read_row = 0; write_row = 0; read_col = 0; write_col = 0;
			read_col_const = 0; write_col_const = 0;
			master_address = 0;
		end
		read_24:
		begin
			master_read_enable = 1;
			shift_enable24 = 1;
		end
		read_pulse:
		begin
			pixel_enable = 1;
			master_read_enable = 1;
			load_read_buffer = 1;
		end
		read_filter:
		begin
			master_read_enable = 1;
			load_read_buffer = 1;
			pixel_enable = 0;
		end
		shift_write_full_block:
		begin
			//wait clock cycle for pixel data to shift into write buffer
		end	
		write_full_block:
		begin
			master_write_enable = 1;
		end	
		shift_read_buffer:
		begin
			shift_enable8 = 1;
		end		
		shift_write_block:
		begin
			//wait clock cycle for pixel data to shift into write buffer
		end		
		write_block:
		begin
			master_write_enable = 1;
		end		
		pulse:
		begin
			pixel_enable = 1;
		end
		filter:
		begin
			pixel_enable = 0;
		end		
		wait_filter:
		begin
			pixel_enable = 1;
		end
		wait_read_block:
		begin
			master_read_enable = 1;
		end		
		last_write:
		begin
			master_write_enable = 1;
		end	
	endcase
end

endmodule