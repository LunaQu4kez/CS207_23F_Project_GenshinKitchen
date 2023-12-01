`timescale 1ns / 1ps

module Top(  // top module
    input [4:0] button,
    input [7:0] switches,

    output [7:0] led,
    output [7:0] led2,

    // 7seg_tub
    output [7:0] tub_sel,
    output [7:0] tub_ctr1, tub_ctr2,
    
    input clk,
    input rx,
    output tx
);

    wire uart_clk_16; // 153600Hz
    wire quick_clk;   // fast enough
    wire slow_clk;    // 10Hz
    wire tub_clk;     // 400Hz

    wire [7:0] dataIn_bits;         // data_in to UART
    wire [7:0] dataIn_bits_manual;  // data_in of manual mode
    wire [7:0] dataIn_bits_auto;    // data_in of auto mode
    wire dataIn_ready;

    wire [7:0] dataOut_bits;  // receive from UART
    wire [7:0] out_bits;      // out_bits every valid time
    wire dataOut_valid;
    
    wire script_mode;
    wire [7:0] pc;
    wire [15:0] script;

    wire rst;       // reset signal
    wire rst_auto;  // reset signal in auto mode

    wire [3:0] state_manual;  // state in manual mode
    wire [7:0] state_auto;    // state in auto mode

    assign dataIn_bits = switches[6] ? dataIn_bits_auto : dataIn_bits_manual;
    assign rst = switches[6] ? rst_auto : 0;

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

    SegTubClock tub_clock(
        .clk(uart_clk_16),
        .tub_clk(tub_clk)
    );

    OutbitsHandle obh(
        .clk(quick_clk),
        .dataOut_bits(dataOut_bits),
        .dataOut_valid(dataOut_valid),
        .out_bits(out_bits)
    );

    Output op(
        .clk(tub_clk),
        .mode(switches[6]),
        .out_bits(out_bits),
        .in_bits_manual(dataIn_bits_manual),
        .state_manual(state_manual),
        .state_auto(state_auto),
        .pc(pc),
        .script(script),
        .led(led),
        .led2(led2),
        .tub_sel(tub_sel),
        .tub_ctr1(tub_ctr1),
        .tub_ctr2(tub_ctr2)
    );

    Manual mnl(
        .clk(slow_clk),
        .button(button),
        .switches(switches),
        .out_bits(out_bits),
        .in_bits(dataIn_bits_manual),
        .state_manual(state_manual)
    );

    Automatic aut(
        .clk(slow_clk),
        .out_bits(out_bits),
        .script(script),
        .btn(button),
        .switch(switches),
        .pc(pc),
        .in_bits(dataIn_bits_auto),
        .rst(rst_auto),
        .state_auto(state_auto)
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