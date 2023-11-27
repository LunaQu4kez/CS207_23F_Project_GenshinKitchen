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
              WAIT = 4'b1000;
    
    reg [3:0] state = 4'b0000, next_state;

    assign led = in_bits;
    assign led2[3:0] = state;
    assign led2[7:4] = out_bits[5:2];

    always @(button, switches) begin
        if (button[6]) next_state = state;
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
                    next_state = ~button[2] ? USUAL : INTERACT;
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
                in_bits = {switches[5:0], 2'b11};
            end
            MOVE: begin
                in_bits = 8'b0010_0010;
            end
            GET: begin
                in_bits = 8'b0000_0110;
            end
            PUT: begin
                in_bits = 8'b0000_1010;
            end
            THROW: begin
                in_bits = 8'b0100_0010;
            end
            INTERACT: begin
                in_bits = 8'b0001_0010;
            end
        endcase
    end


    
endmodule