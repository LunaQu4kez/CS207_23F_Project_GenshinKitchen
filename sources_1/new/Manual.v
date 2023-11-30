`include "Constant.v"

// manual mode logic
module Manual (  
    input [0:0] clk,
    input [4:0] button,
    input [7:0] switches,
    input [7:0] out_bits,
    output reg [7:0] in_bits,
    output [3:0] state_manual
);
    
    reg [3:0] state = `UNSTART_M, next_state; // state register

    assign state_manual = state;

    // block determined next state
    always @(button, switches) begin
        if (switches[6]) next_state = state;
        else begin
            case (state)
                `UNSTART_M:
                    next_state = switches[7] ? `START_M : `UNSTART_M;
                `START_M:
                    next_state = `WAIT_M;
                `WAIT_M:
                    next_state = `USUAL_M;
                `USUAL_M:
                    if (button[0]) next_state = `MOVE_M;
                    else if (button[1]) next_state = `PUT_M;
                    else if (button[2]) next_state = `INTERACT_M;
                    else if (button[3]) next_state = `GET_M;
                    else if (button[4]) next_state = `THROW_M;
                    else if (~switches[7]) next_state = `UNSTART_M;
                    else next_state = `USUAL_M;
                `MOVE_M:
                    next_state = `USUAL_M;
                `GET_M:
                    next_state = `USUAL_M;
                `PUT_M:
                    next_state = `USUAL_M;
                `THROW_M:
                    next_state = `USUAL_M;
                `INTERACT_M:
                    next_state = ~button[2] ? `NONINT_M : `INTERACT_M;
                `NONINT_M:
                    next_state = `USUAL_M;
            endcase
        end
    end

    // change state
    always @(posedge clk) begin
        state <= next_state;
    end

    // output combination circuit
    always @(state) begin
        case (state)
            `UNSTART_M: begin
                in_bits = `endgame;
            end
            `START_M: begin
                in_bits = `start;
            end
            `WAIT_M: begin
                in_bits = `start;
            end
            `USUAL_M: begin
                if (switches[5:0] > 20) in_bits = `nontar;
                else in_bits = {switches[5:0], 2'b11};
            end
            `MOVE_M: begin
                in_bits = `move;
            end
            `GET_M: begin
                if (~out_bits[2]) in_bits = `nonact;
                else begin
                    case (switches[5:0])
                        `n01, `n02, `n03, `n04, `n05, `n06: 
                            in_bits = ~out_bits[3] ? `get : `nonact;
                        `n07, `n08, `n09, `n10, `n11, `n12, `n13, `n14, `n15, `n16, `n17, `n19, `n20: 
                            in_bits = ~out_bits[3] & out_bits[5] ? `get : `nonint;
                        `n18:
                            in_bits = `nonint;
                        default:
                            in_bits = `nonact;
                    endcase
                end
            end
            `PUT_M: begin
                if (~out_bits[2]) in_bits = `nonact;
                else begin
                    case (switches[5:0])
                        `n01, `n02, `n03, `n04, `n05, `n06, `n09, `n10, `n11, `n12, `n13, `n14, `n15, `n16, `n17, `n18, `n19:
                            in_bits = out_bits[3] ? `put : `nonint;
                        `n07, `n08, `n20:
                            in_bits = ~out_bits[5] & out_bits[3] ? `put : `nonint;
                        default:
                            in_bits = `nonact;
                    endcase
                end
            end
            `THROW_M: begin
                case (switches[5:0])
                    `n01, `n02, `n03, `n04, `n05, `n06, `n07, `n08, `n10, `n12, `n13, `n15, `n16, `n18:
                        in_bits = `nonint;
                    `n09, `n11, `n14, `n17, `n19, `n20:
                        in_bits = out_bits[3] ? `throw : `nonint;
                    default:
                        in_bits = `nonact;
                endcase
            end
            `INTERACT_M: begin
                if (~out_bits[2]) in_bits = `nonact;
                else in_bits = `interact;
            end
            `NONINT_M:
                in_bits = `nonint;
        endcase
    end
    
endmodule