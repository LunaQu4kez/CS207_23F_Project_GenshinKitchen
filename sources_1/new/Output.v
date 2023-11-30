// deal with output
module Output (
    input [0:0] clk,
    input [0:0] mode,  // mode, 0 for manual, 1 for auto
    input [7:0] out_bits,
    input [7:0] in_bits_manual,
    input [3:0] state_manual,
    input [7:0] state_auto,
    input [7:0] pc,
    input [15:0] script,
    output [7:0] led,
    output [7:0] led2
);

    assign led = ~mode ? in_bits_manual : pc;
    assign led2[7:4] = out_bits[5:2];
    assign led2[3:0] = ~mode ? state_manual : state_auto[3:0];

    
endmodule