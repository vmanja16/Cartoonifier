module intensity 
(
	input wire clk, //CLK
	input wire n_rst,
	input wire [215:0] pixeldata,
	output reg [72:0] iGrid // Intensity Output
);
wire [7:0] i0, i1, i2, i3, i4, i5, i6, i7, i8;
reg [71:0] next_grid;
always @(posedge clk) begin
  if (n_rst==0) iGrid <= 0;
  else iGrid <= next_grid;
end

icomb I0 ( .rgb(pixeldata[215:192]), .oIntensity(i0) );
icomb I1 ( .rgb(pixeldata[191:168]), .oIntensity(i1) );
icomb I2 ( .rgb(pixeldata[167:144]), .oIntensity(i2) );
icomb I3 ( .rgb(pixeldata[143:120]), .oIntensity(i3) );
icomb I4 ( .rgb(pixeldata[119:96]),  .oIntensity(i4) );
icomb I5 ( .rgb(pixeldata[95:72]),   .oIntensity(i5) );
icomb I6 ( .rgb(pixeldata[71:48]),   .oIntensity(i6) );
icomb I7 ( .rgb(pixeldata[47:24]),   .oIntensity(i7) );
icomb I8 ( .rgb(pixeldata[23:0]),    .oIntensity(i8) );

always_comb begin
  next_grid = {i0, i1, i2, i3, i4, i5, i6, i7, i8};
end
	
endmodule
