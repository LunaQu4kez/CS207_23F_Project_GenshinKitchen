`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/06 16:09:48
// Design Name: 
// Module Name: demo_sim
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


module demo_sim(

    );

    reg clock = 0;
    
    initial begin
        while(1) begin
            clock = ~clock;
            #10;
        end
    end
    
    reg io_pair_rx = 0;
    wire io_pair_tx,io_dataIn_ready,io_dataOut_valid;
    
    reg [7:0] io_dataIn_bits = 8'b01010100;
    wire [7:0] io_dataOut_bits;
 
    reg start_ = 0,end_ = 0;
    reg[4:0] op = 0;
    reg[4:0] dev = 1;
    wire[3:0] signal;
    reg[7:0] pc = 0;
    wire [15:0] script;
    reg rx = 1;
    wire tx;
    UartProtocol demo(
        start_,end_,
        op,
        dev,
            
        signal, //接收来自厨房的反馈信号。
        
        pc,
        script,
        clock,
        rx,
        tx
    );
           
//    UART uart_inst(
//      .clock(clock),             // 时钟，8x UART 比特率（9600 * 16 = 153600Hz，差不多就行了，没必要完全相等，差 1% 应该是可以接受的）
//      .reset(0),             // 同步 reset
//      .io_pair_rx(io_pair_rx),        // UART RX
//      .io_dataIn_bits(io_dataIn_bits),    // (a) UART 接受的 byte，当 io_dataIn_valid=1 且 io_dataIn_ready=1 时接受输入
//      .io_pair_tx(io_pair_tx),        // UART TX
//      .io_dataIn_ready(io_dataIn_ready),   // 见(a)；正在发送的时候为 0，空闲的时候每 16 个周期输出一次 1（懒得改了）
//      .io_dataOut_valid(io_dataOut_valid),  // 见(b)
//      .io_dataOut_bits(io_dataOut_bits)    // (b) UART 接受的 byte，当 io_dataOut_valid=1 时有效
//    );
    
endmodule
