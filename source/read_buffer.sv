// $Id: $
// File name:   read_buffer.sv
// Created:     4/19/2016
// Author:      Russell Doctor
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Read Buffer

module read_buffer
(
input logic clk,
input logic n_rst,
input logic shift_enable8,
input logic shift_enable24,
input logic load_read_buffer,
input logic [23:0] master_readdata,
input logic master_readdatavalid,
output logic [215:0] pixelData,
output logic done_read8,
output logic done_read24,
output logic done_load_read_buffer
);

reg [191:0] line1;
reg [191:0] line2;
reg [191:0] line3;
reg [191:0] buffer;
genvar i;

assign pixelData = {line1[71:0], line2[71:0], line3[71:0]};

always_ff@(posedge clk, negedge n_rst)
begin
	if (1'b0 == n_rst)
	begin
		
	end
	else if (master_readdatavalid)
	begin
		if (shift_enable24)
		begin
			line1[23:0] <= master_readdata;
			line2[23:0] <= line1[191:167];
			line3[23:0] <= line2[191:167];
		end
		if (load_read_buffer)
			buffer[23:0] <= master_readdata;
	end
	else if (shift_enable8)
	begin
		buffer[23:0] <= 0;
		line1[23:0] <= buffer[191:167];
		line2[23:0] <= line1[191:167];
		line3[23:0] <= line2[191:167];
	end
end

generate
	for (i = 23; i<191; i=i+24)
	always_ff@(posedge clk, negedge n_rst)
	begin
		if (1'b0 == n_rst)
		begin
			
		end	
		else if (master_readdatavalid)
		begin
			if (shift_enable24)
			begin
				line1[i+24-:23] <= line1[i-:23];
				line2[i+24-:23] <= line2[i-:23];
				line3[i+24-:23] <= line3[i-:23];
			end
			if (load_read_buffer)
				buffer[i+24-:23] <= buffer[i-:23];
		end
		else if (shift_enable8)
		begin
			buffer[i+24-:23] <= buffer[i-:23];
			line1[i+24-:23] <= line1[i-:23];
			line2[i+24-:23] <= line2[i-:23];
			line3[i+24-:23] <= line3[i-:23];
		end
	end
endgenerate

flex_counter #(5) count_24
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(done_24),
	.count_enable(done_load_read_buffer && shift_enable24),
	.rollover_val(4'd3),
	.rollover_flag(done_read24)
);

flex_counter #(4) count_8
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(done_8),
	.count_enable(shift_enable8),
	.rollover_val(4'd8),
	.rollover_flag(done_shift8)
);

flex_counter #(4) count_load
(
	.clk(clk),
	.n_rst(n_rst),
	.clear(done_load),
	.count_enable((load_read_buffer || shift_enable24) && master_readdatavalid)),
	.rollover_val(4'd8),
	.rollover_flag(done_load_read_buffer)
);

endmodule