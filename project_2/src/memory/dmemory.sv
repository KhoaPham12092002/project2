`timescale 1ns/1ps
import memory_pkg::*;

module dmemory (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] address,
    input  logic [31:0] data,
    input  logic        we,
    input  dev_sel_t    dcsel,
    input  logic [3:0]  dmask,
    input  logic        signal_ext,
    output logic [31:0] q
);

    // QUAN TRỌNG: Dùng mảng ram thuần, không dùng IP Core
    logic [31:0] ram [0:4095];
    logic [31:0] ram_q_raw;

    always_ff @(posedge clk) begin
        if (we && (dcsel == DEV_DMEM)) begin
            if (dmask[0]) ram[address[13:2]][7:0]   <= data[7:0];
            if (dmask[1]) ram[address[13:2]][15:8]  <= data[15:8];
            if (dmask[2]) ram[address[13:2]][23:16] <= data[23:16];
            if (dmask[3]) ram[address[13:2]][31:24] <= data[31:24];
        end
    end

    assign ram_q_raw = (dcsel == DEV_DMEM) ? ram[address[13:2]] : 32'b0;

    always_comb begin
        q = 32'b0;
        if (dcsel == DEV_DMEM) begin
            case (dmask)
                4'b1111: q = ram_q_raw;
                4'b0011: q = (signal_ext && ram_q_raw[15]) ? {16'hFFFF, ram_q_raw[15:0]} : {16'h0000, ram_q_raw[15:0]};
                4'b1100: q = (signal_ext && ram_q_raw[31]) ? {16'hFFFF, ram_q_raw[31:16]} : {16'h0000, ram_q_raw[31:16]};
                4'b0001: q = (signal_ext && ram_q_raw[7])  ? {24'hFFFFFF, ram_q_raw[7:0]}  : {24'h000000, ram_q_raw[7:0]};
                4'b0010: q = (signal_ext && ram_q_raw[15]) ? {24'hFFFFFF, ram_q_raw[15:8]} : {24'h000000, ram_q_raw[15:8]};
                4'b0100: q = (signal_ext && ram_q_raw[23]) ? {24'hFFFFFF, ram_q_raw[23:16]} : {24'h000000, ram_q_raw[23:16]};
                4'b1000: q = (signal_ext && ram_q_raw[31]) ? {24'hFFFFFF, ram_q_raw[31:24]} : {24'h000000, ram_q_raw[31:24]};
                default: q = 32'b0;
            endcase
        end
    end

endmodule