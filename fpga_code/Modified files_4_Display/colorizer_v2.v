// colorizer_v2.v
// Thong & Deepen
//
// Determine which color to display b/w robot, map & title, using layer-concept


module colorizer_v2(
    input [11:0]      icon,
    input [1:0]      map_color,
    input [1:0]      world_pixel,
    input [11:0]      icon2,
    input [11:0]      title_color,
    input             video_on,
    input[15:0] switch,
    output reg [3:0]  VGA_R,
    output reg [3:0]  VGA_G,
    output reg [3:0]  VGA_B
);

  reg [11:0] map_color2;
    
  always @(*) begin
    case (world_pixel)
        2'b00:  map_color2 = 12'hfff;
        2'b10:  map_color2 = 12'h840;
    endcase
  end
  // determine between icon color or world color
  always @(*) begin
    if (~video_on) begin
      {VGA_R, VGA_G, VGA_B} = 12'h000;
    end
    else begin
                     
            case({switch[15],switch[14]})
              2'b00: {VGA_R, VGA_G, VGA_B}  = title_color ? title_color: map_color;
              2'b01: {VGA_R, VGA_G, VGA_B} = title_color ? title_color : (icon ? icon : map_color);
              2'b10: {VGA_R, VGA_G, VGA_B} = title_color ? title_color : (icon2 ? icon2 : map_color);
              default: {VGA_R, VGA_G, VGA_B} = map_color2;
            endcase 
            
         end
  end

endmodule
