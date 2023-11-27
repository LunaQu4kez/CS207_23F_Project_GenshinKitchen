`timescale 1ns / 1ps

module Top(
    input [4:0] button,
    input [7:0] switches,

    output [7:0] led,
    output [7:0] led2,
    
    input clk,
    input rx,
    output tx
);

    wire uart_clk_16;
    wire quick_clk;
    wire slow_clk;
        
    wire [7:0] dataIn_bits;
    wire [7:0] dataIn_bits_manual;
    wire [7:0] dataIn_bits_auto;
    wire dataIn_ready;

    wire [7:0] dataOut_bits;
    reg [7:0] out_bits;
    wire dataOut_valid;
    
    wire script_mode;
    wire [7:0] pc;
    wire [15:0] script;

    wire [7:0] led_manual;
    wire [7:0] led2_manual;
    wire [7:0] led_auto;
    wire [7:0] led2_auto;

    wire rst;
    wire rst_auto;

    assign dataIn_bits = switches[6] ? dataIn_bits_auto : dataIn_bits_manual;
    assign rst = switches[6] ? rst_auto : 0;
    assign led = switches[6] ? led_auto : led_manual;
    assign led2 = switches[6] ? led2_auto : led2_manual;

    always @(posedge quick_clk) begin
        if (dataOut_valid) begin
            out_bits <= dataOut_bits;
        end
    end

    UARTClock uart_clock(
        .clk(clk),
        .uart_clk_16(uart_clk_16)
    );

    QuickClock quick_clock(
        .clk(clk),
        .quick_clk(quick_clk)
    );

    SlowClock slow_clock(
        .clk(uart_clk_16),
        .slow_clk(slow_clk)
    );

    Manual mnl(
        .button(button),
        .switches(switches),
        .out_bits(out_bits),
        .dataIn_bits(dataIn_bits_manual),
        .led(led_manual),
        .led2(led2_manual)
    );

    Automatic aut(
        .clk(slow_clk),
        .out_bits(out_bits),
        .script(script),
        .btn(button),
        .switch(switches),
        .pc(pc),
        .in_bits(dataIn_bits_auto),
        .led(led_auto),
        .led2(led2_auto),
        .rst(rst_auto)
    );

    ScriptMem script_mem_module(
        .clock(uart_clk_16),   // please use the same clock as UART module
        .reset(rst),           // please use the same reset as UART module
    
        .dataOut_bits(dataOut_bits), // please connect to io_dataOut_bits of UART module
        .dataOut_valid(dataOut_valid), // please connect to io_dataOut_valid of UART module
    
        .script_mode(script_mode), // output 1 when loading script from UART.
                                   // at this time, you should not use dataOut_bits or use pc and script.
    
        .pc(pc), // (a) give a program counter (address) to ScriptMem.
        .script(script) // referring (a), returning the corresponding instructions of pc
    );

    UART uart_module(
        .clock(uart_clk_16),     // uart clock. Please use 16 x BultRate. (e.g. 9600 * 16 = 153600Hz)
        .reset(rst),               // reset
  
        .io_pair_rx(rx),          // rx, connect to R5 please
        .io_pair_tx(tx),         // tx, connect to T4 please
        
        .io_dataIn_bits(dataIn_bits),     // (a) byte from DevelopmentBoard => GenshinKitchen
        .io_dataIn_ready(dataIn_ready),   // referring (a) pulse 1 after a byte tramsmit success.
        
        .io_dataOut_bits(dataOut_bits),     // (b) byte from GenshinKitchen => DevelopmentBoard, only available if io_dataOut_valid=1
        .io_dataOut_valid(dataOut_valid)  // referring (b)
    );


endmodule