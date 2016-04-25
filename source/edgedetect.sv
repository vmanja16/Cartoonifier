module edgedetect (
	input	wire	      clk,
	input	wire [71:0]	iGrid,
	input wire [7:0]  iThreshold,
	input wire        n_rst,
	input wire edgedetect_enable,
	output reg        isEdge, //0 if not edge, 1 if edge
	output reg	  mean_average_enable
	);
	wire	[7:0] left, right, top, btm, sum1, sum2, sum3, sum4;
	wire	[7:0] intensity [8:0];
	wire nxt_isEdge;
	reg wait_enable;
	
	always @ (posedge clk) begin
		if (n_rst == 0) begin 
		  isEdge <= 0;
		  wait_enable <=0;
		  mean_average_enable <= 0;
		end
		else begin 
  		  isEdge <= nxt_isEdge;
		  wait_enable <= edgedetect_enable; // wait_enable is to allow for edge calculation
 		  mean_average_enable <= wait_enable;
		end
		  
	end
	
	assign intensity[0] = iGrid[7:0];
	assign intensity[1] = iGrid[15:8];
	assign intensity[2] = iGrid[23:16];
	assign intensity[3] = iGrid[31:24];
	assign intensity[4] = iGrid[39:32];
	assign intensity[5] = iGrid[47:40];
	assign intensity[6] = iGrid[55:48];
	assign intensity[7] = iGrid[63:56];
	assign intensity[8] = iGrid[71:64];
	
	assign right = intensity[6] + (intensity[3]<<1) + intensity[0];
	assign left =  intensity[8] + (intensity[5]<<1) + intensity[2];
	assign top =   intensity[0] + (intensity[1]<<1) + intensity[2];
	assign btm =   intensity[6] + (intensity[7]<<1) + intensity[8];
	
	assign sum1 = right - left;
	assign sum2 = left  - right;
	assign sum3 = top   - btm;
	assign sum4 = btm   - top;
	
	assign nxt_isEdge = (( (sum1[7]==0) && (sum1 > iThreshold)) || 
                       ( (sum2[7]==0) && (sum2 > iThreshold)) ||
                       ( (sum3[7]==0) && (sum3 > iThreshold)) ||
                       ( (sum4[7]==0) && (sum4 > iThreshold)) );
	
endmodule
