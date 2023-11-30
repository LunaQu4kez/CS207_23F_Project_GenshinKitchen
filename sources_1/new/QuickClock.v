// A quick enough clock
module QuickClock (
    input [0:0] clk,
    output reg [0:0] quick_clk
);

    reg [7:0] cnt;

    always @(posedge clk) begin
        if (cnt == 221) begin
            cnt <= 0;
        end
        else begin
           cnt <= cnt + 1'b1; 
        end
    end

    always @(posedge clk) begin
        if (cnt == 221) begin
            quick_clk = ~quick_clk;
        end 
    end
    
endmodule