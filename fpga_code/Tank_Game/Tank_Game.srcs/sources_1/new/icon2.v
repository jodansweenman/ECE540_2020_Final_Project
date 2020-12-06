`timescale 1ns / 1ps

module icon2( 
    input wire [11:0] pixel_column,   
    input wire [11:0] pixel_row,      
    input wire [7:0] LocX_reg,        
    input wire [7:0] LocY_reg,        
    input wire [7:0] BotInfo_reg,     
    input wire clk,
    input wire reset,
    input wire train_hit,
    output reg [11:0]icon,
    output reg icon_flag,
    output reg burst,
    output reg train_reset
    ); 
    
    wire [11:0] col,row;        
    assign col = LocX_reg * 8;  
    assign row = LocY_reg * 6;    

    wire [11:0] train_N;   
    wire [11:0] train_E;  
    wire [11:0] train_S;  
    wire [11:0] train_W; 
    wire [11:0] boom; 
    reg [7:0] read_addr;
    reg [31:0] counter;
    
    boom train_boom(
       .clka(clk),
       .ena(burst),
       .addra(read_addr),
       .douta(boom)
    );
    
    Train_N mytrain_N(
       .clka(clk),
       .ena(~burst),
       .addra(read_addr),
       .douta(train_N)
    );
    Train_E mytrain_E(
       .clka(clk),
       .ena(~burst),
       .addra(read_addr),
       .douta(train_E)
    );
    Train_S mytrain_S(
       .clka(clk),
       .ena(~burst),
       .addra(read_addr),
       .douta(train_S)
    );
    Train_W mytrain_W(
       .clka(clk),
       .ena(~burst),
       .addra(read_addr),
       .douta(train_W)
    );  

    always @(posedge clk) begin
        if (!reset)begin
            burst <= 1'b0;                                              //After reset, burst signal is 0 
            counter <= 1'b0;
            train_reset <= 1'b0;                                        //After reset, red_reset signal is 0
        end
        else if (train_hit) begin
            burst <= 1'b1;       
            counter <= 1'b0;
        end                                                             //When the red tank is hit, the burst signal sets
        else if ((counter==32'h2FFFFFF)&&(burst==1'b1))begin            //When the tank bursts for a while 
            burst <= 1'b0;                                              // burst signal clears
            train_reset <= 1'b1;  
            counter <= 1'b1;                                            // red_reset signal sets
        end
        else if ((counter==32'h10)&&(train_reset==1'b1))                  //the red_reset signal delays for a while
            train_reset <= 1'b0;
        else begin
            counter<=counter+1'b1;
            burst <= burst;
        end
    end  
     
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
              3'b000: begin
                      icon <= burst ? boom : train_N;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b010: begin
                      icon <= burst ? boom : train_E;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b100: begin
                      icon <= burst ? boom : train_S;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b110: begin
                      icon <= burst ? boom : train_W;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
           endcase
     end
     else icon_flag <= 1'b0;
   end
endmodule