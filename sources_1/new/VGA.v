`include "Constant.v"

module VGA (  // 640*480@60Hz
    input clk,
    input rst_n,
    input [15:0] script,
    input [7:0] in_bits,
    input [7:0] out_bits,
    output hsync,   // line synchronization signal
    output vsync,   // vertical synchronization signal
    // 3 color output
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

    wire vga_clk;  // 25MHz
    clk_wiz_0 clk_inst(   // clk_wiz_0 used ip core
        .clk_in1(clk),
        .clk_out1(vga_clk)
    );

    // 0 and 1 pixels
    parameter zero = {
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111100000000001111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000,
        30'b000001111111111111111111100000
    };
    parameter one = {
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000,
        30'b000001111100000000000000000000
    };

    // horizontal counter
    reg [9:0] hc;
    always @(posedge vga_clk) begin
        if (~rst_n) hc <= 0;
        else if (hc == `H_LINE_PERIOD - 1) hc <= 0;
        else hc <= hc + 1;
    end

    // vertical counter
    reg [9:0] vc;
    always @(posedge vga_clk) begin
        if (~rst_n) vc <= 0;
        else if (vc == `V_FRAME_PERIOD - 1) vc <= 0;
        else if (hc == `H_LINE_PERIOD - 1) vc <= vc + 1;
        else vc <= vc;
    end

    wire [9:0] hc0, vc0;
    assign hsync = (hc < `H_SYNC_PULSE) ? 0 : 1;
    assign vsync = (vc < `V_SYNC_PULSE) ? 0 : 1;
    assign hc0 = hc - `H_SYNC_PULSE - `H_BACK_PORCH;
    assign vc0 = vc - `V_SYNC_PULSE - `V_BACK_PORCH;

    wire active;  // is the point active
    assign active = (hc >= `H_SYNC_PULSE + `H_BACK_PORCH) &&
                    (hc < `H_SYNC_PULSE + `H_BACK_PORCH + `H_ACTIVE_TIME) &&
                    (vc >= `V_SYNC_PULSE + `V_BACK_PORCH) &&
                    (vc < `V_SYNC_PULSE + `V_BACK_PORCH + `V_ACTIVE_TIME) ? 1 : 0;

    reg [9:0] idx;

    always @(*) begin
        if (~rst_n) begin
            red = 0;
            green = 0;
            blue = 0;
        end
        else if (active) begin
            ////// script //////
            if (hc0 >= 80 + 0*`char_width && hc0 < 80 + 1*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 + 30 * (vc0 - 140);
                if (script[15] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 1*`char_width && hc0 < 80 + 2*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - `char_width + 30 * (vc0 - 140);
                if (script[14] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 2*`char_width && hc0 < 80 + 3*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 2*`char_width + 30 * (vc0 - 140);
                if (script[13] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 3*`char_width && hc0 < 80 + 4*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 3*`char_width + 30 * (vc0 - 140);
                if (script[12] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 4*`char_width && hc0 < 80 + 5*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 4*`char_width + 30 * (vc0 - 140);
                if (script[11] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 5*`char_width && hc0 < 80 + 6*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 5*`char_width + 30 * (vc0 - 140);
                if (script[10] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 6*`char_width && hc0 < 80 + 7*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 6*`char_width + 30 * (vc0 - 140);
                if (script[9] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 7*`char_width && hc0 < 80 + 8*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 7*`char_width + 30 * (vc0 - 140);
                if (script[8] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 8*`char_width && hc0 < 80 + 9*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 8*`char_width + 30 * (vc0 - 140);
                if (script[7] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 9*`char_width && hc0 < 80 + 10*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 9*`char_width + 30 * (vc0 - 140);
                if (script[6] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 10*`char_width && hc0 < 80 + 11*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 10*`char_width + 30 * (vc0 - 140);
                if (script[5] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 11*`char_width && hc0 < 80 + 12*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 11*`char_width + 30 * (vc0 - 140);
                if (script[4] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 12*`char_width && hc0 < 80 + 13*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 12*`char_width + 30 * (vc0 - 140);
                if (script[3] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 13*`char_width && hc0 < 80 + 14*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 13*`char_width + 30 * (vc0 - 140);
                if (script[2] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 14*`char_width && hc0 < 80 + 15*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 14*`char_width + 30 * (vc0 - 140);
                if (script[1] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 80 + 15*`char_width && hc0 < 80 + 16*`char_width && vc0 >= 140 && vc0 < 140 + `char_width) begin
                idx = hc0 - 80 - 15*`char_width + 30 * (vc0 - 140);
                if (script[0] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            ////// in_bits //////
            else if (hc0 >= 65 + 0*`char_width && hc0 < 65 + 1*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 0*`char_width + 30 * (vc0 - 310);
                if (in_bits[7] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 1*`char_width && hc0 < 65 + 2*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 1*`char_width + 30 * (vc0 - 310);
                if (in_bits[6] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 2*`char_width && hc0 < 65 + 3*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 2*`char_width + 30 * (vc0 - 310);
                if (in_bits[5] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 3*`char_width && hc0 < 65 + 4*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 3*`char_width + 30 * (vc0 - 310);
                if (in_bits[4] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 4*`char_width && hc0 < 65 + 5*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 4*`char_width + 30 * (vc0 - 310);
                if (in_bits[3] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 5*`char_width && hc0 < 65 + 6*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 5*`char_width + 30 * (vc0 - 310);
                if (in_bits[2] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 6*`char_width && hc0 < 65 + 7*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 6*`char_width + 30 * (vc0 - 310);
                if (in_bits[1] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 65 + 7*`char_width && hc0 < 65 + 8*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 65 - 7*`char_width + 30 * (vc0 - 310);
                if (in_bits[0] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            ////// out_bits //////
            else if (hc0 >= 335 + 0*`char_width && hc0 < 335 + 1*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 0*`char_width + 30 * (vc0 - 310);
                if (out_bits[7] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 1*`char_width && hc0 < 335 + 2*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 1*`char_width + 30 * (vc0 - 310);
                if (out_bits[6] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 2*`char_width && hc0 < 335 + 3*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 2*`char_width + 30 * (vc0 - 310);
                if (out_bits[5] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 3*`char_width && hc0 < 335 + 4*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 3*`char_width + 30 * (vc0 - 310);
                if (out_bits[4] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 4*`char_width && hc0 < 335 + 5*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 4*`char_width + 30 * (vc0 - 310);
                if (out_bits[3] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 5*`char_width && hc0 < 335 + 6*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 5*`char_width + 30 * (vc0 - 310);
                if (out_bits[2] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 6*`char_width && hc0 < 335 + 7*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 6*`char_width + 30 * (vc0 - 310);
                if (out_bits[1] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else if (hc0 >= 335 + 7*`char_width && hc0 < 335 + 8*`char_width && vc0 >= 310 && vc0 < 310 + `char_width) begin
                idx = hc0 - 335 - 7*`char_width + 30 * (vc0 - 310);
                if (out_bits[0] == 0)
                    if (zero[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
                else 
                    if (one[idx] == 1) {red, green, blue} = 12'hfff;
                    else {red, green, blue} = 12'h000;
            end
            else
                {red, green, blue} = 12'h000;
        end
    end

endmodule