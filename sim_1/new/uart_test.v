`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/09 16:07:32
// Design Name: 
// Module Name: uart_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_test(
    
    );
    reg clock = 0;
    reg io_send = 0;
    initial begin
        while(1) begin
            clock = ~clock;
            #10;
        end
    end
    
    wire serial;

    
    wire rec_valid,send_valid;
    reg [7:0] send_data = 8'b01100101;
    wire [7:0] rec_data;
    
    initial begin
       #1000
       io_send = 1;
//       #1000
//       send_data = 8'b00100001;
    end
    
  reg [3:0] clkCnt = 0;
    always @(posedge clock) begin
      clkCnt <= clkCnt + 4'h1;
    end
    
UARTReceiver rec(
     .clock(clock),
     .reset(0),
     .rx(serial),
     .io_valid(rec_valid),
     .io_bits(rec_data)
 );
 
UARTTransmitter tra(
    .clock(clock),
    .reset(0),
    .io_valid(io_send),
    .io_bits(send_data),
    .tick(clkCnt),
    .io_ready(send_valid),
    .tx(serial)
);
endmodule
