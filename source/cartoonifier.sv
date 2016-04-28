module cartoonifier(

input wire clk,
input wire n_rst,
// input wire master_writeresponsevalid,
input wire master_waitrequest,
input wire [31:0] master_readdata,
input wire [31:0] master_readdatavalid,
input wire start,

// outputs
output logic [31:0] master_writedata,
output logic master_read_enable,
output logic master_write_enable,
output logic master_address

);
wire intensity_enable, edgedetect_enable, mean_average_enable, isEdge, pixel_done;
wire shift_enable8, shift_enable24, load_read_buffer;
wire done_write, done_read8, done_read24, done_load_read_buffer;
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


write_buffer(	.clk(clk),
		.n_rst(n_rst),
		.pixel_data(f_pixel),
		.pixel_done(pixel_done), 
		.master_waitrequest(master_waitrequest),
		// .master_writeresponsevalid(master_writereponsevalid),
		// outputs
		.master_writedata(master_writedata),
		.done_write(done_write)
		);


read_buffer (	.clk(clk),
		.n_rst(n_rst),
		.shift_enable8(shift_enable8),
		.shift_enable24(shift_enable24),
		.load_read_buffer(load_read_buffer),
		.master_readdata(master_readdata),
		.master_readdatavalid(master_readdatavalid),
		.pixel_done(pixel_done),
		// outputs
		.pixelData(pixelData),
		.done_read8(done_read8),
		.done_read24(done_read24),
		.done_load_read_buffer(done_load_read_buffer)
		);


rcu RCU (	.clk(clk),
		.n_rst(n_rst),
		.start(start),
		.pixel_done(pixel_done),
		.done_read24(done_read24),
		.done_shift8(done_shift8),
		.done_load_read_buffer(done_load_read_buffer),
		.done_write(done_write),
		.master_readdatavalid(master_readdatavalid),
		// outputs
		.master_write_enable(master_write_enable),
		.master_read_enable(master_read_enable),
		.master_address(master_address),
		.pixel_enable(intensity_enable),
		.shift_enable8(shift_enable8),
		.shift_enable24(shift_enable24),
		.load_read_buffer(load_read_buffer)	
		);

endmodule
