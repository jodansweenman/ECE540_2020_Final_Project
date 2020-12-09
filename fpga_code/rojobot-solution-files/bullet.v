`timescale 1ns / 1ps


module bullet(             
    input wire [11:0]pixel_row,       
    input wire [11:0]pixel_column,      
    output reg bullet_flag,               //bullet flag
    output reg [11:0] bullet_color,    
    output reg burst,                     //the opponent tank is hit
    input wire [7:0]LocX_reg,             //LocX_reg signal from IO_BotInfo
    input wire [7:0]LocY_reg,             //LocY_reg signal from IO_BotInfo
    input wire [7:0]BotInfo_reg,          //orientation of rojobot.
    input wire clk,    
    input wire biu,                       //shots signal
    input wire reset,
    input wire [1:0]icon_op,              //The opponent tank icon flag
    input wire [1:0]world_pixel           //the world map pixel
    );
    
    reg [11:0] pixelr_bul, pixelc_bul;    //to record the starting coordinates of bullet
    reg [11:0] row, col;                  //to record the coordinates of the shot time (first start time)
    reg [31:0] counter;                   //counter for delay
    reg [31:0]times;                      //record the times of bullet movement
    reg stop;                             //the stop flag is determine when the bullet stops to display
    reg [2:0] ori;                        //record the orientation of bullet (the orientation of tank at the shooting time)

    // Get stop and burst signal 
    always @(posedge clk) begin          
        if (!reset)begin
            stop <= 1'b1;                          //At beginning, the stop flag is 1
            burst <= 1'b0;                         //At beginning, the hit signal is 0
        end
        else if (biu==1'b1) begin                  //When the tank shoot
            stop <= 1'b0;                          //When the stop flag is 0
        end 
        else if ((bullet_flag == 1'b1) && (world_pixel == 2'b10)) begin  //When the stop keeps being 0 until the bullet meet the wall
            stop <= 1'b1;
        end
        else if ((bullet_flag == 1'b1) && (icon_op == 2'b01))begin       //When the stop keeps being 0 until the bullet meet the opponemt tank
            stop <= 1'b1;
            burst <= 1'b1;                                              //When bullet meets the oppoment tank, set the burst signal to show the opponemt is hit
        end
        else begin
            stop <= stop;
            burst <= 1'b0;
        end
    end


    // Change the starting coordinates to achive the movement of bullet
    always@ (posedge clk) begin
        if ((biu==1'b1)&&(stop==1'b1))begin         //At the shooting time 
            ori <= BotInfo_reg[2:0];                    //recore the orientation of the tank
            case (BotInfo_reg[2:0])                     //according the orientation of the tank, set the first starting coordinates for bullet. The bullet should show up in the front of tank
                3'b000:  begin //North
                pixelr_bul<=(LocY_reg * 6)-24 ;
                pixelc_bul<=(LocX_reg << 3) +6 ;
                row <= (LocY_reg * 6)-24 ;
                col <= (LocX_reg << 3) +6 ;
                times <= 1'b0;
                counter <= 1'b0;
                end
                3'b010:  begin//East
                pixelr_bul <= (LocY_reg * 6)+6 ;
                pixelc_bul <= (LocX_reg << 3) +36 ;
                row <= (LocY_reg * 6)+6 ;
                col <= (LocX_reg << 3) +36 ;
                times <= 1'b0;
                counter <= 1'b0;
                end
                3'b100:   begin//South
                pixelr_bul <= (LocY_reg * 6)+36 ;
                pixelc_bul <= (LocX_reg << 3) +6 ;
                row <= (LocY_reg * 6)+36 ;
                col <= (LocX_reg << 3) +6 ;
                times <= 1'b0;
                counter <= 1'b0;
                end		       
                3'b110:   begin//West
                pixelr_bul <= (LocY_reg * 6)+6 ;
                pixelc_bul <= (LocX_reg << 3) -24 ;
                row <= (LocY_reg * 6)+6 ;
                col <= (LocX_reg << 3) -24 ;
                times <= 1'b0;
                counter <= 1'b0;
                end
            endcase
        end
        else if ((counter==32'h1EFFFF) && (stop==1'b0) )begin //After delay, make the bullet move automatically
            case (ori)
                    3'b000:  begin //North
                    pixelr_bul <= row-(6'd10*times);
                    pixelc_bul <= col;
                    counter <= 1'b0;
                    times <= times+1'b1;
                    end
                    3'b010:  begin//East
                    pixelc_bul <= col+(6'd10*times);
                    pixelr_bul <= row;
                    counter <= 1'b0;
                    times <= times+1'b1;
                    end
                    3'b100:   begin//South
                    pixelr_bul <= row+(6'd10*times);
                    pixelc_bul <= col;
                    counter <= 1'b0;
                    times <= times+1'b1;
                    end		       
                    3'b110:   begin//West
                    pixelc_bul <= col-(6'd10*times);
                    pixelr_bul <= row;
                    counter <= 1'b0;
                    times <= times+1'b1;
                    end
                    default: begin
                    pixelr_bul <= pixelr_bul;
                    pixelc_bul <= pixelc_bul;
                counter <= 1'b0;
                times <= times+1'b1;
                end
            endcase
        end
    else begin
        pixelr_bul <= pixelr_bul;
        pixelc_bul <= pixelc_bul;
        counter <= counter+1'b1;
        times <= times;
        ori <= ori ;
        row <= row;
        col <= col;
    end
 end


reg [4:0] addr_r;             // address of row 0-31
reg [4:0] addr_c;             // address of col 0-31
wire [11:0] bullet_rom ;      //12-bit rom used to store the pixel data of bullet icon

reg [8:0] addr = 11'd0;       //address for read rom

bullet_up    bullet_up ( .clka(clk), .ena(~stop), .addra(addr), .douta (bullet_rom));  
	
     //to get the bullet flag and bullet color according to the recored orientation
always @(posedge clk) begin
if((stop == 1'b0) &&(pixel_column >= pixelc_bul) && (pixel_column <= pixelc_bul + 6'd19) && (pixel_row >= pixelr_bul) && (pixel_row <= pixelr_bul + 6'd19))
    begin
    case(ori)
    3'b000: begin  //North
            addr_r <= pixel_row-pixelr_bul;             //Row address = current dgt row coordinate - starting row coordinate
            addr_c <= pixel_column-pixelc_bul;          //Column address = current dgt col coordinate - starting col coordinate
            addr <= addr_r * 5'd20+addr_c;              //combine the row address and column address
            bullet_color <= bullet_rom;                    //bullet color is read from the bullet color rom
            bullet_flag <= (bullet_rom==12'hfff)?1'b0:1'b1;  //If the icon color is white, icon flag is 0, if not, the icon flag is 1
            end

    3'b010: begin  //East
            addr_r <= pixel_row-pixelr_bul;
            addr_c <= 5'd19-(pixel_column-pixelc_bul);
            addr <= addr_c * 5'd20+addr_r;
            bullet_color <= bullet_rom;
            bullet_flag <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end

    3'b100: begin  //South
            addr_r <= 5'd19-(pixel_row-pixelr_bul);
            addr_c <= 5'd19-(pixel_column-pixelc_bul);
            addr <= addr_r * 5'd20+addr_c;
            bullet_color <= bullet_rom;
            bullet_flag <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end

    3'b110: begin  //West
            addr_r <= 5'd19-(pixel_row-pixelr_bul);
            addr_c <= pixel_column-pixelc_bul;
            addr <= addr_c * 5'd20+addr_r;
            bullet_color <= bullet_rom;
            bullet_flag <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end
    endcase
    end
else 
    bullet_flag <= 1'b0; //icon is transparent if icon is out of specific range.
end 

endmodule