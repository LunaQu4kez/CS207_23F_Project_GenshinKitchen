module Automatic (
    input [0:0] clk,
    input [7:0] out_bits,
    input [15:0] script,
    input [4:0] btn,
    input [0:0] switch,
    output reg [7:0] pc,
    output reg [7:0] in_bits,
    output [7:0] led,
    output [7:0] led2,
    output reg [0:0] rst
);
    parameter BG = 8'hA0, CHOOSE = 8'hA1, START = 8'hA2, ENDGAME = 8'hA3,
              GET_SCRIPT = 8'hA4, MOVE = 8'hA5, THROW = 8'hA6, PUT = 8'hA7,
              GET = 8'hA8, INTERACT = 8'hA9, TAR_ON = 8'hAA,
              WAIT_CNT = 8'hAB, WAITUNTIL = 8'hAC, P_READY = 8'hAD, P_HASITEM = 8'hAE,
              T_READY = 8'hAF, T_HASITEM = 8'hB0,
              WAIT1 = 8'hC1;

    reg [7:0] state = 8'hA0, next_state;
    reg [0:0] tick1, tick2;
    reg [7:0] cnt, temp;

    assign led2 = state;
    assign led = out_bits;

    always @(state, btn, script, out_bits, cnt) begin
        case (state)
            BG:
                if (btn[2]) next_state = CHOOSE;
                else next_state = BG;
            CHOOSE:
                if (script[4:0] == 5'b10100) next_state = ENDGAME;
                else if (script[4:0] == 5'b01100) next_state = START;
                else if (script[2:0] == 3'b001) next_state = TAR_ON;
                else if (script[4:0] == 5'b00011) next_state = WAIT_CNT;
                else if (script[4:0] == 5'b01011) next_state = WAITUNTIL;
            GET_SCRIPT:
                next_state = CHOOSE;
            START:
                next_state = WAIT1;
            WAIT1:
                next_state = GET_SCRIPT;
            ENDGAME:
                next_state = ENDGAME;
            TAR_ON:
                if (script[4:3] == 2'b11) next_state = THROW;
                else next_state = MOVE;
            THROW:
                next_state = ~out_bits[3] ? GET_SCRIPT : THROW;
            MOVE:
                if (out_bits[2]) begin
                    if (script[4:3] == 2'b01) next_state = PUT;
                    else if (script[4:3] == 2'b00) next_state = GET;
                    else next_state = INTERACT;
                end
                else next_state = MOVE;
            PUT:
                next_state = ~out_bits[3] ? GET_SCRIPT : PUT;
            GET:
                next_state = out_bits[3] ? GET_SCRIPT : GET;
            INTERACT:
                next_state = GET_SCRIPT;
            WAITUNTIL:
                if (script[7:5] == 3'b000) next_state = P_READY;
                else if (script[7:5] == 3'b001) next_state = P_HASITEM;
                else if (script[7:5] == 3'b010) next_state = T_READY;
                else if (script[7:5] == 3'b011) next_state = T_HASITEM;
            P_READY:
                next_state = out_bits[2] ? GET_SCRIPT : P_READY;
            P_HASITEM:
                next_state = out_bits[3] ? GET_SCRIPT : P_HASITEM;
            T_READY:
                next_state = out_bits[4] ? GET_SCRIPT : T_READY;
            T_HASITEM:
                next_state = out_bits[5] ? GET_SCRIPT : T_HASITEM;
            WAIT_CNT:
                if (temp + script[15:8] == cnt) next_state = GET_SCRIPT;
                else next_state = WAIT_CNT;
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;
        cnt <= cnt + 1;
    end

    always @(state) begin
        case (state)
            BG: begin
                in_bits = 8'b0000_0000;
                tick1 = 0;
                tick2 = 0;
            end
            GET_SCRIPT: begin
                in_bits = 8'b0000_0000;
                tick1 = 1;
                tick2 = 0;
            end
            CHOOSE: begin
                in_bits = 8'b0000_0000;
                tick1 = 0;
            end
            START:
                in_bits = 8'b0000_0101;
            WAIT1:
                in_bits = 8'b0000_0101;
            ENDGAME:
                in_bits = 8'b0000_1001;
            TAR_ON:
                in_bits = {script[13:8], 2'b11};
            MOVE:
                in_bits = 8'b0010_0010;
            THROW:
                in_bits = 8'b0100_0010;
            PUT:
                in_bits = 8'b0000_1010;
            GET:
                in_bits = 8'b0000_0110;
            INTERACT:
                in_bits = 8'b0001_0010;
            WAITUNTIL:
                in_bits = 8'b0001_0010;
            T_READY:
                in_bits = 8'b0001_0010;
            WAIT_CNT: begin
                tick2 = 1;
                in_bits = 8'b0000_0000;
            end
            WAITUNTIL:
                in_bits = in_bits;
        endcase
    end

    always @(posedge tick1) begin
        pc <= pc + 2;
    end

    always @(posedge tick2) begin
        temp <= cnt;
    end

endmodule