`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.08.2022 01:16:07
// Design Name: 
// Module Name: control
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


module control(
input in_clk,
input in_rst,
input [7:0] in_pix_data,
input in_pix_valid,
output reg [71:0] out_pix_data,
output out_pix_valid,
output reg out_intr
    );
   
reg [8:0] pixCount;
reg [1:0] current_write_lb;
reg [3:0] lb_valid;
reg [1:0] current_read_lb;
reg [3:0] read_data_lb;
reg [8:0] readCount;
reg read_lb;
reg [11:0] totalpixCount;
wire [23:0] lb0data;
wire [23:0] lb1data;
wire [23:0] lb2data;
wire [23:0] lb3data;
reg read_state, read_ln;

wire t0;
wire t1;
wire t2;
wire t3;


localparam IDLE = 'b0,
            READ_BUFFER = 'b1;

assign out_pix_valid = read_lb;

always@(posedge in_clk)
begin
    if (in_rst)
        totalpixCount <= 0;
    else
        begin
            if (in_pix_valid & !read_lb)
                totalpixCount <= totalpixCount +1;
            else if (!in_pix_valid & read_lb)
                totalpixCount <= totalpixCount -1;
        end
end

always@(posedge in_clk)
begin
    if (in_rst)
    begin
        read_state <= IDLE;
        read_lb <= 1'b0;
        out_intr <= 1'b0;
    end
    else
    begin
        case(read_state)
            IDLE:begin
                if (totalpixCount >= 1536)
                begin
                    read_lb <= 1'b1;
                    read_state <= READ_BUFFER;
                    out_intr <= 1'b0;
                end
            end
            READ_BUFFER:begin
                if (readCount == 511)
                begin
                    read_state <= IDLE;
                    read_lb <= 1'b0;
                    out_intr <= 1'b1;
                end
            end
        endcase
    end
end

always@(posedge in_clk)
begin
    if (in_rst)
        pixCount <= 0;
    else
        begin
            if (in_pix_valid)
                pixCount <= pixCount + 1;
        end
end

always@(posedge in_clk)
begin
    if (in_rst)
        current_write_lb <= 0;
    else 
    begin
        if (pixCount == 511 & in_pix_valid)
            current_write_lb <= current_write_lb + 1;
    end    
end

always@(*)
begin
    lb_valid = 4'b0;
    lb_valid[current_write_lb] = in_pix_valid;
end

always@(posedge in_clk)
begin
    if(in_rst)
        readCount <= 0;
    else
    begin
        if (read_ln)
            readCount <= readCount +1;
    end
end

always@(posedge in_clk)
begin
    if (in_rst)
    begin
        current_read_lb <= 0;
    end
    else
    begin
    // <Doubt here>
        if (readCount == 511 & read_lb) //511 doubt. The starting and ending pixel values can't be included.
            current_read_lb <= current_read_lb + 1;
    end
end

always@ (*)
begin
    case(current_read_lb)
    0: begin 
    out_pix_data = {lb2data,lb1data,lb0data};
    end
    1: begin
    out_pix_data = {lb3data,lb2data,lb1data};
    end
    2: begin
    out_pix_data = {lb0data,lb3data,lb2data};
    end
    3: begin
    out_pix_data = {lb1data,lb0data,lb3data};
    end
    endcase
end

always@(*)
begin
    case(current_read_lb)
    0: begin 
    read_data_lb[0] = read_lb;
    read_data_lb[1] = read_lb;
    read_data_lb[2] = read_lb;
    read_data_lb[3] = 1'b0;
    end
    1: begin
    read_data_lb[0] = 1'b0;
    read_data_lb[1] = read_lb;
    read_data_lb[2] = read_lb;
    read_data_lb[3] = read_lb;
    end
    2: begin
    read_data_lb[0] = read_lb;
    read_data_lb[1] = 1'b0;
    read_data_lb[2] = read_lb;
    read_data_lb[3] = read_lb;
    end
    3: begin
    read_data_lb[0] = read_lb;
    read_data_lb[1] = read_lb;
    read_data_lb[2] = 1'b0;
    read_data_lb[3] = read_lb;
    end
    endcase
end

assign t0 = read_data_lb[0];
assign t1 = read_data_lb[1];
assign t2 = read_data_lb[2];
assign t3 = read_data_lb[3];


linebuffer lb0(
    .in_clk(in_clk),
    .in_rst(in_rst),
    .in_data(in_pix_data),
    .in_valid(lb_valid[0]),
    .in_read(lb0data),
    .out_data(t0)
    );
    
linebuffer lb1(
    .in_clk(in_clk),
    .in_rst(in_rst),
    .in_data(in_pix_data),
    .in_valid(lb_valid[1]),
    .in_read(lb1data),
    .out_data(t1)
    );
    
linebuffer lb2(
    .in_clk(in_clk),
    .in_rst(in_rst),
    .in_data(in_pix_data),
    .in_valid(lb_valid[2]),
    .in_read(lb2data),
    .out_data(t2)
    );
    
linebuffer lb3(
    .in_clk(in_clk),
    .in_rst(in_rst),
    .in_data(in_pix_data),
    .in_valid(lb_valid[3]),
    .in_read(lb3data),
    .out_data(t3)
    );


endmodule
