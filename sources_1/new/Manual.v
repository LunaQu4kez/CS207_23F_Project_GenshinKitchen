module Manual (
    input [4:0] button,
    input [7:0] switches,
    output reg [7:0] dataIn_bits
);

    always @(switches[7]) begin
        if (switches[7]) begin
            dataIn_bits = 8'b0000_0101;
        end
        else begin
            dataIn_bits = 8'b0000_1001;
        end
    end
    
endmodule