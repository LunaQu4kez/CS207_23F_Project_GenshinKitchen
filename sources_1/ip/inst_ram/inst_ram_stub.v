// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Tue Nov 14 20:58:20 2023
// Host        : LAPTOP-1890NNVV running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {D:/Desktop/Digital
//               Design/Project/GenshinKitchen_2023F/GenshinKitchen_HDL/GenshinKitchen.srcs/sources_1/ip/inst_ram/inst_ram_stub.v}
// Design      : inst_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module inst_ram(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[7:0],dina[7:0],douta[15:0]" */;
  input clka;
  input [0:0]wea;
  input [7:0]addra;
  input [7:0]dina;
  output [15:0]douta;
endmodule
