`timescale 1ns / 1ps

module UARTTransmitter(
  input        clock,
               reset,
               io_valid,
  input  [7:0] io_bits,
  input        tick,
  output       io_ready,
               tx
);

  reg  [3:0] state = 0;
  reg  [7:0] data = 0;
  wire       _io_ready_T = state == 4'h1;
  always @(posedge clock) begin
    if (reset)
      state <= 4'h0;
    else if (tick) begin
      if (state == 4'h2)
        state <= 4'h0;
      else if (state == 4'hB)
        state <= 4'h2;
      else if (state == 4'hA)
        state <= 4'hB;
      else if (state == 4'h9)
        state <= 4'hA;
      else if (state == 4'h8)
        state <= 4'h9;
      else if (state == 4'h7)
        state <= 4'h8;
      else
        state <= {1'h0, state == 4'h6 ? 3'h7 : state == 4'h5 ? 3'h6 : state == 4'h4 ? 3'h5 : state == 4'h1 ? 3'h4 : {2'h0, io_valid}};
      
      if (state == 4'h1 & io_valid)
          data <= io_bits;
      else
          data <= {1'h0, data[7:1]};
    end

  end // always @(posedge)
  assign io_ready = tick & _io_ready_T;
  assign tx = (|(state[3:2])) ? data[0] : ~_io_ready_T;
endmodule

module UARTReceiver(
  input        clock,
               reset,
               rx,
  output io_valid,
  output [7:0] io_bits
);

  reg  [2:0] cnt = 0;
  reg        sync_r = 0;
  reg        sync = 0;
  reg        bit_0 = 0;
  reg  [3:0] spacing = 0;
  wire       tick = spacing == 4'hA;
  reg  [3:0] state = 0;
  reg        data_0 = 0;
  reg        data_1 = 0;
  reg        data_2 = 0;
  reg        data_3 = 0;
  reg        data_4 = 0;
  reg        data_5 = 0;
  reg        data_6 = 0;
  reg        data_7 = 0;
  always @(posedge clock) begin
    if (reset) begin
      cnt <= 3'h6;
      bit_0 <= 1'h1;
      spacing <= 4'h0;
      state <= 4'h0;
    end
    else begin
      if (sync & ~(&cnt))
        cnt <= cnt + 3'h1;
      else if (~sync & (|cnt))
        cnt <= cnt - 3'h1;
      bit_0 <= (&cnt) | (|cnt) & bit_0;
      if (state == 4'h0) begin
        spacing <= 4'h0;
        state <= {3'h0, ~bit_0};
      end
      else begin
        spacing <= spacing + 4'h1;
        if (&spacing) begin
          if (state == 4'h2)
            state <= 4'h0;
          else if (state == 4'hB)
            state <= 4'h2;
          else if (state == 4'hA)
            state <= 4'hB;
          else if (state == 4'h9)
            state <= 4'hA;
          else if (state == 4'h8)
            state <= 4'h9;
          else if (state == 4'h7)
            state <= 4'h8;
          else
            state <=
              {1'h0,
               state == 4'h6
                 ? 3'h7
                 : state == 4'h5 ? 3'h6 : state == 4'h4 ? 3'h5 : {state == 4'h1, 2'h0}};
        end
      end
    end
    sync_r <= rx;
    sync <= sync_r;
    if (tick) begin
      data_0 <= bit_0;
      data_1 <= data_0;
      data_2 <= data_1;
      data_3 <= data_2;
      data_4 <= data_3;
      data_5 <= data_4;
      data_6 <= data_5;
      data_7 <= data_6;
    end
  end // always @(posedge)
  assign io_valid = state == 4'h2 & tick;
  assign io_bits = {data_0, data_1, data_2, data_3, data_4, data_5, data_6, data_7};
  
endmodule

module UART(
  input        clock,             // uart clock. Please use 16 x BaudRate. (such as: 9600 * 16 = 153600Hz)
               reset,             // reset on high.
               io_pair_rx,        // rx, connect to R5 pin please
  input  [7:0] io_dataIn_bits,    // (a) byte from DevelopmentBoard => GenshinKitchen
  output       io_pair_tx,        // tx, connect to T4 pin please
               io_dataIn_ready,   // referring (a) £»pulse 1 after a byte tramsmit success.
           reg io_dataOut_valid,  // referring (b)
  output reg [7:0] io_dataOut_bits    // (b) byte from GenshinKitchen => DevelopmentBoard, only available if io_dataOut_valid=1
);

  wire io_dataIn_valid = (io_dataIn_bits[1:0] != 2'b00);
  reg [3:0] clkCnt = 0;
  always @(posedge clock) begin
    if (reset)
      clkCnt <= 4'h0;
    else
      clkCnt <= clkCnt + 4'h1;
  end // always @(posedge)
  UARTTransmitter tx (
    .clock    (clock),
    .reset    (reset),
    .io_valid (io_dataIn_valid),
    .io_bits  (io_dataIn_bits),
    .tick     (&clkCnt),
    .io_ready (io_dataIn_ready),
    .tx       (io_pair_tx)
  );
  
  wire io_valid;
  wire [7:0] io_bits;
  UARTReceiver rx (
    .clock    (clock),
    .reset    (reset),
    .rx       (io_pair_rx),
    .io_valid(io_valid),
    .io_bits(io_bits)
  );

  always @(posedge clock) begin
    io_dataOut_bits = io_bits;
    io_dataOut_valid = io_valid;
  end

endmodule
