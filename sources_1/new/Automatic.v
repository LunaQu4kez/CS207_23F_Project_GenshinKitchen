module Automatic (
    input [0:0] clk,
    input [7:0] out_bits,
    input [15:0] script,
    input [4:0] btn,
    input [7:0] switch,
    output reg [7:0] pc,
    output reg [7:0] in_bits,
    output [7:0] led,
    output [7:0] led2,
    output reg [0:0] rst
);
    parameter BG = 8'hA0, CHOOSE = 8'hA1, START = 8'hA2, ENDGAME = 8'hA3,
              GET_SCRIPT = 8'hA4, MOVE = 8'hA5, THROW = 8'hA6, PUT = 8'hA7,
              GET = 8'hA8, INTERACT = 8'hA9, TAR_ON = 8'hAA,
              WAIT_CNT = 8'hAB, WAITUNTIL = 8'hAC, P_READY = 8'hAD, T_READY = 8'hAE,
              WAIT1 = 8'hC1,
              RESET = 8'hD0;

    reg [7:0] state = 8'hA0, next_state;
    reg [0:0] tick1, tick2;
    reg [7:0] cnt, temp;

    assign led2 = state;
    assign led = in_bits;

    always @(state, btn, switch, temp, script, out_bits, cnt) begin
        if (~switch[6]) next_state = state;
        else if (btn[4]) next_state = RESET;
        else begin
            case (state)
                RESET:
                    next_state = BG;
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
                    else if (script[7:5] == 3'b010) next_state = T_READY;
                P_READY:
                    next_state = out_bits[2] ? GET_SCRIPT : P_READY;
                T_READY:
                    next_state = out_bits[4] ? GET_SCRIPT : T_READY;
                WAIT_CNT:
                    if (temp + script[15:8] == cnt) next_state = GET_SCRIPT;
                    else next_state = WAIT_CNT;
            endcase
        end
    end

    always @(posedge clk) begin
        state <= next_state;
        cnt <= cnt + 1;
    end

    always @(state) begin
        case (state)
            RESET: begin
                in_bits = 8'b0000_0000;
                tick1 = 1;
                rst = 1;
            end
            BG: begin
                in_bits = 8'b0000_0000;
                tick1 = 0;
                tick2 = 0;
                rst = 0;
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
            START: begin
                in_bits = 8'b0000_0101;
                tick1 = 0;
            end
            WAIT1: begin
                in_bits = 8'b0000_0101;
                tick1 = 0;
            end
            ENDGAME: begin
                in_bits = 8'b0000_1001;
                tick1 = 0;
            end
            TAR_ON: begin
                in_bits = {script[13:8], 2'b11};
                tick1 = 0;
            end
            MOVE: begin
                in_bits = 8'b0010_0010;
                tick1 = 0;
            end
            THROW: begin
                in_bits = 8'b0100_0010;
                tick1 = 0;
            end
            PUT: begin
                in_bits = 8'b0000_1010;
                tick1 = 0;
            end
            GET: begin
                in_bits = 8'b0000_0110;
                tick1 = 0;
            end
            INTERACT: begin
                in_bits = 8'b0001_0010;
                tick1 = 0;
            end
            WAITUNTIL: begin
                in_bits = 8'b0001_0010;
                tick1 = 0;
            end
            T_READY: begin
                in_bits = 8'b0001_0010;
                tick1 = 0;
            end
            WAIT_CNT: begin
                tick1 = 0;
                tick2 = 1;
                in_bits = 8'b0000_0000;
            end
        endcase
    end

    always @(posedge tick1) begin
        if (state == RESET) pc <= 0;
        else pc <= pc + 2;
    end

    always @(posedge tick2) begin
        temp <= cnt;
    end

endmodule