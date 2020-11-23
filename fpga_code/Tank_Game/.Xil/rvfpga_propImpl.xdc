set_property SRC_FILE_INFO {cfile:c:/Users/airum/Desktop/final_project-alpa-enting-josh-josiah/fpga_code/Tank_Game/Tank_Game.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc rfile:../Tank_Game.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc id:1 order:EARLY scoped_inst:clock_divider/inst} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/airum/Desktop/RVfpga_RojoBot_HW/fpga_code/src/rvfpga.xdc rfile:../../../../RVfpga_RojoBot_HW/fpga_code/src/rvfpga.xdc id:2} [current_design]
current_instance clock_divider/inst
set_property src_info {type:SCOPED_XDC file:1 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
current_instance
set_property src_info {type:XDC file:2 line:108 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }]; #IO_L11N_T1_SRCC_35 Sch=uart_rxd_out
