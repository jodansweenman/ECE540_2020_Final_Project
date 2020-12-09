`timescale 1ns / 1ps

module icon #(
    // If 0 instantiate tank, if 1 then train...
    // ... Only really about which sprite is used
    TRAIN1_TANK0 = 0
    )( 
    input wire [11:0] pixel_column,   
    input wire [11:0] pixel_row,      
    input wire [7:0] LocX_reg,       
    input wire [7:0] LocY_reg,        
    input wire [7:0] BotInfo_reg,     
    input wire clk,
    input wire reset,
    input wire tank_hit,
    output reg [11:0]icon,
    output reg icon_flag,
    output reg burst,
    output reg tank_reset  
    ); 
    
    wire [11:0] col,row;        
    assign col = LocX_reg * 8;  
    assign row = LocY_reg * 6;    

// says tank_N but is tank or train depending on parameter
    wire [11:0] tank_N;   
    wire [11:0] tank_E;  
    wire [11:0] tank_S;  
    wire [11:0] tank_W;   
    wire [11:0] boom;
    reg [7:0] read_addr;
    reg [31:0] counter; 
    
    boom tank_boom(
       .clka(clk),
       .ena(burst),
       .addra(read_addr),
       .douta(boom)
    );

    // Generate art for tank/train
    // 0=Tank, 1=Train
    generate
        if (TRAIN1_TANK0 == 0) begin
            Tank_N mytank_N(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_N)
            );
            Tank_E mytank_E(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_E)
            );
            Tank_S mytank_S(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_S)
            );
            Tank_W mytank_W(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_W)
            );
        end
        if (TRAIN1_TANK0 == 1) begin
            Train_N mytrain_N(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_N)
            );
            Train_E mytrain_E(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_E)
            );
            Train_S mytrain_S(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_S)
            );
            Train_W mytrain_W(
            .clka(clk),
            .ena(~burst),
            .addra(read_addr),
            .douta(tank_W)
            );
        end
    endgenerate

    always @(posedge clk) begin
        if (!reset)begin
            burst <= 1'b0;                                              //After reset, burst signal is 0 
            counter <= 1'b0;
            tank_reset <= 1'b0;                                        //After reset, red_reset signal is 0
        end
        else if (tank_hit) begin
            burst <= 1'b1;       
            counter <= 1'b0;
        end                                                             //When the red tank is hit, the burst signal sets
        else if ((counter==32'h2FFFFFF)&&(burst==1'b1))begin            //When the tank bursts for a while 
            burst <= 1'b0;                                              // burst signal clears
            tank_reset <= 1'b1;  
            counter <= 1'b1;                                            // red_reset signal sets
        end
        else if ((counter==32'h10)&&(tank_reset==1'b1))                  //the red_reset signal delays for a while
            tank_reset <= 1'b0;
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
        else if ((pixel_row >= row && pixel_row < (row+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH)))
            read_addr <= read_addr+1'd1;
   end
   
   always @ (posedge clk) begin
     if ((pixel_row >= row && pixel_row < (row+WIDTH)) && (pixel_column >= col && pixel_column < (col+WIDTH))) begin
           case(BotInfo_reg[2:0])
              3'b000: begin
                      icon <= burst ? boom : tank_N;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b010: begin
                      icon <= burst ? boom : tank_E;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b100: begin
                      icon <= burst ? boom : tank_S;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
              3'b110: begin
                      icon <= burst ? boom : tank_W;
                      icon_flag <= (icon==12'hfff)?1'b0:1'b1;
                      end
           endcase
     end
     else icon_flag <= 1'b0;
   end
endmodule