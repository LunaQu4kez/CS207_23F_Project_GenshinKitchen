module Manual (
    input [4:0] button,
    input [7:0] switches,
    input [7:0] out_bits,
    output reg [7:0] dataIn_bits,
    output [7:0] led,
    output [7:0] led2
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