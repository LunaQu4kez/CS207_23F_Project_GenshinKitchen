module Manual (
    input [0:0] clk,
    input [4:0] button,
    input [7:0] switches,
    input [7:0] out_bits,
    output reg [7:0] in_bits,
    output [7:0] led,
    output [7:0] led2
);
    
    parameter UNSTART = 4'b0000, USUAL = 4'b0001, MOVE = 4'b0010, PUT = 4'b0011,
              GET = 4'b0100, THROW = 4'b0101, INTERACT = 4'b0110, START = 4'b0111,
              WAIT = 4'b1000, NONINT = 4'b1001;
    
    reg [3:0] state = 4'b0000, next_state;

    assign led = in_bits;
    assign led2[3:0] = state;
    assign led2[7:4] = out_bits[5:2];

    always @(button, switches) begin
        if (switches[6]) next_state = state;
        else begin
            case (state)
                UNSTART:
                    next_state = switches[7] ? START : UNSTART;
                START:
                    next_state = WAIT;
                WAIT:
                    next_state = USUAL;
                USUAL:
                    if (button[0]) next_state = MOVE;
                    else if (button[1]) next_state = PUT;
                    else if (button[2]) next_state = INTERACT;
                    else if (button[3]) next_state = GET;
                    else if (button[4]) next_state = THROW;
                    else if (~switches[7]) next_state = UNSTART;
                    else next_state = USUAL;
                MOVE:
                    next_state = USUAL;
                GET:
                    next_state = USUAL;
                PUT:
                    next_state = USUAL;
                THROW:
                    next_state = USUAL;
                INTERACT:
                    next_state = ~button[2] ? NONINT : INTERACT;
                NONINT:
                    next_state = USUAL;
            endcase
        end
    end

    always @(posedge clk) begin
        state <= next_state;
    end

    always @(state) begin
        case (state)
            UNSTART: begin
                in_bits = 8'b0000_1001;
            end
            START: begin
                in_bits = 8'b0000_0101;
            end
            WAIT: begin
                in_bits = 8'b0000_0101;
            end
            USUAL: begin
                if (switches[5:0] > 20) in_bits = 8'b0000_0011;
                else in_bits = {switches[5:0], 2'b11};
            end
            MOVE: begin
                in_bits = 8'b0010_0010;
            end
            GET: begin
                if (~out_bits[2]) in_bits = 8'b0000_0000;
                else begin
                    case (switches[5:0])
                        6'b000001: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000010: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000011: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000100: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000101: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000110: in_bits = ~out_bits[3] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b000111: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001000: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001001: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001010: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001011: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001100: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001101: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001110: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b001111: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b010000: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b010001: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b010010: in_bits = 8'b0000_0000;
                        6'b010011: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        6'b010100: in_bits = ~out_bits[3] & out_bits[5] ? 8'b0000_0110 : 8'b0000_0000;
                        default: in_bits = 8'b0000_0000;
                    endcase
                end
            end
            PUT: begin
                if (~out_bits[2]) in_bits = 8'b0000_0000;
                else begin
                    case (switches[5:0])
                        6'b000001: in_bits = 8'b0000_1010;
                        6'b000010: in_bits = 8'b0000_1010;
                        6'b000011: in_bits = 8'b0000_1010;
                        6'b000100: in_bits = 8'b0000_1010;
                        6'b000101: in_bits = 8'b0000_1010;
                        6'b000110: in_bits = 8'b0000_1010;
                        6'b000111: in_bits = ~out_bits[5] & out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001000: in_bits = ~out_bits[5] & out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001001: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001010: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001011: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001100: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001101: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001110: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b001111: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b010000: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b010001: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b010010: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b010011: in_bits = out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        6'b010100: in_bits = ~out_bits[5] & out_bits[3] ? 8'b0000_1010 : 8'b0000_0000;
                        default: in_bits = 8'b0000_0000;
                    endcase
                end
            end
            THROW: begin
                case (switches[5:0])
                    6'b000001: in_bits = 8'b0000_0000;
                    6'b000010: in_bits = 8'b0000_0000;
                    6'b000011: in_bits = 8'b0000_0000;
                    6'b000100: in_bits = 8'b0000_0000;
                    6'b000101: in_bits = 8'b0000_0000;
                    6'b000110: in_bits = 8'b0000_0000;
                    6'b000111: in_bits = 8'b0000_0000;
                    6'b001000: in_bits = 8'b0000_0000;
                    6'b001001: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    6'b001010: in_bits = 8'b0000_0000;
                    6'b001011: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    6'b001100: in_bits = 8'b0000_0000;
                    6'b001101: in_bits = 8'b0000_0000;
                    6'b001110: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    6'b001111: in_bits = 8'b0000_0000;
                    6'b010000: in_bits = 8'b0000_0000;
                    6'b010001: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    6'b010010: in_bits = 8'b0000_0000;
                    6'b010011: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    6'b010100: in_bits = out_bits[3] ? 8'b0100_0010 : 8'b0000_0000;
                    default: in_bits = 8'b0000_0000;
                endcase
            end
            INTERACT: begin
                if (~out_bits[2]) in_bits = 8'b0000_0000;
                else in_bits = 8'b0001_0010;
            end
            NONINT:
                in_bits = 8'b0000_0010;
        endcase
    end
    
endmodule