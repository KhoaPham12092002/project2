`timescale 1ns/1ps
import alu_types_pkg::*;
import decoder_pkg::*;
module iregister (
    input  logic        clk,     // Cần clock để chốt dữ liệu
    input  logic        rst,     // Reset để đưa các đầu ra về 0
    input  logic [31:0] instr,   // Lệnh thô từ Fetch stage
    
    // Opcodes & Register Addresses
    output opcodes_t    opcodes, 
    output logic [4:0]  rd,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    
    // Immediates 
    output logic [31:0] imm_i,
    output logic [31:0] imm_s,
    output logic [31:0] imm_b,
    output logic [31:0] imm_u,
    output logic [31:0] imm_j
);

    // Sử dụng always_ff for Pipeline Register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset 
            opcodes <= '0;
            rd      <= 5'd0;
            rs1     <= 5'd0;
            rs2     <= 5'd0;
            imm_i   <= 32'd0;
            imm_s   <= 32'd0;
            imm_b   <= 32'd0;
            imm_u   <= 32'd0;
            imm_j   <= 32'd0;
        end else begin
            // ---Tách bit (Slicing) ---
            opcodes.opcode  <= instr[6:0];
            opcodes.funct3  <= instr[14:12];
            opcodes.funct7  <= instr[31:25];
            opcodes.funct12 <= instr[31:20];
            
            rd  <= instr[11:7];
            rs1 <= instr[19:15];
            rs2 <= instr[24:20];

            // --- Mở rộng dấu (Immediate Gen) ---
            imm_i <= {{20{instr[31]}}, instr[31:20]};
            imm_s <= {{20{instr[31]}}, instr[31:25], instr[11:7]};
            imm_b <= {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            imm_u <= {instr[31:12], 12'b0};
            imm_j <= {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        end
    end

endmodule