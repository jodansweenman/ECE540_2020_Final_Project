module colorizer_v2(
    input clk,
    input [11:0]      pixel_column, 
    input [11:0]      pixel_row,    
    input [11:0]      icon1,                    // tank color
    input [11:0]      icon2,                    // train color
    input             icon1_flag,               // tank flag
    input             icon2_flag,               // train flag
    input [11:0]      bullet1,                  // tank bullet color     
    input [11:0]      bullet2,                  // train bullet color
    input             bullet1_flag,             // tank bullet flag
    input             bullet2_flag,             // train bullet flag
    input             frame1,                   // initial screen
    input             frame2,                   // map
    input             frame3,                   // tank win
    input             frame4,                   // train win
    //input wire [4:0]  sw,                       // for testing purpose
    input [1:0]       world_pixel,
    input             video_on,
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B
);

      reg [15:0] addr;          
      reg [7:0] addr_r,addr_c;
      wire [11:0] Initial;            // The initial picture
      wire [11:0] player1;
      wire [11:0] player2;
      GameScreen Initial_begin (.clka(clk), .ena(frame1), .addra(addr), .douta(Initial));         //Initial Frame rom
      TankWin player1_win (.clka(clk), .ena(frame3), .addra(addr), .douta(player1));              //player1 win
      TrainWin player2_win (.clka(clk), .ena(frame4), .addra(addr), .douta(player2));             //player2 win
   
 always @ (posedge clk)  begin
	if (video_on == 1'b0)                   //if the video is off, nothing will be shown
		{VGA_R, VGA_G, VGA_B} <= 12'h000;
	else begin
	if (frame1==1'b1) begin
		addr_r <= pixel_row/3'd3;             // scaling 256*256 pixels
		addr_c <= pixel_column/3'd4;
		addr <= {addr_r,addr_c};		
		{VGA_R, VGA_G, VGA_B} <= Initial;	
	end
	else if (frame2==1'b1)      // game screen
          begin       
            case({world_pixel,icon1_flag,icon2_flag,bullet1_flag,bullet2_flag})                //case statement start
            6'b001000: {VGA_R, VGA_G, VGA_B} <= icon1;  
            6'b101000: {VGA_R, VGA_G, VGA_B} <= icon1;
    
            6'b000100: {VGA_R, VGA_G, VGA_B} <= icon2;  
            6'b100100: {VGA_R, VGA_G, VGA_B} <= icon2;
    
            6'b001100: {VGA_R, VGA_G, VGA_B} <= icon1;    
            6'b101100: {VGA_R, VGA_G, VGA_B} <= icon1;
    
            6'b000000: {VGA_R, VGA_G, VGA_B} <= 12'hFFF;  // Background
            6'b100000: {VGA_R, VGA_G, VGA_B} <= 12'h840;  // obstruction
  
            6'b001010: {VGA_R, VGA_G, VGA_B} <= bullet1;  //tank bullet color
            6'b101010: {VGA_R, VGA_G, VGA_B} <= bullet1;
    
            6'b000110: {VGA_R, VGA_G, VGA_B} <= bullet1;
            6'b100110: {VGA_R, VGA_G, VGA_B} <= bullet1;
    
            6'b000010: {VGA_R, VGA_G, VGA_B} <= bullet1; 
            6'b100010: {VGA_R, VGA_G, VGA_B} <= bullet1; 
    
            6'b001001: {VGA_R, VGA_G, VGA_B} <= bullet2;   //train bullet color
            6'b101001: {VGA_R, VGA_G, VGA_B} <= bullet2;
    
            6'b000101: {VGA_R, VGA_G, VGA_B} <= bullet2;
            6'b100101: {VGA_R, VGA_G, VGA_B} <= bullet2;
    
            6'b000001: {VGA_R, VGA_G, VGA_B} <= bullet2; 
            6'b100001: {VGA_R, VGA_G, VGA_B} <= bullet2;

            6'b001011: {VGA_R, VGA_G, VGA_B} <= bullet1;   //tank bullet color
            6'b101011: {VGA_R, VGA_G, VGA_B} <= bullet1;
    
            6'b000111: {VGA_R, VGA_G, VGA_B} <= bullet1; 
            6'b100111: {VGA_R, VGA_G, VGA_B} <= bullet1;
    
            6'b000011: {VGA_R, VGA_G, VGA_B} <= bullet1;  
            6'b100011: {VGA_R, VGA_G, VGA_B} <= bullet1;
 
            default: {VGA_R, VGA_G, VGA_B} <= 12'hfff; 
          endcase
	end

	else if ((frame3 == 1'b1))begin        // tank win screen
		addr_r <= pixel_row/3'd3;          // scaling 256*256 pixels
		addr_c <= pixel_column/3'd4;
		addr <= {addr_r,addr_c};		
		{VGA_R, VGA_G, VGA_B} <= player1;
	    end

	else if (frame4 == 1'b1) begin          // train win screen
         addr_r <= pixel_row/3'd3;          // scaling 256*256 pixels
		 addr_c <= pixel_column/3'd4;
		 addr <= {addr_r,addr_c};	  
         {VGA_R, VGA_G, VGA_B}<= player2;
	    end	  
	end
  end  

endmodule
