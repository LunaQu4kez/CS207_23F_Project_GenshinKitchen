// A 100Hz clock
module SegTubClock (
    input[0:0] clk, // 153600Hz
    output reg [0:0] tub_clk // 400Hz
);

    reg [15:0] cnt;

    always @(posedge clk) begin
        if (cnt == 192) begin
            cnt <= 0;
        end
        else begin
           cnt <= cnt + 1'b1; 
        end
    end

    always @(posedge clk) begin
        if (cnt == 192) begin
            tub_clk = ~tub_clk;
        end 
    end

endmodule