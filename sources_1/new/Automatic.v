`include "Constant.v"

// auto mode logic
module Automatic (  
    input [0:0] clk,
    input [7:0] out_bits,
    input [15:0] script,
    input [4:0] btn,
    input [7:0] switch,
    output reg [7:0] pc,
    output reg [7:0] in_bits,
    output [0:0] rst,
    output [7:0] state_auto
);

    reg [7:0] state = `BG, next_state; // state register
    reg [0:0] tick1, tick2, tick3, tick4;
    reg [7:0] cnt, temp; // used to implement script "wait xxx"
    reg [5:0] tar_num = `n07;  // target machine in handle exception
    reg [7:0] tar_pc = 0; // used to implement script "jumpif" and "jumpifnot"

    assign state_auto = state;
    assign rst = btn[4];

    // block determined next state
    always @(*) begin
        if (~switch[6]) next_state = state;
        else begin
            case (state)
                `BG:
                    if (btn[2]) next_state = `CHOOSE;
                    else next_state = `BG;
                `CHOOSE:
                    if (script[4:0] == 5'b10100) next_state = `ENDGAME;
                    else if (script[4:0] == 5'b01100) next_state = `START;
                    else if (script[2:0] == 3'b001) next_state = `TAR_ON;
                    else if (script[4:0] == 5'b00011) next_state = `WAIT_CNT;
                    else if (script[7:0] == 8'b00001011) next_state = `P_READY;
                    else if (script[7:0] == 8'b01001011) next_state = `T_READY;
                    else if (script[2:0] == 3'b010) next_state = `JUMP;
                `GET_SCRIPT:
                    next_state = `CMP;
                `CMP:
                    if (pc < tar_pc) next_state = `GET_SCRIPT;
                    else next_state = `CHOOSE;
                `START:
                    next_state = out_bits[5:2] != 4'b0000 ? `WAIT1 : `START;
                `WAIT1:
                    next_state = switch[5] ? `TAR2NUM : `GET_SCRIPT;
                `ENDGAME:
                    next_state = `ENDGAME;
                `TAR_ON:
                    if (script[4:3] == 2'b11 & 
                        (script[13:8] == `n09 |
                         script[13:8] == `n11 |
                         script[13:8] == `n14 |
                         script[13:8] == `n17 |
                         script[13:8] == `n19 |
                         script[13:8] == `n20)) next_state = `THROW;
                    else next_state = `MOVE;
                `THROW:
                    next_state = ~out_bits[3] ? `GET_SCRIPT : `THROW;
                `MOVE:
                    if (out_bits[2]) begin
                        if (script[4:3] == 2'b01 | script[4:3] == 2'b11) next_state = `PUT;
                        else if (script[4:3] == 2'b00 & out_bits[3] == 0) next_state = `GET;
                        else if (script[4:3] == 2'b00 & out_bits[3] == 1) next_state = `TAR_TO_BIN;
                        else next_state = `INTERACT;
                    end
                    else next_state = `MOVE;
                `TAR_TO_BIN:
                    next_state = `THROW_IT;
                `THROW_IT:
                    next_state = `TAR_ON;
                `PUT:
                    next_state = ~out_bits[3] ? `GET_SCRIPT : `PUT;
                `GET:
                    next_state = out_bits[3] ? `GET_SCRIPT : `GET;
                `INTERACT:
                    next_state = `GET_SCRIPT;
                `P_READY:
                    next_state = out_bits[2] ? `GET_SCRIPT : `P_READY;
                `T_READY:
                    next_state = out_bits[4] ? `GET_SCRIPT : `T_READY;
                `WAIT_CNT:
                    if (temp + script[15:8] == cnt) next_state = `GET_SCRIPT;
                    else next_state = `WAIT_CNT;
                `JUMP:
                    next_state = `GET_SCRIPT;
                `TAR2NUM:
                    next_state = `WAIT3;
                `WAIT3:
                    next_state = out_bits[5] ? `MOVE2NUM : `NUM_PLUS;
                `MOVE2NUM:
                    next_state = out_bits[2] ? `GET_ITEM : `MOVE2NUM;
                `GET_ITEM:
                    next_state = out_bits[3] ? `TAR2BIN : `GET_ITEM;
                `TAR2BIN:
                    next_state = `THROW_ITEM;
                `THROW_ITEM:
                    next_state = out_bits[5:4] == 2'b10 ? `WAIT2 : `THROW_ITEM;
                `WAIT2:
                    next_state = `TAR_NUM;
                `TAR_NUM:
                    next_state = `TAR_BIN;
                `TAR_BIN:
                    next_state = out_bits[5:4] == 2'b01 ? `TAR2NUM : `TAR_BIN;
                `NUM_PLUS:
                    next_state = `WAIT4;
                `WAIT4:
                    next_state = tar_num > 19 ? `GET_SCRIPT : `TAR2NUM;
            endcase
        end
    end

    // change state
    always @(posedge clk or posedge rst) begin
        if (rst) state <= `BG;
        else state <= next_state;
    end

    // cnt++
    always @(posedge clk) begin
        cnt <= cnt + 1;
    end

    // output logic
    always @(posedge clk) begin
        if (rst) in_bits <= `nonint;
        else begin
            case (state)
                `BG: begin
                    in_bits <= `nonact;
                    tick1 <= 0;
                    tick2 <= 0;
                    tick3 <= 0;
                end
                `GET_SCRIPT: begin
                    in_bits <= `nonact;
                    tick1 <= 1;
                    tick2 <= 0;
                    tick4 <= 0;
                end
                `CHOOSE: begin
                    in_bits <= `nonact;
                    tick1 <= 0;
                    tick4 <= 0;
                end
                `CMP: begin
                    in_bits <= `nonact;
                    tick1 <= 0;
                end
                `START: begin
                    in_bits <= `start;
                    tick1 <= 0;
                end
                `WAIT1: begin
                    in_bits <= `start;
                    tick1 <= 0;
                end
                `ENDGAME: begin
                    in_bits <= `endgame;
                    tick1 <= 0;
                end
                `TAR_ON: begin
                    in_bits <= {script[13:8], 2'b11};
                    tick1 <= 0;
                end
                `MOVE: begin
                    in_bits <= `move;
                    tick1 <= 0;
                end
                `TAR_TO_BIN: begin
                    in_bits <= `tarbin;
                    tick1 <= 0;
                end
                `THROW_IT: begin
                    in_bits <= `throw;
                    tick1 <= 0;
                end
                `THROW: begin
                    in_bits <= `throw;
                    tick1 <= 0;
                end
                `PUT: begin
                    in_bits <= `put;
                    tick1 <= 0;
                end
                `GET: begin
                    in_bits <= `get;
                    tick1 <= 0;
                end
                `INTERACT: begin
                    in_bits <= `interact;
                    tick1 <= 0;
                end
                `P_READY: begin
                    in_bits <= `interact;
                    tick1 <= 0;
                end
                `T_READY: begin
                    in_bits <= `interact;
                    tick1 <= 0;
                end
                `WAIT_CNT: begin
                    in_bits <= `nonact;
                    tick1 <= 0;
                    tick2 <= 1;
                end
                `JUMP: begin
                    in_bits <= `nonact;
                    tick4 <= 1;
                end
                `TAR2NUM: begin
                    in_bits <= {tar_num, 2'b11};
                    tick3 <= 0;
                end
                `WAIT3: begin
                    in_bits <= {tar_num, 2'b11};
                    tick3 <= 0;
                end
                `MOVE2NUM: begin
                    in_bits <= `move;
                    tick3 <= 0;
                end
                `GET_ITEM: begin
                    in_bits <= `get;
                    tick3 <= 0;
                end
                `TAR2BIN: begin
                    in_bits <= `tarbin;
                    tick3 <= 0;
                end
                `THROW_ITEM: begin
                    in_bits <= `throw;
                    tick3 <= 0;
                end
                `WAIT2: begin
                    in_bits <= `throw;
                    tick3 <= 0;
                end
                `TAR_NUM: begin
                    in_bits <= {tar_num, 2'b11};
                    tick3 <= 0;
                end
                `TAR_BIN: begin
                    in_bits <= `tarbin;
                    tick3 <= 0;
                end
                `NUM_PLUS: begin
                    in_bits <= `nonact;
                    tick3 <= 1;
                end
                `WAIT4: begin
                    in_bits <= `nonact;
                    tick3 <= 0;
                end
            endcase
        end
    end

    always @(posedge tick1 or posedge rst) begin
        if (rst) pc <= 0;
        else pc <= pc + 2;
    end

    always @(posedge tick2) begin
        temp <= cnt;
    end

    always @(posedge tick3 or posedge rst) begin
        if (rst) tar_num <= `n07;
        else tar_num <= tar_num + 1;
    end

    always @(posedge tick4 or posedge rst) begin
        if (rst) tar_pc <= 0;
        else begin
            if (script[3] == 0) begin
                if (script[7:5] == 0 & out_bits[2] == 1) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 1 & out_bits[3] == 1) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 2 & out_bits[4] == 1) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 3 & out_bits[5] == 1) tar_pc <= pc + script[15:8]*2;
                else tar_pc <= tar_pc;
            end
            else begin
                if (script[7:5] == 0 & out_bits[2] == 0) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 1 & out_bits[3] == 0) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 2 & out_bits[4] == 0) tar_pc <= pc + script[15:8]*2;
                else if (script[7:5] == 3 & out_bits[5] == 0) tar_pc <= pc + script[15:8]*2;
                else tar_pc <= tar_pc;
            end
        end
    end

endmodule