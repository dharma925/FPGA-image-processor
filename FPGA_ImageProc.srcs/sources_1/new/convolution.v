`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.08.2022 00:28:26
// Design Name: 
// Module Name: convolution
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module convolution(
input in_clk,
input [71:0] in_9pixdata,
input in_9pixvalid,
output reg [7:0] out_convdata,
output reg out_valid
    );
    
reg [7:0] kernel [8:0];
integer i;
reg [15:0] multiplicated[8:0];
reg [15:0] sumI;
reg [15:0] sumF;
reg mult_valid;
reg sum_valid;

initial 
begin
    kernel[0] = 1;
    kernel[1] = 2;
    kernel[2] = 1;
    kernel[3] = 2;
    kernel[4] = 4;
    kernel[5] = 2;
    kernel[6] = 1;
    kernel[7] = 2;
    kernel[8] = 1;
    
end

always@(posedge in_clk)
begin
    for(i=0;i<9;i=i+1)
        begin
            multiplicated[i] = kernel[i]*in_9pixdata[i*8+:8];
        end
    mult_valid <= in_9pixvalid;
end


always@(*) //commbinational circuit
begin
    sumI = 0; //blocking asignment
    for(i=0;i<9;i=i+1)
        begin
            sumI = sumI+multiplicated[i];
        end
end
    
always@(posedge in_clk)
begin
    sumF <= sumI;
    sum_valid <= mult_valid;
end

always@(posedge in_clk)
begin
    out_convdata <= sumF/16; //only integer part is returned in this operation.
    out_valid <= sum_valid;
end
endmodule
