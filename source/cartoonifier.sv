module cartoonifier(
// need to pass master inputs (readdatavalid, writeresponsevalid, etc)
input wire clk,
input wire n_rst,
input wire 
input wire 

output 
output
output
output

);
wire intensity_enable, edgedetect_enable, mean_average_enable, isEdge, pixel_done;
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
		.iThreshold(8'd80);
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
		.f_pixel(f_pixel);
		);


write_buffer(.clk(clk) .n_rst(n_rst),);

reader_buffer(.clk(clk) .n_rst(n_rst),)

rcu RCU (	.clk(clk),
		.n_rst(n_rst),
		pixel_enable(intensity_enable),
		);