`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.08.2022 03:05:28
// Design Name: 
// Module Name: image_proc
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


module image_proc(
input axi_clk,
input axi_rst_n,
//slave interface
input in_data_valid,
input [7:0] in_data,
output out_data_ready,
//master interface
output out_data_valid,
output [7:0] out_data,
input in_data_ready,
//interrupt
output interrupt
    );
 
wire [71:0] pix_data;
wire pix_valid;
wire axis_prog_full;
wire [7:0] conv_data;
wire conv_data_valid;


assign out_data_ready = !axis_prog_full;
control ctrl(
    .in_clk(axi_clk),
    .in_rst(!axi_rst_n),
    .in_pix_data(in_data),
    .in_pix_valid(in_data_valid),
    .out_pix_data(pix_data),
    .out_pix_valid(pix_valid),
    .out_intr(interrupt)
    );
convolution conv(
    .in_clk(axi_clk),
    .in_9pixdata(pix_data),
    .in_9pixvalid(pix_valid),
    .out_convdata(conv_data),
    .out_valid(conv_data_valid)
    );

output_buffer out_Buf (
  .wr_rst_busy(),        // output wire wr_rst_busy
  .rd_rst_busy(),        // output wire rd_rst_busy
  .s_aclk(axi_clk),                  // input wire s_aclk
  .s_aresetn(axi_rst_n),            // input wire s_aresetn
  .s_axis_tvalid(conv_data_valid),    // input wire s_axis_tvalid
  .s_axis_tready(),    // output wire s_axis_tready
  .s_axis_tdata(conv_data),      // input wire [7 : 0] s_axis_tdata
  .m_axis_tvalid(out_data_valid),    // output wire m_axis_tvalid
  .m_axis_tready(in_data_ready),    // input wire m_axis_tready
  .m_axis_tdata(out_data),      // output wire [7 : 0] m_axis_tdata
  .axis_prog_full(axis_prog_full)  // output wire axis_prog_full
);

endmodule
