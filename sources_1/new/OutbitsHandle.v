module OutbitsHandle (
    input [0:0] clk,
    input [7:0] dataOut_bits,
    input [0:0] dataOut_valid,
    output reg [7:0] out_bits
);

    always @(posedge clk) begin
        if (dataOut_valid) begin
            out_bits <= dataOut_bits;
        end
    end
    
endmodule