`timescale 1ns / 1ps

module icon2( 
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

    wire [11:0] train_N;   
    wire [11:0] train_E;  
    wire [11:0] train_S;  
    wire [11:0] train_W;  
    reg [7:0] read_addr;

    Train_N mytrain_N(
       .clka(clk),
       .addra(read_addr),
       .douta(train_N)
    );
    Train_E mytrain_E(
       .clka(clk),
       .addra(read_addr),
       .douta(train_E)
    );
    Train_S mytrain_S(
       .clka(clk),
       .addra(read_addr),
       .douta(train_S)
    );
    Train_W mytrain_W(
       .clka(clk),
       .addra(read_addr),
       .douta(train_W)
    );  
    
    parameter WIDTH = 16;
    
   //assign read_addr = (pixel_row-row)*WIDTH + (pixel_column-col);

   always @ (posedge clk) begin
        if(read_addr == 255) 
            read_addr <= 8'd0;
        else if ((pixel_row >= row-60 && pixel_row < (row-60+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH)))
            read_addr <= read_addr+1'd1;
   end
      
   always @ (posedge clk) begin
     if ((pixel_row >= row-60 && pixel_row < (row-60+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH))) begin
           case(BotInfo_reg[2:0])
              3'b000: icon <= train_N;
              3'b010: icon <= train_E;
              3'b100: icon <= train_S;
              3'b110: icon <= train_W;
           endcase
     end
     else icon <= 0;
   end
endmodule