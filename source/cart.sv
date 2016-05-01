module cart ( input logic clk, n_rst, intensity_enable,
	     input [215:0] pixelData,
	     output pixel_done,
	     output [23:0] f_pixel);
		
reg [71:0] iGrid;
wire isEdge, mean_average_enable;


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

endmodule
