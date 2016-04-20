module icomb 
(
	input wire [23:0] rgb,
	output wire [7:0] oIntensity
);

//    I     =  .25R  +  .5G  + .25B
assign oIntensity = (rgb[23:16] >> 2) + (rgb[15:8] >> 1) + (rgb[7:0] >> 2);
endmodule
