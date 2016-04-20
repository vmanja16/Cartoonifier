module intensity 
(
	input wire clk, //CLK
	input wire n_rst,
	input wire [215:0] pixelData,
	output reg [71:0] iGrid // Intensity Output
);
wire [7:0] i0, i1, i2, i3, i4, i5, i6, i7, i8;
reg [71:0] next_grid;
always @(posedge clk) begin
  if (n_rst==0) iGrid <= 0;
  else iGrid <= next_grid;
end

icomb IN0 ( .rgb(pixelData[215:192]), .oIntensity(i0) );
icomb IN1 ( .rgb(pixelData[191:168]), .oIntensity(i1) );
icomb IN2 ( .rgb(pixelData[167:144]), .oIntensity(i2) );
icomb IN3 ( .rgb(pixelData[143:120]), .oIntensity(i3) );
icomb IN4 ( .rgb(pixelData[119:96]),  .oIntensity(i4) );
icomb IN5 ( .rgb(pixelData[95:72]),   .oIntensity(i5) );
icomb IN6 ( .rgb(pixelData[71:48]),   .oIntensity(i6) );
icomb IN7 ( .rgb(pixelData[47:24]),   .oIntensity(i7) );
icomb IN8 ( .rgb(pixelData[23:0]),    .oIntensity(i8) );

always_comb begin
  next_grid = {i0, i1, i2, i3, i4, i5, i6, i7, i8};
end
	
endmodule
