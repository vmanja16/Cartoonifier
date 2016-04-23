module mean_average (
input wire         clk,
input wire         n_rst,
input wire         isEdge,
input wire [215:0] pixelData,
output reg [23:0]  f_pixel
);

reg [7:0] r_avg, g_avg, b_avg;
reg [7:0] nxt_r_avg, nxt_g_avg, nxt_b_avg;
reg [23:0] nxt_rgb_avg, rgb_avg;
reg [23:0] nxt_f_pixel;
wire [7:0] r0,r1,r2,r3,r5,r6,r7,r8,b0,b1,b2,b3,b5,b6,b7,b8,g0,g1,g2,g3,g5,g6,g7,g8;
reg [7:0] r01,r23,r56,r78,g01,g23,g56,g78,b01,b23,b56,b78, r0123, r5678, b0123, b5678, g0123, g5678;

// TODO: on Enable (x clock cycles to process 1 3x3 frame): write f_pixel and shift in new pixelData


always_ff @ (posedge clk) begin
  if (n_rst == 0) begin 
    r_avg   <= 0;
    g_avg   <= 0;
    b_avg   <= 0;
    rgb_avg <= 0;
    f_pixel <= 0;
  end
  else begin
    r_avg   <= nxt_r_avg;
    g_avg   <= nxt_g_avg;
    b_avg   <= nxt_b_avg;
    rgb_avg <= nxt_rgb_avg;
    f_pixel <= nxt_f_pixel;
  end
end


// Calculate nxt_f_pixel
always_comb begin
  if (isEdge) nxt_f_pixel = 0; // turn pixel black on edge
  else begin
    if (f_pixel == 0) nxt_f_pixel = rgb_avg;
	 else begin nxt_f_pixel = {
	   ( (nxt_f_pixel[23:16]>>1) + (rgb_avg[23:16]>>1) ), // avg red
	   ( (nxt_f_pixel[15:8] >>1) + (rgb_avg[15:8]>>1)  ), // avg green
	   ( (nxt_f_pixel[7:0]  >>1) + (rgb_avg[7:0]>>1)   )};  // avg blue
	 end
  end


end
// Calculate nxt_rgb_avg
always_comb begin 
   nxt_rgb_avg = {r_avg, g_avg, b_avg}; 
end
// Calculate nxt_r_avg
always_comb begin
  nxt_r_avg = r_avg;
	r01 = r0>>3 + r1>>3;	
	r23 = r2>>3 + r3>>3;
	r56 = r5>>3 + r6>>3;
	r78 = r7>>3 + r8>>3;
	r0123 = r01+r23;
	r5678 = r56+r78;
	nxt_r_avg = r0123+r5678;  
end
// Calculate nxt_g_avg
always_comb begin
  nxt_g_avg = g_avg;
	g01   = g0>>3 + g1>>3;	
	g23   = g2>>3 + g3>>3;
	g56   = g5>>3 + g6>>3;
	g78   = g7>>3 + g8>>3;
	g0123 = g01+g23;
	g5678 = g56+g78;
	nxt_g_avg = g0123+g5678;
end
// Calculate nxt_b_avg
always_comb begin
   nxt_b_avg = b_avg;
	b01   = b0>>3 + b1>>3;	
	b23   = b2>>3 + b3>>3;
	b56   = b5>>3 + b6>>3;
	b78   = b7>>3 + b8>>3;
	b0123 = b01+b23;
	b5678 = b56+b78;
	nxt_b_avg = b0123+b5678;

end

assign r0 = pixelData[215:208];
assign g0 = pixelData[207:200];
assign b0 = pixelData[199:192];
assign r1 = pixelData[191:184];
assign g1 = pixelData[183:176];
assign b1 = pixelData[175:168];
assign r2 = pixelData[167:160];
assign g2 = pixelData[159:152];
assign b2 = pixelData[151:144];
assign r3 = pixelData[143:136];
assign g3 = pixelData[135:128];
assign b3 = pixelData[127:120];
//reg r5 = pixelData[119:112];
//reg g5 = pixelData[111:104];
//reg b5 = pixelData[103:96];
assign r5 = pixelData[95:88];
assign g5 = pixelData[87:80];
assign b5 = pixelData[79:72];
assign r6 = pixelData[71:64];
assign g6 = pixelData[63:56];
assign b6 = pixelData[55:48];
assign r7 = pixelData[47:40];
assign g7 = pixelData[39:32];
assign b7 = pixelData[31:24];
assign r8 = pixelData[23:16];
assign g8 = pixelData[15:8];
assign b8 = pixelData[7:0];

endmodule


