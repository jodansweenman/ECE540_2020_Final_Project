module colorizer_v2(
    input [11:0]      icon1,
    input [11:0]      icon2,
    //input             icon1_flag,
    //input             icon2_flag,
    input [1:0]       world_pixel,
    input             video_on,
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B
);
    reg [11:0] map_color;
    
  always @(*) begin
    case (world_pixel)
        2'b00:  map_color = 12'hfff;
        2'b10:  map_color = 12'h840;
    endcase
  end
      
  // determine between icon color or map color
  always @(*) begin
    if (~video_on) begin
      {VGA_R, VGA_G, VGA_B} = 12'h000;
    end
    else begin
        {VGA_R, VGA_G, VGA_B} = icon1? icon1 : map_color;
    end
  end

endmodule
