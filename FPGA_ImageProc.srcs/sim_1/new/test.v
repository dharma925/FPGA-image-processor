`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.08.2022 09:57:48
// Design Name: 
// Module Name: test
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

`define headersize 1078
`define imgSize 512*512

module test(

    );

reg clk,reset;
reg [7:0] imgData;
integer file,file1,i;
reg imgDatavalid;
integer sentSize;
wire intr;

wire [7:0] outData;
wire outDataValid;
integer recievedData;


initial
begin
    clk = 1'b0;
    forever
    begin
        #5 clk = ~clk;
    end
end

//Keep reset of min 100ns
initial
begin
    sentSize = 0;
    imgDatavalid = 0;
    reset = 0;
    #100;
    reset = 1;
    #100;
    file = $fopen("deadpool_gray_512x512.bmp","rb");
    file1 = $fopen("blured_deadpool_gray_512x512.bmp","wb");
    for (i =0;i<`headersize;i=i+1)
    begin
        $fscanf(file,"%c",imgData);//1 byte at a time so %c
        $fwrite(file1,"%c",imgData);
    end
    
    for(i=0;i<4*512;i=i+1)
    begin
        @(posedge clk);
        $fscan(file,"%c",imgData);
        imgDatavalid <= 1'b1;
    end
    sentSize = 4*512;
    @(posedge clk);
    imgDatavalid <= 1'b0;
    while(sentSize < `imgSize)
    begin
        @(posedge intr);
        for(i=0;i<512;i=i+1)
        begin
            @(posedge clk);
            $fscan(file,"%c",imgData);
            imgDatavalid <= 1'b1;          
        end
        @(posedge clk);
        imgDatavalid <= 1'b0;
        sentSize = sentSize+512;
    end
    @(posedge clk);
    imgDatavalid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        imgData <= 1'b0;
        imgDatavalid <= 1'b1;          
    end
    @(posedge clk);
    imgDatavalid <= 1'b0;
    @(posedge intr);
    for(i=0;i<512;i=i+1)
    begin
        @(posedge clk);
        imgData <= 1'b0;
        imgDatavalid <= 1'b1;          
    end
    @(posedge clk);
    imgDatavalid <= 1'b0;
    $fclose(file);
end

always @(posedge clk)
begin
    if(outDataValid)
    begin
        $fwrite(file1,"%c",outData);
        recievedData = recievedData+1;
    end
    if (recievedData == `imgSize)
    begin
        $fclose(file1);
        $stop();
    end
end



image_proc dut(
    .axi_clk(clk),
    .axi_rst_n(reset),
//slave interface
    .in_data_valid(imgDatavalid),
    .in_data(imgData),
    .out_data_ready(),
//master interface
    .out_data_valid(),
    .out_data(outData),
    .in_data_ready(1'b1),
//interrupt
    .interrupt(intr)
    );
endmodule
