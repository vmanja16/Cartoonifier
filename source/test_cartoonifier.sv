module test_cartoonifier(

input wire clk,
input wire n_rst,
input wire master_writeresponsevalid,
//input wire master_waitrequest,
input wire [31:0] master_readdata,
input wire master_readdatavalid,
input wire [31:0] start,

// outputs
output logic [31:0] master_writedata,
output logic master_read_enable,
output logic master_write_enable,
//output logic master_address
output integer read_row, 
output integer read_col, 
output integer write_row,
output integer write_col,
output integer read_col_const, 
output integer write_col_const, 
output logic image_done
);

wire intensity_enable, edgedetect_enable, mean_average_enable, isEdge, pixel_done;
wire shift_enable8, shift_enable24, load_read_buffer;
wire done_write, done_shift8, done_read24, done_load_read_buffer;
reg [215:0] pixelData;
reg [71:0] iGrid;
reg [7:0] iThreshold;
reg [23:0] f_pixel;

intensity INT(	.clk(clk),
		.n_rst(n_rst),
		.intensity_enable(intensity_enable),
		.pixelData(pixelData),
		// outputs
		.edgedetect_enable(edgedetect_enable),
		.iGrid(iGrid)
		);

edgedetect E_D(	.clk(clk),
		.n_rst(n_rst),
		.edgedetect_enable(edgedetect_enable),
		.iGrid(iGrid),
		.iThreshold(8'd80),
		// outputs
		.mean_average_enable(mean_average_enable),
		.isEdge(isEdge)
		 );



mean_average MA(.clk(clk),
		.n_rst(n_rst),
		.mean_average_enable(mean_average_enable),
		.isEdge(isEdge),
		.pixelData(pixelData),
		// outputs
		.pixel_done(pixel_done),
		.f_pixel(f_pixel)
		);


write_buffer WB (	.clk(clk),
		.n_rst(n_rst),
		.f_pixel(f_pixel),
		.pixel_done(pixel_done), 
		//.master_waitrequest(master_waitrequest),
		.master_writeresponsevalid(master_writeresponsevalid),
		// outputs
		.master_writedata(master_writedata),
		.done_write(done_write)
		);


read_buffer RB(	.clk(clk),
		.n_rst(n_rst),
		.shift_enable8(shift_enable8),
		.shift_enable24(shift_enable24),
		.load_read_buffer(load_read_buffer),
		.master_readdata(master_readdata),
		.master_readdatavalid(master_readdatavalid),
		.pixel_done(pixel_done),
		// outputs
		.pixelData(pixelData),
		.done_shift8(done_shift8),
		.done_read24(done_read24),
		.done_load_read_buffer(done_load_read_buffer)
		);


test_rcu RCU (	.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.pixel_done(pixel_done),
		.done_read24(done_read24),
		.done_shift8(done_shift8),
		.done_load_read_buffer(done_load_read_buffer),
		.done_write(done_write),
		.master_readdatavalid(master_readdatavalid),
		.master_writeresponsevalid(master_writeresponsevalid),
		// outputs
		.master_write_enable(master_write_enable),
		.master_read_enable(master_read_enable),
		//.master_address(master_address),
		.pixel_enable(intensity_enable),
		.shift_enable8(shift_enable8),
		.shift_enable24(shift_enable24),
		.load_read_buffer(load_read_buffer),
		.read_row(read_row),
		.read_col(read_col),
		.write_row(write_row),
		.write_col(write_col),
		.read_col_const(read_col_const),
		.write_col_const(write_col_const),
		.image_done(image_done)
		);

endmodule