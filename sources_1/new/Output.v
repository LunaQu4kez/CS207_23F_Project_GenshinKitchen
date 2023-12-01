`include "Constant.v"

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
    output [7:0] led2,
    output reg [7:0] tub_sel,
    output reg [7:0] tub_ctr1, tub_ctr2
);

    assign led = ~mode ? in_bits_manual : pc;
    assign led2[7:4] = out_bits[5:2];
    assign led2[3:0] = ~mode ? state_manual : state_auto[3:0];

    reg [1:0] state = `S0, next_state;

    always @(state) begin
        case (state)
            `S0: next_state = `S1;
            `S1: next_state = `S2;
            `S2: next_state = `S3;
            `S3: next_state = `S0;
            default: next_state = `S0;
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(state) begin
        if (~mode) begin
            tub_sel = `sel_m;
            tub_ctr1 = `ctr1_m;
            tub_ctr2 = `ctr2_m;
        end
        else begin
            case (state)
                `S0: begin
                    tub_sel = `sel_a0;
                    if (script[15:14] == 2'b00) tub_ctr1 = `ctr00;
                    else if (script[15:14] == 2'b01) tub_ctr1 = `ctr01;
                    else if (script[15:14] == 2'b10) tub_ctr1 = `ctr10;
                    else tub_ctr1 = `ctr11;
                    if (script[7:6] == 2'b00) tub_ctr2 = `ctr00;
                    else if (script[7:6] == 2'b01) tub_ctr2 = `ctr01;
                    else if (script[7:6] == 2'b10) tub_ctr2 = `ctr10;
                    else tub_ctr2 = `ctr11;
                end
                `S1: begin
                    tub_sel = `sel_a1;
                    if (script[13:12] == 2'b00) tub_ctr1 = `ctr00;
                    else if (script[13:12] == 2'b01) tub_ctr1 = `ctr01;
                    else if (script[13:12] == 2'b10) tub_ctr1 = `ctr10;
                    else tub_ctr1 = `ctr11;
                    if (script[5:4] == 2'b00) tub_ctr2 = `ctr00;
                    else if (script[5:4] == 2'b01) tub_ctr2 = `ctr01;
                    else if (script[5:4] == 2'b10) tub_ctr2 = `ctr10;
                    else tub_ctr2 = `ctr11;
                end
                `S2: begin
                    tub_sel = `sel_a2;
                    if (script[11:10] == 2'b00) tub_ctr1 = `ctr00;
                    else if (script[11:10] == 2'b01) tub_ctr1 = `ctr01;
                    else if (script[11:10] == 2'b10) tub_ctr1 = `ctr10;
                    else tub_ctr1 = `ctr11;
                    if (script[3:2] == 2'b00) tub_ctr2 = `ctr00;
                    else if (script[3:2] == 2'b01) tub_ctr2 = `ctr01;
                    else if (script[3:2] == 2'b10) tub_ctr2 = `ctr10;
                    else tub_ctr2 = `ctr11;
                end
                `S3: begin
                    tub_sel = `sel_a3;
                    if (script[9:8] == 2'b00) tub_ctr1 = `ctr00;
                    else if (script[9:8] == 2'b01) tub_ctr1 = `ctr01;
                    else if (script[9:8] == 2'b10) tub_ctr1 = `ctr10;
                    else tub_ctr1 <= `ctr11;
                    if (script[1:0] == 2'b00) tub_ctr2 = `ctr00;
                    else if (script[1:0] == 2'b01) tub_ctr2 = `ctr01;
                    else if (script[1:0] == 2'b10) tub_ctr2 = `ctr10;
                    else tub_ctr2 = `ctr11;
                end
            endcase
        end
    end
    
endmodule