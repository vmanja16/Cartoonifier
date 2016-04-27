`timescale 1ns / 100ps

module tb_intensity();
// Define parameters
parameter CLK_PERIOD	= 2; //50 MHZ
parameter NUM_TESTS 	= 9;
parameter MAX_TEST_BIT = NUM_TESTS -1;
parameter MAX_OUTPUT_BIT = 71;
parameter MAX_INPUT_BIT = 215;

//  DUT inputs
reg tb_clk;
reg tb_n_rst;
reg [MAX_INPUT_BIT:0] tb_pixelData;
reg tb_intensity_enable;
reg tb_edgedetect_enable;

// DUT outputs
wire [MAX_OUTPUT_BIT:0] tb_iGrid;

// Test Bench Debug Signals
integer tb_test_case, i;
reg [7:0] r0, r1, r2, r3, r4,r5,r6,r7,r8;
reg [7:0] g0, g1, g2, g3 ,g4,g5,g6,g7,g8;
reg [7:0] b0, b1, b2 ,b3 ,b4,b5,b6,b7,b8;
reg [7:0] I0,I1, I2, I3, I4, I5, I6, I7, I8;

reg [71:0] test_1 = {
8'd20, 8'd20, 8'd40, 8'd60, 8'd80, 8'd100, 8'd120, 8'd144, 8'd160};

reg [71:0] test_2 = {
8'd12, 8'd24, 8'd48, 8'd60, 8'd72, 8'd84, 8'd96, 8'd155, 8'd189};

reg [71:0] test_3 = {
8'd5, 8'd22, 8'd42, 8'd65, 8'd99, 8'd100, 8'd210, 8'd200, 8'd164};

// Test Case expected outputs
reg [MAX_OUTPUT_BIT:0] tb_expected_iGrid;

intensity DUT ( .clk(tb_clk), .n_rst(tb_n_rst), .pixelData(tb_pixelData), .iGrid(tb_iGrid), .intensity_enable(tb_intensity_enable), .edgedetect_enable(tb_edgedetect_enable) );

always
begin : CLK_GEN
	tb_clk = 1'b0;
	#(CLK_PERIOD / 2);
	tb_clk = 1'b1;
	#(CLK_PERIOD / 2);
end




initial begin
assign r0 = tb_pixelData[215:208];
assign g0 = tb_pixelData[207:200];
assign b0 = tb_pixelData[199:192];
assign r1 = tb_pixelData[191:184];
assign g1 = tb_pixelData[183:176];
assign b1 = tb_pixelData[175:168];
assign r2 = tb_pixelData[167:160];
assign g2 = tb_pixelData[159:152];
assign b2 = tb_pixelData[151:144];
assign r3 = tb_pixelData[143:136];
assign g3 = tb_pixelData[135:128];
assign b3 = tb_pixelData[127:120];
assign r4 = tb_pixelData[119:112];
assign g4 = tb_pixelData[111:104];
assign b4 = tb_pixelData[103:96];
assign r5 = tb_pixelData[95:88];
assign g5 = tb_pixelData[87:80];
assign b5 = tb_pixelData[79:72];
assign r6 = tb_pixelData[71:64];
assign g6 = tb_pixelData[63:56];
assign b6 = tb_pixelData[55:48];
assign r7 = tb_pixelData[47:40];
assign g7 = tb_pixelData[39:32];
assign b7 = tb_pixelData[31:24];
assign r8 = tb_pixelData[23:16];
assign g8 = tb_pixelData[15:8];
assign b8 = tb_pixelData[7:0];

assign I0 = tb_iGrid[71:64];
assign I1 = tb_iGrid[63:56];
assign I2 = tb_iGrid[55:48];
assign I3 = tb_iGrid[47:40];
assign I4 = tb_iGrid[39:32];
assign I5 = tb_iGrid[31:24];
assign I6 = tb_iGrid[23:16];
assign I7 = tb_iGrid[15:8];
assign I8 = tb_iGrid[7:0];

tb_n_rst = 0;
@(posedge tb_clk);
tb_n_rst=1;
tb_test_case = 0;
tb_n_rst = 1;
tb_intensity_enable = 0;
tb_pixelData = 0;

//TEST 0
@(posedge tb_clk);
tb_test_case = 1;
tb_n_rst = 1;
tb_intensity_enable = 1;
tb_pixelData <= {test_1, test_3,test_2};
@(posedge tb_clk);
tb_intensity_enable = 0;
@(posedge tb_clk);
@(posedge tb_clk);
////////TEST 1
tb_test_case = 1;
tb_n_rst = 1;
@(posedge tb_clk);
tb_intensity_enable = 1;
tb_pixelData <= {test_3, test_2, test_1};
@(posedge tb_clk);
tb_intensity_enable = 0;
#(CLK_PERIOD);
#(CLK_PERIOD*2);
/////// TEST 2
tb_test_case = 2;
tb_n_rst = 1;
@(posedge tb_clk);
tb_intensity_enable = 1;
@(posedge tb_clk);
tb_intensity_enable = 0;
tb_pixelData <= {test_2, test_3, test_1};
#(CLK_PERIOD);
#(CLK_PERIOD*2);
//TEST 3
tb_test_case = 3;
tb_n_rst = 1;
@(posedge tb_clk);
tb_intensity_enable = 1;
tb_pixelData <= {test_1, test_2,test_3};
@(posedge tb_clk);
tb_intensity_enable = 0;
#(CLK_PERIOD);
#(CLK_PERIOD * 2);

//TEST 4
tb_test_case = 4;
tb_n_rst = 1;
@(posedge tb_clk);
tb_intensity_enable = 1;
tb_pixelData <= {test_3, test_1, test_2};
@(posedge tb_clk);
tb_intensity_enable = 0;

#(CLK_PERIOD);
#(CLK_PERIOD*2);
// TEST 5
tb_test_case = 5;
tb_n_rst = 1;
@(posedge tb_clk);
tb_intensity_enable = 1;
tb_pixelData <= {test_2, test_1, test_3};
@(posedge tb_clk);
tb_intensity_enable = 0;

#(CLK_PERIOD);
#(CLK_PERIOD*2);

end

endmodule
