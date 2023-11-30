// A 10Hz clock
module SlowClock (
    input [0:0] clk, // 153600Hz
    output reg [0:0] slow_clk // 10Hz
);

    reg [15:0] cnt;

    always @(posedge clk) begin
        if (cnt == 7680) begin
            cnt <= 0;
        end
        else begin
           cnt <= cnt + 1'b1; 
        end
    end

    always @(posedge clk) begin
        if (cnt == 7680) begin
            slow_clk = ~slow_clk;
        end 
    end
    
endmodule