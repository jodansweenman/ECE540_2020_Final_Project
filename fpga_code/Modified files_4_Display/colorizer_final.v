

module colorizer_final(
    input clk,
    input [11:0] pixel_column, //pixel_column signal from dtg module
    input [11:0] pixel_row,    //pixel_row signal from dtg module
    input video_on,            //The signal to show video on
    input [1:0] world_pixel,   //World map pixel
    input [1:0] icon1_flag,    //tank icon1_flag  
    input [11:0]icon1,        //12 bit  tank icon1_flag color
    input [1:0] icon2_flag,   //  tank2 icon_flag 
    input [11:0] icon2,     //12 bit tank2 icon1_flag color
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B,
    input bull1_flag, bull2_flag,            // bullet flag
    input [11:0] bul_color,bul_color2, //bullet color 
    input [11:0]      title_color,
   // input [1:0]      map_color,   
    input wire frame1, frame2, frame3, frame4, frame5
    );
	
    reg [16:0]addr;          
    reg [8:0] addr_r,addr_c;
    wire [11:0] Initial;            // The initial picture
    wire [11:0] player1;
    wire [11:0] player2;
  
     
     
     blk_mem_gen_0 Initial_begin (.clka(clk), .addra(addr), .douta(Initial));      //Initial Frame rom
    // blk_mem_gen_2 player1_win (.clka(clk), .addra(addr), .douta(player1));        //player1 win
    // blk_mem_gen_lr player2_win (.clka(clk), .addra(addr), .douta(player2));       //player2 win
  

always @ (posedge clk)  begin
	if (video_on == 1'b0)                   //if the video is off, nothing will be shown
		{VGA_R, VGA_G, VGA_B} <= 12'h000;
	else begin
	if (frame1==1'b1)// When frame1 set, the game frame shows up 
	  
          begin       
            case({world_pixel,icon1_flag,icon2_flag,bull1_flag,bull2_flag})                //case statement start
            8'b00010000: {VGA_R, VGA_G, VGA_B} <= icon1;  
            8'b01010000: {VGA_R, VGA_G, VGA_B} <= icon1;
            8'b10010000: {VGA_R, VGA_G, VGA_B} <= icon1;
            8'b11010000: {VGA_R, VGA_G, VGA_B} <= icon1;
    
            8'b00000100: {VGA_R, VGA_G, VGA_B} <= icon2;  
            8'b01000100: {VGA_R, VGA_G, VGA_B} <= icon2;
            8'b10000100: {VGA_R, VGA_G, VGA_B} <= icon2;
            8'b11000100: {VGA_R, VGA_G, VGA_B} <= icon2;
    
            8'b00010100: {VGA_R, VGA_G, VGA_B} <= icon1;    
            8'b01010100: {VGA_R, VGA_G, VGA_B} <= icon1;
            8'b10010100: {VGA_R, VGA_G, VGA_B} <= icon1;
            8'b11010100: {VGA_R, VGA_G, VGA_B} <= icon1;
    
            8'b00000000: {VGA_R, VGA_G, VGA_B} <= 12'hFFF;  //Background
            8'b01000000: {VGA_R, VGA_G, VGA_B} <= 12'hF0F;  //secind Base
            8'b10000000: {VGA_R, VGA_G, VGA_B} <= 12'h840;  //Give the brick color to the obstacles
            8'b11000000: {VGA_R, VGA_G, VGA_B} <= 12'hF0F;  //first base
    
            8'b00010010: {VGA_R, VGA_G, VGA_B} <= bul_color;  //When the 1st tank  bullet flag has been set, give the color of 1st tank bullet
            8'b01010010: {VGA_R, VGA_G, VGA_B} <= bul_color;   
            8'b10010010: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b11010010: {VGA_R, VGA_G, VGA_B} <= bul_color;
    
            8'b00000110: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b01000110: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b10000110: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b11000110: {VGA_R, VGA_G, VGA_B} <= bul_color;
    
            8'b00000010: {VGA_R, VGA_G, VGA_B} <= bul_color; 
            8'b01000010: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b10000010: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b11000010: {VGA_R, VGA_G, VGA_B} <= bul_color;  
    
            8'b00010001: {VGA_R, VGA_G, VGA_B} <= bul_color2;  //When the 2nd tank bullet flag has been set, give the color of 2nd tank bullet
            8'b01010001: {VGA_R, VGA_G, VGA_B} <= bul_color2;
            8'b10010001: {VGA_R, VGA_G, VGA_B} <= bul_color2;
            8'b11010001: {VGA_R, VGA_G, VGA_B} <= bul_color2;
    
            8'b00000101: {VGA_R, VGA_G, VGA_B} <= bul_color2;  
            8'b01000101: {VGA_R, VGA_G, VGA_B} <= bul_color2;
            8'b10000101: {VGA_R, VGA_G, VGA_B} <= bul_color2;
            8'b11000101: {VGA_R, VGA_G, VGA_B} <= bul_color2;
    
            8'b00000001: {VGA_R, VGA_G, VGA_B} <= bul_color2;  
            8'b01000001: {VGA_R, VGA_G, VGA_B} <= bul_color2; 
            8'b10000001: {VGA_R, VGA_G, VGA_B} <= bul_color2; 
            8'b11000001: {VGA_R, VGA_G, VGA_B} <= bul_color2;  
    
            8'b00010011: {VGA_R, VGA_G, VGA_B} <= bul_color;   //When the 1st and 2nd tank  bullet flag has been set, give the color of 1st tank bullet
            8'b01010011: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b10010011: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b11010011: {VGA_R, VGA_G, VGA_B} <= bul_color;
    
            8'b00000111: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b01000111: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b10000111: {VGA_R, VGA_G, VGA_B} <= bul_color;
            8'b11000111: {VGA_R, VGA_G, VGA_B} <= bul_color;
    
            8'b00000011: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b01000011: {VGA_R, VGA_G, VGA_B} <= bul_color;  
            8'b10000011: {VGA_R, VGA_G, VGA_B} <= bul_color; 
            8'b11000011: {VGA_R, VGA_G, VGA_B} <= bul_color;  
    
            default: {VGA_R, VGA_G, VGA_B} <= 12'hfff; 
           endcase
	       end

	else if ((frame2 == 1'b1))begin        //If the frame2 has been set, show the initial frame
		addr_r <= pixel_row/3'd3;
		addr_c <= pixel_column/2'd2;
		addr <= {addr_r,addr_c};		
		{VGA_R, VGA_G, VGA_B} <= Initial ;
	    end

	else if (frame3 == 1'b1) begin          // If the frame3 has been set, show the player win screen 

         addr_r <= pixel_row/3'd3;
		 addr_c <= pixel_column/2'd2;
		 addr <= {addr_r,addr_c};	  
         {VGA_R, VGA_G, VGA_B}<= title_color;
	    end
	  
	end
  end
endmodule	
	