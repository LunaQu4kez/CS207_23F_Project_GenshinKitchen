// A 153600Hz clock can be used in UART and ScriptMem
module UARTClock (
    input [0:0] clk,
    output reg [0:0] uart_clk_16
);

    reg [9:0] cnt;

    always @(posedge clk) begin
        if (cnt == 325) begin
            cnt <= 0;
        end
        else begin
           cnt <= cnt + 1'b1; 
        end
    end

    always @(posedge clk) begin
        if (cnt == 325) begin
            uart_clk_16 = ~uart_clk_16;
        end 
    end
    
endmodule
