`timescale 1ns/1ps
import memory_pkg::*;

module imemory (
    input  logic        clk,
    input  logic        rst,
    // Instruction Fetch
    input  logic [31:0] i_address,
    output logic [31:0] i_data,
    // Data Access (Load constants)
    input  logic [31:0] d_address,
    input  logic        d_read,
    input  dev_sel_t    dcsel,
    output logic [31:0] d_data_out
);

    // Khai báo mảng nhớ
    logic [31:0] ram [0:4095];

    // [FIX QUAN TRỌNG NHẤT]
    // Vòng lặp này sẽ biến tất cả XXXXXXXXXXXXXXXX thành 0000000000000000
    initial begin
        integer i;
        for (i = 0; i < 4096; i = i + 1) begin
            ram[i] = 32'h00000000; // Khởi tạo giá trị mặc định là 0 (NOP)
        end
    end

    // Logic đọc lệnh (Word Aligned)
    assign i_data = ram[i_address[13:2]];

    // Logic đọc dữ liệu
    always_comb begin
        if (d_read && (dcsel == DEV_IMEM)) begin
            d_data_out = ram[d_address[13:2]];
        end else begin
            d_data_out = 32'b0;
        end
    end

endmodule