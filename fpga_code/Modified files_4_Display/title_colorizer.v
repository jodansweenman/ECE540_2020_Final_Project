// title_colorizer.v
// Thong & Deepen
//
// Pick color for the title based on the given pixel coordinates

module title_colorizer
(
  input wire               clk,            // clock signal
  input wire        [15:0] switch,      
  input wire signed [31:0] pixel_row,      // pixel row from the dtg
  input wire signed [31:0] pixel_column,   // pixel column from the dtg
  output reg [11:0]       title_color     // title color at the given pixel coordinates
);

wire [17:0]addr;          
wire [8:0] addr_r,addr_c;
wire [11:0] Initial; 
wire [11:0] player1;
wire [11:0] player2;
//wire [11:0] map;

// Block ROM to store the image information of background

  blk_mem_gen_0 Initial_begin ( .clka(clk), .addra(addr), .douta(Initial));      //Initial Frame rom
  blk_mem_gen_2 player1_win ( .clka(clk), .addra(addr), .douta(player1));        //player1 win
  blk_mem_gen_lr player2_win ( .clka(clk), .addra(addr), .douta(player2));       //player2 win

    assign  addr_r = pixel_row/3'd3;
    assign  addr_c = pixel_column/2'd2;
    assign  addr = {addr_r,addr_c};  
           
      always@(*)
        begin 
            case({switch[2],switch[1]})
              2'b00: title_color  = Initial;
              2'b01: title_color = player1;
              2'b10: title_color = player2;
              default: title_color = 12'hfff;
            endcase
         end     
       

endmodule