`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2022 23:05:23
// Design Name: 
// Module Name: linebuffer
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


module linebuffer(
input in_clk,
input in_rst,
input [7:0] in_data,
input in_valid,
input in_read,
output [23:0] out_data
    );
    
reg [7:0] line [511:0]; //line buffer of 512 pixels 8bit each
reg [8:0] write_pointer = 0;  //log512 base 2
reg [8:0] read_pointer = 0;  //log512 base 2
always@(posedge in_clk)
begin
    if (in_valid)
        line[write_pointer] <= in_data;
    end
always@(posedge in_clk)
begin
    if (in_rst)
        write_pointer <= 'd0;
    else if (in_valid)
        write_pointer <= write_pointer + 'd1;
    end

assign out_data = {line[read_pointer],line[read_pointer+1],line[read_pointer+2]};

always@(posedge in_clk)
begin
    if (in_rst)
        read_pointer <= 'd0;
    else if (in_read)
        read_pointer <= read_pointer + 'd1;
    end


endmodule
