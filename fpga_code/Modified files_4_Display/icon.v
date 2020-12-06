//Train Icon module
//explosion detail added

module icon( // tank
    input [11:0] pixel_column,   //pixel_column signal from dtg module
    input [11:0] pixel_row,      //pixel_row signal from dtg module
    input [7:0] LocX_reg,        //LocX_reg signal from IO_BotInfo
    input [7:0] LocY_reg,        //LocY_reg signal from IO_BotInfo
    input [7:0] BotInfo_reg,     //This signal will tell us what the orientation of rojobot.
    input clk,
    input reset,
    input hit,                  //hit signal shows the  tank is hit
    output reg [1:0] icon,      //icon signal is a icon flag to determine whether display the icon up
    output reg [11:0]icon_c,    //icon_c signal is 12-bit icon color (RGB CODE)
    output reg burst,           //burst signal is to show whether the tank is hit and burst for a while
    output reg tank_reset      //tank_reset is used to reset the  tank rojobot to make it go back the initialization position     
    ); 
    wire [11:0] col,row;        
    assign col = LocX_reg << 3;  //Translate rojobot map 128 * 128 to the dgt size 1024 * 768 
    assign row = LocY_reg * 6;    
    
    reg [31:0]counter;            // counter for burst delay              
    reg [4:0] addr_r;             // address of row 0-31
    reg [4:0] addr_c;             // address of column 0-31
    wire [11:0] image_boom_rom;   //12-bit rom used to store the pixel data of burst icon 
    
    wire [1:0] image_rom ;        //2-bit rom used to store the pixel data of tank icon 
    
    reg [9:0] addr;               //address for read rom
 
   
    //Instantiate burst icon rom and read out the 12-bit burst icon color (RGB CODE)
    blk_mem_gen_4  boom_ROM2 ( .clka(clock), .ena(burst), .addra(addr), .douta(image_boom_rom));
    //Instantiate tank icon rom and read out the 2-bit tank icon color
    blk_mem_gen_3 blue_tank ( .clka(clk), .ena(~burst), .addra(addr), .douta(image_rom));
    reg [11:0] image_color_rom ;  //12-bit color code for tank icon(RGB CODE)
    //translate the 2-bit tank icon color to 12-bit RGB code
    always @ (*) begin
    case (image_rom)
        2'd0: image_color_rom = 12'hFFF; //white
        2'd1: image_color_rom = 12'h000; //black
        2'd2: image_color_rom = 12'h00F; //blue
        2'd3: image_color_rom = 12'h025; //gray
    endcase
    end
    
    //get the burst signal which is the hit signal with delay and tank_reset which should be set after the  tank completes burst.
    always @(posedge clk) begin
    if (!reset)begin
    burst <= 1'b0;                                              //After reset, burst signal is 0
    counter <= 1'b0;                                            
    tank_reset <= 1'b0;                                        //After reset, tank_reset signal is 0
    end
    else if (hit) begin
    burst <= 1'b1;                                              //When the  tank is hit, the burst signal sets
    counter <= 1'b0;                                            //Counter signal should begin to count
    end
    else if ((counter==32'h2FFFFFF)&&(burst==1'b1))begin        //When the tank bursts for a while 
    burst <= 1'b0;                                              // burst signal clears
    counter <= 1'b0;                                            // counter clears
    tank_reset <= 1'b1;                                        // tank_reset signal sets
    end
    else if ((counter==32'h10)&&(tank_reset==1'b1))begin       //the tank_reset signal delays for a while
    tank_reset <= 1'b0;
    end
    else begin
    counter<=counter+1'b1;                                      
    burst <= burst;
    end
    end
    
    //to get the icon flag and icon color according to the orientation of rojobot
    always @(posedge clk) begin
    if((pixel_column >= col) && (pixel_column <= (col + 6'd31)) && (pixel_row >= row) && (pixel_row <= (row + 6'd31))) //both icon are 32*32, limite the coordinates range into a 32 * 32 square from starting coordinates
        begin
        case(BotInfo_reg[2:0])
      3'b000: begin  //North
                addr_r <= pixel_row-row;                          //Row address = current dgt row coordinate - starting row coordinate
                addr_c <= pixel_column-col;                       //Column address = current dgt col coordinate - starting col coordinate
                addr <= {addr_r,addr_c};                          //combine the row address and column address
                icon_c <= burst?image_boom_rom:image_color_rom;   //If the burst signal sets, use burst icon color, if not, use tank icon color
                icon <= (icon_c==12'hfff)?1'b0:1'b1;              //If the icon color is white, icon flag is 0, if not, the icon flag is 1
                end

        3'b010: begin  //East
                addr_r <= pixel_row-row;
                addr_c <= 5'd31-(pixel_column-col);
                addr <= {addr_c,addr_r};
                icon_c <= burst?image_boom_rom:image_color_rom;
                icon <= (icon_c==12'hfff)?1'b0:1'b1;                                                   
                end
    
        3'b100: begin  //South
                addr_r <= 5'd31-(pixel_row-row);
                addr_c <= 5'd31-(pixel_column-col);
                addr <= {addr_r,addr_c};
                icon_c <= burst?image_boom_rom:image_color_rom;
                icon <= (icon_c==12'hfff)?1'b0:1'b1;
                end
    
        3'b110: begin  //West
                addr_r <= 5'd31-(pixel_row-row);
                addr_c <= pixel_column-col;
                addr <= {addr_c,addr_r};
                icon_c <= burst?image_boom_rom:image_color_rom;
                icon <= (icon_c==12'hfff)?1'b0:1'b1;
                end
        endcase
        end
    else 
        icon <= 1'b0; //icon is transparent if icon is out of specific range.
    end 
       
    endmodule
