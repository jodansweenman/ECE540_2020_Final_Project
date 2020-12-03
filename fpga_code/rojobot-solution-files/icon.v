`timescale 1ns / 1ps

module icon( 
    input wire [11:0] pixel_column,   
    input wire [11:0] pixel_row,      
    input wire [7:0] LocX_reg,       
    input wire [7:0] LocY_reg,        
    input wire [7:0] BotInfo_reg,     
    input wire clk,
    input wire reset,
    output reg [11:0]icon     
    ); 
    
    wire [11:0] col,row;        
    assign col = LocX_reg * 8;  
    assign row = LocY_reg * 6;    

    wire [11:0] tank_N;   
    wire [11:0] tank_E;  
    wire [11:0] tank_S;  
    wire [11:0] tank_W;   
    reg [7:0] read_addr;

    Tank_N mytank_N(
       .clka(clk),
       .addra(read_addr),
       .douta(tank_N)
    );
    Tank_E mytank_E(
       .clka(clk),
       .addra(read_addr),
       .douta(tank_E)
    );
    Tank_S mytank_S(
       .clka(clk),
       .addra(read_addr),
       .douta(tank_S)
    );
    Tank_W mytank_W(
       .clka(clk),
       .addra(read_addr),
       .douta(tank_W)
    );
    
   parameter WIDTH = 16;
   
   //assign read_addr = (pixel_row-row)*WIDTH + (pixel_column-col);

   always @ (posedge clk) begin
        if(read_addr == 255) 
            read_addr <= 8'd0;
        else if ((pixel_row >= row && pixel_row < (row+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH)))
            read_addr <= read_addr+1'd1;
   end
   
   always @ (posedge clk) begin
     if ((pixel_row >= row && pixel_row < (row+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH))) begin
           case(BotInfo_reg[2:0])
              3'b000: icon <= tank_N;
              3'b010: icon <= tank_E;
              3'b100: icon <= tank_S;
              3'b110: icon <= tank_W;
           endcase
     end
     else icon <= 0;
   end
endmodule