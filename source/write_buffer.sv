// $Id: $
// File name:   write_buffer.sv
// Created:     4/19/2016
// Author:      Russell Doctor
// Lab Section: 337-05f
// Version:     1.0  Initial Design Entry
// Description: Write Buffer

module write_buffer
(
input logic clk,
input logic n_rst,
input logic [23:0] f_pixel,
input logic pixel_done,
//input logic master_waitrequest,
input logic master_writeresponsevalid,
output logic [31:0] master_writedata,
output logic done_write
);

reg [143:0] buffer1;
reg [143:0] buffer2;
logic buffer_enable;
logic next_buffer_enable;
logic done_load_write;
genvar i;

always_ff@(posedge clk, negedge n_rst)
begin
	if (1'b0 == n_rst)
	begin
		buffer_enable <= 0;
		//done_load_write <= 0;
		buffer1[23:0] <= 0;
		buffer2[23:0] <= 0;
	end
	else
	begin
		if (pixel_done)
		begin
			if (!buffer_enable)
				buffer1[23:0] <= f_pixel;
			else
				buffer2[23:0] <= f_pixel;
		end
		else if (master_writeresponsevalid)
		begin
			if (buffer_enable)
				buffer1[23:0] <= 0;
			else
				buffer2[23:0] <= 0;
		end
		buffer_enable <= next_buffer_enable;
	end
end

generate
	for (i = 23; i<143; i=i+24)
	always_ff@(posedge clk, negedge n_rst)
	begin
		if (1'b0 == n_rst)
		begin
			buffer1[i+24-:24] <= 0;
			buffer2[i+24-:24] <= 0;
		end
		else
		begin
			if (pixel_done)
			begin
				if (!buffer_enable)
					buffer1[i+24-:24] <= buffer1[i-:24];
				else
					buffer2[i+24-:24] <= buffer2[i-:24];
			end
			else if (master_writeresponsevalid)
			begin
				if (buffer_enable)
					buffer1[i+24-:24] <= buffer1[i-:24];
				else
					buffer2[i+24-:24] <= buffer2[i-:24];
			end
		end
	end
endgenerate

assign master_writedata = buffer_enable ? {8'h00,buffer1[143:119]} : {8'h00, buffer2[143:119]};
assign next_buffer_enable = done_load_write ? buffer_enable ? 0 : 1 : buffer_enable ? 1 : 0;

flex_counter #(4) count_load
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(done_load_write),
	.count_enable(pixel_done),
	.rollover_val(4'd6),
	.rollover_flag(done_load_write),
	.count_out()

);

flex_counter #(4) count_write
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(done_write),
	.count_enable(master_writeresponsevalid),
	.rollover_val(4'd6),
	.rollover_flag(done_write),
	.count_out()
);

endmodule