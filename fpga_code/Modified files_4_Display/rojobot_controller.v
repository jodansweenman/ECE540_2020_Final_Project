`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// 
// Design Name: Tank Team Fall 2020
// Module Name: rojobot_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      This module wraps the rojobot module and the WB interface signals
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rojobot_controller(

    // System
    input wire         clk,            // 100MHz clock
	input wire         rstn,           // reset active low
	input wire         clk_75,         // 75MHz clock
	input wire [15:0]  debounced_SW,   // the switches

    // WISHBONE Interface
	input wire [31:0]  wb_adr_i, 
	input wire [31:0]  wb_dat_i, 
	input wire [3:0]   wb_sel_i, 
	input wire         wb_we_i, 
	input wire         wb_cyc_i, 
	input wire         wb_stb_i,
	input wire [2:0]   wb_cti_i, 
	input wire [1:0]   wb_bte_i,
	output reg [31:0]  wb_dat_o, 
	output reg         wb_ack_o, 
	output wire        wb_err_o, 
	output wire        wb_rtry_o,
	
	input wire [31:0]  wb_adr_i_2, 
	input wire [31:0]  wb_dat_i_2, 
	input wire [3:0]   wb_sel_i_2, 
	input wire         wb_we_i_2, 
	input wire         wb_cyc_i_2, 
	input wire         wb_stb_i_2,
	input wire [2:0]   wb_cti_i_2, 
	input wire [1:0]   wb_bte_i_2,
	output reg [31:0]  wb_dat_o_2, 
	output reg         wb_ack_o_2, 
	output wire        wb_err_o_2, 
	output wire        wb_rtry_o_2,
	
	// VGA
    input wire [11:0]  pixel_column,    // VGA screen column
    input wire [11:0]  pixel_row,       // VGA screen row
    input wire         video_on,        // VGA signal for visible region
    output wire [ 3:0] VGA_R,           // VGA red channel
    output wire [ 3:0] VGA_G,           // VGA green channel
    output wire [ 3:0] VGA_B            // VGA blue channel
	
    );
    
    // ****************************************
    // VARIABLES
    // ****************************************
    
    // for SYNC
    reg rstn_75;                        // reset in 75MHz domain
    reg [15:0] debounced_SW_75;         // the switches in 75 domain
    /////////// Rojobot 1/////////////
    // for WISHBONE bus
	// WB          
    wire [31:0]  IO_BotInfo;           
    reg [7:0]    IO_BotCtrl;	           
    
    
    
    // Rojobot
    wire [7:0]  MotCtl_in;
    reg  [7:0]  MotCtl_in_75;           // sync to 75MHz domain
    wire [7:0]  LocX_reg;
    reg  [7:0]  LocX_reg_100;           // sync to 100MHz domain
    wire [7:0]  LocY_reg;
    reg  [7:0]  LocY_reg_100;           // sync to 100MHz domain
    wire [7:0]  Sensors_reg;
    reg  [7:0]  Sensors_reg_100;        // sync to 100MHz domain
    wire [7:0]  BotInfo_reg;
    reg  [7:0]  BotInfo_reg_100;        // sync to 100MHz domain
    wire        upd_sysregs;
    reg         upd_sysregs_100;        // sync to 100MHz domain
    wire [11:0] icon1;
    wire        icon1_flag;
    
    // Handshake flip-flop
	reg          IO_BotUpdt_Sync;       
	reg          IO_INT_ACK;  
    //////////// Rojobot 2 /////////////
    // for WISHBONE bus
    wire [31:0]  IO_BotInfo_2;           
    reg [7:0]    IO_BotCtrl_2;	           
    
    wire [1:0] IO_HIT;               // 2 bit hit IO, one for each rojobot        
    reg [3:0] IO_Frame;             // 4 bit for four frames      
    reg [1:0] IO_Bullet;            // 2 bits bullet IO, one for each rojobot
    wire [11:0] bullet1;
    wire        bullet1_flag;
    wire [11:0] bullet2;
    wire        bullet2_flag;
    //Bullet signal
	wire burst_tank1, burst_tank2;                              // burst_tg shows the green tank is hit by the opponent tank; burst_tr shows the red tank is hit by the opponent tank.  
    wire hit1, hit2; 
    
    // Rojobot
    wire [7:0]  MotCtl_in_2;
    reg  [7:0]  MotCtl_in_75_2;           // sync to 75MHz domain
    wire [7:0]  LocX_reg_2;
    reg  [7:0]  LocX_reg_100_2;           // sync to 100MHz domain
    wire [7:0]  LocY_reg_2;
    reg  [7:0]  LocY_reg_100_2;           // sync to 100MHz domain
    wire [7:0]  Sensors_reg_2;
    reg  [7:0]  Sensors_reg_100_2;        // sync to 100MHz domain
    wire [7:0]  BotInfo_reg_2;
    reg  [7:0]  BotInfo_reg_100_2;        // sync to 100MHz domain
    wire        upd_sysregs_2;
    reg         upd_sysregs_100_2;        // sync to 100MHz domain
    wire [11:0] icon2;
    wire        icon2_flag;
    
    // Handshake flip-flop
	reg          IO_BotUpdt_Sync_2;       
	reg          IO_INT_ACK_2;  
    //////////////////////////////////////////////////////////////////
	  // World map
    wire [13:0] map_addr_tank, map_addr_train;
    wire [1:0]  map_data_tank, map_data_train, map1_data_tank, map1_data_train, map2_data_tank, map2_data_train;
    wire [13:0] vid_addr;
    wire [1:0]  map_pixel, map1_pixel, map2_pixel;
   
  
    // Scaler
    wire [6:0]  world_row, world_column;
    wire        out_of_map;
    
	
	
    assign IO_BotInfo = {LocX_reg_100, LocY_reg_100, Sensors_reg_100, BotInfo_reg_100};
    assign IO_BotInfo_2 = {LocX_reg_100_2, LocY_reg_100_2, Sensors_reg_100_2, BotInfo_reg_100_2};
    assign MotCtl_in = IO_BotCtrl;
    assign MotCtl_in_2 = IO_BotCtrl_2;
    // ****************************************
    // INSTANCES
    // ****************************************
    
    // rojobot 1
    rojobot31_0 Tank (
        .MotCtl_in(MotCtl_in_75),         // input wire [7 : 0] MotCtl_in
        .LocX_reg(LocX_reg),              // output wire [7 : 0] LocX_reg
        .LocY_reg(LocY_reg),              // output wire [7 : 0] LocY_reg
        .Sensors_reg(Sensors_reg),        // output wire [7 : 0] Sensors_reg
        .BotInfo_reg(BotInfo_reg),        // output wire [7 : 0] BotInfo_reg
        .worldmap_addr(map_addr_tank),    // output wire [13 : 0] worldmap_addr
        .worldmap_data(map_data_tank),    // input wire [1 : 0] worldmap_data
        .clk_in(clk_75),                  // input wire clk_in
        .reset(~rstn_75),                 // input wire reset
        .upd_sysregs(upd_sysregs),        // output wire upd_sysregs
        .Bot_Config_reg(debounced_SW_75)  // input wire [7 : 0] Bot_Config_reg
    );
    
    // rojobot 2
    rojobot31_1 Train (
        .MotCtl_in(MotCtl_in_75_2),         // input wire [7 : 0] MotCtl_in
        .LocX_reg(LocX_reg_2),              // output wire [7 : 0] LocX_reg
        .LocY_reg(LocY_reg_2),              // output wire [7 : 0] LocY_reg
        .Sensors_reg(Sensors_reg_2),        // output wire [7 : 0] Sensors_reg
        .BotInfo_reg(BotInfo_reg_2),        // output wire [7 : 0] BotInfo_reg
        .worldmap_addr(map_addr_train),    // output wire [13 : 0] worldmap_addr
        .worldmap_data(map_data_train),    // input wire [1 : 0] worldmap_data
        .clk_in(clk_75),                  // input wire clk_in
        .reset(~rstn_75),                 // input wire reset
        .upd_sysregs(upd_sysregs_2),        // output wire upd_sysregs
        .Bot_Config_reg(debounced_SW_75)  // input wire [7 : 0] Bot_Config_reg
    );
    
    // handshake flip-flop
    always @ (posedge clk) begin
        if (IO_INT_ACK == 1'b1) begin
            IO_BotUpdt_Sync <= 1'b0;
        end else if (upd_sysregs_100 == 1'b1) begin
            IO_BotUpdt_Sync <= 1'b1;
        end else begin
            IO_BotUpdt_Sync <= IO_BotUpdt_Sync;
        end
    end
    
    always @ (posedge clk) begin
        if (IO_INT_ACK_2 == 1'b1) begin
            IO_BotUpdt_Sync_2 <= 1'b0;
        end else if (upd_sysregs_100_2 == 1'b1) begin
            IO_BotUpdt_Sync_2 <= 1'b1;
        end else begin
            IO_BotUpdt_Sync_2 <= IO_BotUpdt_Sync_2;
        end
    end
    
   
   
    blk_mem_gen_1 tank1(
        .clka(clk_75),
        .addra(map_addr_tank),
        .douta(map1_data_tank),
        .clkb(clk_75),
        .addrb(vid_addr),
        .doutb(map1_pixel)
    );
    
    blk_mem_gen_1 train1(
        .clka(clk_75),
        .addra(map_addr_train),
        .douta(map1_data_train),
        .clkb(clk_75),
        .addrb(vid_addr),
        .doutb()
    );
    
    game_map2 tank2(
        .clka(clk_75),
        .addra(map_addr_tank),
        .douta(map2_data_tank),
        .clkb(clk_75),
        .addrb(vid_addr),
        .doutb(map2_pixel)
    );
    
    game_map2 train2(
        .clka(clk_75),
        .addra(map_addr_train),
        .douta(map2_data_train),
        .clkb(clk_75),
        .addrb(vid_addr),
        .doutb()
    );
    
    // mux to select map based on the SW
    assign {map_data_tank, map_data_train, map_pixel} =
        debounced_SW[15] ? {map1_data_tank, map1_data_train, map1_pixel} : {map2_data_tank, map2_data_train, map2_pixel};
       
    
    // scaler
    vga_scaler_v2 vga_scaler_v2(
        .world_row(world_row),
        .world_column(world_column),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .vid_addr(vid_addr),
        .out_of_map(out_of_map)
    );
    
    // rojobot ICON  
    icon icon_tank(
        .clk(clk_75),
        .reset(~rstn_75),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .LocX_reg(LocX_reg),
        .LocY_reg(LocY_reg),
        .BotInfo_reg(BotInfo_reg),
        .icon(icon1_flag),
        .icon_c(icon1),
        .burst(IO_HIT[0]),
        .tank_reset(),
        .hit(hit1)
    );
    
    icon2 icon_train(
        .clk(clk_75),
        .reset(~rstn_75),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .LocX_reg(LocX_reg_2),
        .LocY_reg(LocY_reg_2),
        .BotInfo_reg(BotInfo_reg_2),
        .icon(icon2_flag),
        .icon_c(icon2),
        .burst(IO_HIT[1]),
        .tank_reset(),
        .hit(hit2)
    );
   
    // map colorizer
    map_colorizer map_colorizer(
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .map_value(world_pixel),
        .map_color(map_color)
    );

    // title colorizer
    title_colorizer title_colorizer(
        .clk(clk_75),
        .switch(debounced_SW_75),
        .pixel_row(pixel_row),
        .pixel_column(pixel_column),
        .title_color(title_color)
    );


  
  //bullet
   bullet tank_bullet(    
            .pixel_row(pixel_row),
            .pixel_column(pixel_column),
            .bullet_flag(bullet1_flag),                             
            .bullet_color(bullet1),
            .burst(hit1),			
            .LocX_reg(LocX_reg),       
            .LocY_reg(LocY_reg),
            .BotInfo_reg(BotInfo_reg),
            .clock(clk_75),
            .reset(~rstn_75),
            .biu(IO_Bullet[0]),                 //input signal to make the tank shot
            .icon_op(icon1),                    //opponent tank icon flag(tank )
            .world_pixel(doutb)
     );
     
     bullet train_bullet(    
            .pixel_row(pixel_row),
            .pixel_column(pixel_column),
            .bullet_flag(bullet2_flag),                             
            .bullet_color(bullet2), 
			.burst(hit2),                     //red tank hits green tank
            .LocX_reg(LocX_reg_2),       
            .LocY_reg(LocY_reg_2),
            .BotInfo_reg(BotInfo_reg_2),
            .clock(clk_75),
            .reset(~rstn_75),
            .biu(IO_Bullet[1]),                 //input signal to make the  train shot
            .icon_op(icon2),                    //opponent tank icon flag(train tank)
            .world_pixel(doutb)
     );
  
  
  //Final colorizer
    colorizer_final colorizer_final(
        .clk(clk_75),
        .pixel_column(pixel_column),
        .pixel_row(pixel_row), 
        .icon1(icon1),
        .icon1_flag(icon1_flag),
        .icon2(icon2),
        .icon2_flag(icon2_flag),
        .bull1_flag(bullet1_flag),
        .bull2_flag(bullet2_flag),
        .bul_color(bullet1),
        .bul_color2(bullet2),
        .frame1(IO_Frame[0]),                //map with icon screen
        .frame2(IO_Frame[1]),               // Initial/Welcome screen
        .frame3(IO_Frame[2]),               //player1 win screen
        .frame4(IO_Frame[3]),              // player2 win screen
        .frame5(IO_Frame[4]),                       
        //.map_color(map_color),
        .world_pixel(world_pixel),
        .title_color(title_color),
        .video_on(video_on),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
        
    );
    
    // ****************************************
    // LOGIC
    // ****************************************
    
    // sync signals from 100MHz to 75MHz domain
    always @(posedge clk_75) begin
        rstn_75 <= rstn;
        MotCtl_in_75 <= MotCtl_in;
        MotCtl_in_75_2 <= MotCtl_in_2;
        debounced_SW_75 <= debounced_SW;
    end
    
    // sync signals from 75MHz to 100MHz domain
    always @(posedge clk) begin
        LocX_reg_100 <= LocX_reg;
        LocY_reg_100 <= LocY_reg;
        Sensors_reg_100 <= Sensors_reg;
        BotInfo_reg_100 <= BotInfo_reg;
        upd_sysregs_100 <= upd_sysregs;
        LocX_reg_100_2 <= LocX_reg_2;
        LocY_reg_100_2 <= LocY_reg_2;
        Sensors_reg_100_2 <= Sensors_reg_2;
        BotInfo_reg_100_2 <= BotInfo_reg_2;
        upd_sysregs_100_2 <= upd_sysregs_2;
    end
       
    
    // WISHBONE acknowledge
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            wb_ack_o <= 0;
            wb_ack_o_2 <= 0;
        end
        else begin
            wb_ack_o <= wb_cyc_i & !wb_ack_o;
            wb_ack_o_2 <= wb_cyc_i_2 & !wb_ack_o_2;
        end
    end

    //Write Control Rojobot 1
    always @(posedge clk, negedge rstn) begin            
        if (~rstn) begin           
            IO_INT_ACK  <= 1'b0;            
            IO_BotCtrl  <= 8'h00;        
        end        
        else if ( wb_cyc_i & wb_stb_i & wb_we_i & !wb_ack_o & wb_sel_i[0]) begin // Possibly wb_ck_o instead.            
            case (wb_adr_i[7:0])                
                8'h10: IO_BotCtrl <= wb_dat_i[7:0]; //bot control
                8'h18: IO_INT_ACK  <= wb_dat_i[0];  // int ack 
                8'h20: IO_Bullet <= wb_dat_i[1:0];
                8'h30: IO_Frame <= wb_dat_i[4:0];         
            endcase        
        end    
    end
    //Write Control Rojobot 2
    always @(posedge clk, negedge rstn) begin            
        if (~rstn) begin           
            IO_INT_ACK_2  <= 1'b0;            
            IO_BotCtrl_2  <= 8'h00;        
        end        
        else if ( wb_cyc_i_2 & wb_stb_i_2 & wb_we_i_2 & !wb_ack_o_2 & wb_sel_i_2[0]) begin // Possibly wb_ck_o instead.            
            case (wb_adr_i_2[7:0])                
                8'h10: IO_BotCtrl_2 <= wb_dat_i_2[7:0]; //bot control
                8'h18: IO_INT_ACK_2  <= wb_dat_i_2[0];  // int ack          
            endcase        
        end    
    end
    
    // read data via WISHBONE bus
    //Read Control Rojobot 1
    always @ (posedge clk, negedge rstn) begin        
        if (~rstn) begin           
            wb_dat_o <= 32'h00_00_00_00;        
        end        
        else begin            
            case (wb_adr_i[7:0])                
                8'h0C: wb_dat_o <= IO_BotInfo; // bot info                       
                8'h14: wb_dat_o <= {31'h00_00_00_00, IO_BotUpdt_Sync}; // update sync 
                8'h20: wb_dat_o <= {30'h00_00_00_00, IO_HIT};
            endcase        
        end    
    end
    
    //Read Control Rojobot 2
    always @ (posedge clk, negedge rstn) begin        
        if (~rstn) begin           
            wb_dat_o_2 <= 32'h00_00_00_00;        
        end        
        else begin            
            case (wb_adr_i_2[7:0])                
                8'h0C: wb_dat_o_2 <= IO_BotInfo_2; // bot info                       
                8'h14: wb_dat_o_2 <= {31'h00_00_00_00, IO_BotUpdt_Sync_2}; // update sync 
            endcase        
        end    
    end
   
endmodule
