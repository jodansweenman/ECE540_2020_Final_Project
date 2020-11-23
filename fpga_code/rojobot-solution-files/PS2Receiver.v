`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: 
// Create Date: 03/03/2015 09:33:36 PM
// Design Name: 
// Module Name: PS2Receiver
// Project Name: Nexys4DDR Keyboard Demo
// Target Devices: Nexys4DDR
// Tool Versions: 
// Description: PS2 Receiver module used to shift in keycodes from a keyboard plugged into the PS2 port
// 
// Dependencies: Digilent Inc
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////
module PS2Receiver(
    input clk,      // 50MHz clock
    input kclk,     // keyboard clock
    input kdata,
    output [15:0] keycodeout
    );
    
    wire kclkf, kdataf;
    reg [7:0]datacur;
    reg [7:0]dataprev;
    reg [3:0]cnt;
    reg [15:0]keycode;
    reg flag;
    
    initial begin
        keycode[15:0]<=16'h0000;
        cnt<=4'b0000;
        flag<=1'b0;
    end
    
debouncer debounce(
    .clk(clk),
    .I0(kclk),
    .I1(kdata),
    .O0(kclkf),
    .O1(kdataf)
);
    
always@(negedge(kclkf))begin
    case(cnt)
    0:;//Start bit
    1:datacur[0]<=kdataf;
    2:datacur[1]<=kdataf;
    3:datacur[2]<=kdataf;
    4:datacur[3]<=kdataf;
    5:datacur[4]<=kdataf;
    6:datacur[5]<=kdataf;
    7:datacur[6]<=kdataf;
    8:datacur[7]<=kdataf;
    9:flag<=1'b1;
    10:flag<=1'b0;
    
    endcase
        if(cnt<=9) cnt<=cnt+1;
        else if(cnt==10) cnt<=0;
        
end

//////////////////////////////////////////////////
// Break code:               F0  -   11110000   //
// ENTER:                    5A  -   01011010   //
// TANK:  UP     -   W   -   1D  -   00011101   //
//        DOWN   -   S   -   1B  -   00011011   //
//        LEFT   -   A   -   1C  -   00011100   //
//        RIGHT  -   D   -   23  -   00100011   //
//        BULLET -   Q   -   15  -   00010101   //
// TRAIN: UP     -   I   -   43  -   01000011   //
//        DOWN   -   K   -   42  -   01000010   //
//        LEFT   -   J   -   3B  -   00111011   //
//        RIGHT  -   L   -   4B  -   01001011   //
//        BULLET -   U   -   3C  -   00111100   //
//////////////////////////////////////////////////

always @(posedge flag) begin
      // tank control
      if(datacur == 8'h1d || datacur == 8'h1b || datacur == 8'h1c || datacur == 8'h23 || datacur == 8'h15 || datacur == 8'h5a) begin
            if(dataprev == 8'hf0 && datacur != dataprev)
                keycode[7:0] <= 8'h0;
            else 
                keycode[7:0] <= datacur;
      end
      // train control 
      if(datacur == 8'h43 || datacur == 8'h42 || datacur == 8'h3b || datacur == 8'h4b || datacur == 8'h3c) begin
            if(dataprev == 8'hf0 && datacur != dataprev)
                keycode[15:8] <= 8'h0;
            else 
                keycode[15:8] <= datacur;
      end 
      dataprev<=datacur;

end

assign keycodeout=keycode;
    
endmodule