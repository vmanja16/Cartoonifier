module icomb 
(
	input wire [23:0] rgb,
	output wire [7:0] oIntensity
);
reg [7:0] r, g, b;
	
always_comb begin
  r = rgb[23:16];
  g = rgb[15:8];
  b = rgb[7:0];
end

//    I     =  .25R  +  .5G  + .25B
assign oIntensity = r>>2 + g>>1 + b>>2;
	
endmodule
