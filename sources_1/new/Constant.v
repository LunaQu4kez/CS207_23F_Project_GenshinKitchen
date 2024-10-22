// Constant
// auto state
`define BG 8'hA0
`define CHOOSE 8'hA1
`define START 8'hA2
`define ENDGAME 8'hA3
`define GET_SCRIPT 8'hA4
`define MOVE 8'hA5
`define THROW 8'hA6
`define PUT 8'hA7
`define GET 8'hA8
`define INTERACT 8'hA9
`define TAR_ON 8'hAA
`define WAIT_CNT 8'hAB
`define P_READY 8'hAC
`define T_READY 8'hAD
`define WAIT1 8'hAE
`define CMP 8'hB0
`define JUMP 8'hC0
`define WAIT2 8'hE9
`define WAIT3 8'hEA
`define WAIT4 8'hEB
`define TAR2NUM 8'hE1
`define MOVE2NUM 8'hE2
`define GET_ITEM 8'hE3
`define TAR2BIN 8'hE4
`define THROW_ITEM 8'hE5
`define NUM_PLUS 8'hE6
`define TAR_NUM 8'hE7
`define TAR_BIN 8'hE8
`define TAR_TO_BIN 8'hD1
`define THROW_IT 8'hD2

// manual state
`define UNSTART_M 4'b0000
`define USUAL_M 4'b0001
`define MOVE_M 4'b0010
`define PUT_M 4'b0011
`define GET_M 4'b0100
`define THROW_M 4'b0101
`define INTERACT_M 4'b0110
`define START_M 4'b0111
`define WAIT_M 4'b1000
`define NONINT_M 4'b1001

// output state
`define S0 2'b00
`define S1 2'b01
`define S2 2'b10
`define S3 2'b11

// action command
`define nonact 8'b0000_0000
`define nonint 8'b0000_0010
`define nontar 8'b0000_0011
`define start 8'b0000_0101
`define endgame 8'b0000_1001
`define move 8'b0010_0010
`define throw 8'b0100_0010
`define put 8'b0000_1010
`define get 8'b0000_0110
`define interact 8'b0001_0010
`define tarbin 8'b0101_0011

// target num
`define n01 6'b000001
`define n02 6'b000010
`define n03 6'b000011
`define n04 6'b000100
`define n05 6'b000101
`define n06 6'b000110
`define n07 6'b000111
`define n08 6'b001000
`define n09 6'b001001
`define n10 6'b001010
`define n11 6'b001011
`define n12 6'b001100
`define n13 6'b001101
`define n14 6'b001110
`define n15 6'b001111
`define n16 6'b010000
`define n17 6'b010001
`define n18 6'b010010
`define n19 6'b010011
`define n20 6'b010100

// 7seg_tub constant
`define sel_m 8'b1000_0000
`define ctr1_m 8'b0110_1110
`define ctr2_m 8'b0000_0000
`define sel_a0 8'b1000_1000
`define sel_a1 8'b0100_0100
`define sel_a2 8'b0010_0010
`define sel_a3 8'b0001_0001
`define ctr00 8'b0010_1000
`define ctr01 8'b0110_1000
`define ctr10 8'b0010_1100
`define ctr11 8'b0110_1100

// VGA constant
`define H_SYNC_PULSE 10'd96
`define H_BACK_PORCH 10'd48
`define H_ACTIVE_TIME 10'd640
`define H_FRONT_PORCH 10'd16
`define H_LINE_PERIOD 10'd800
`define V_SYNC_PULSE 10'd2
`define V_BACK_PORCH 10'd33
`define V_ACTIVE_TIME 10'd480
`define V_FRONT_PORCH 10'd10
`define V_FRAME_PERIOD 10'd525
`define char_width 6'd30
