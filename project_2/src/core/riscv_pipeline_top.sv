`timescale 1ns/1ps
import M_types_pkg::*;
import alu_types_pkg::*;
import decoder_pkg::*; 

module riscv_pipeline_top (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] interrupts,

    output logic [31:0] i_address,
    input  logic [31:0] i_data,
    output logic [31:0] d_address,
    output logic [31:0] d_data_w,
    input  logic [31:0] d_data_r,
    output mem_ctrl_t   dmemory_ctrl
);

    // ========================================================================
    // 1. SIGNAL DECLARATIONS
    // ========================================================================
    wb_mux_t writeBackMux_d, writeBackMux_e, writeBackMux_m, writeBackMux_w;
    logic [1:0] forward_a_e, forward_b_e;
    logic       stall_f, stall_d, stall_e, stall_m, stall_w;
    logic       flush_d, flush_e;
    logic       mem_req_m, mem_done_m;

    logic [31:0] pc_f, pc_next_f, pc_plus4_f;
    logic [31:0] pc_d, pc_plus4_d, instr_d;
    logic [31:0] pc_e, pc_plus4_e;
    logic [31:0] pc_plus4_m, pc_plus4_w;
    
    opcodes_t    opcodes_d, opcodes_e;
    logic [4:0]  rd_d, rs1_d, rs2_d;
    logic [4:0]  rd_e, rs1_e, rs2_e; 
    logic [4:0]  rd_m, rd_w;
    
    logic [31:0] imm_i_d, imm_s_d, imm_b_d, imm_u_d, imm_j_d, imm_final_d;
    logic [31:0] imm_e, imm_m, imm_w;
    logic [31:0] r1_data_raw, r2_data_raw, r1_data_d, r2_data_d;     
    logic [31:0] rs1_data_e, rs2_data_e;   

    logic [3:0]  alu_decoder_d, alu_decoder_e;
    logic [2:0]  M_decoder_d;
    logic        alu_src_d, alu_src_e;
    mem_ctrl_t   dmemory_d, dmemory_e;
    logic        reg_write_d, reg_write_e, reg_write_m, reg_write_w;
    jumps_ctrl_t jumps_d, jumps_e;
    logic        csr_write_d, csr_write_e, mret_d, mret_e;
    logic [2:0]  imm_src_d;
    logic [1:0]  ulaMuxData_d;
    cpu_state_t  cpu_state_d;

    logic [31:0] src_a_forwarded, write_data_forwarded;
    logic [31:0] src_b_alu;
    alu_data_t   alu_in;
    
    logic [31:0] alu_core_result; 
    logic [31:0] alu_out_e;       
    
    logic [31:0] alu_out_m, alu_out_w;
    logic        alu_zero_e;
    logic        pc_src_e;
    logic [31:0] pc_target_e, pc_branch_target;

    logic        is_m_instr_e;    
    M_data_t     m_data_in;       
    logic [31:0] m_result;        
    logic        m_ready;         
    logic        m_stall_req;    

    logic [31:0] rs2_data_m, read_data_w, result_w;
    logic [31:0] csr_rdata_e, csr_rdata_m, csr_rdata_w;
    logic        csr_load_mepc;
    logic [31:0] csr_mepc_target;

    // ========================================================================
    // 2. HAZARD UNIT & MEMORY HANDSHAKE
    // ========================================================================
    logic is_load_e;
    assign is_load_e = (opcodes_e.opcode == 7'b0000011);
    assign mem_req_m = dmemory_ctrl.read | dmemory_ctrl.write;
    
    logic mem_done_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) mem_done_reg <= 0;
        else     mem_done_reg <= mem_req_m & ~mem_done_reg; 
    end
    assign mem_done_m = mem_done_reg; 

    hazard_unit hu (
        .stall_m_req (m_stall_req), 
        .clk(clk), .rst(rst),
        .rs1_e(rs1_e), .rs2_e(rs2_e), 
        .rd_m(rd_m), .reg_write_m(reg_write_m), 
        .rd_w(rd_w), .reg_write_w(reg_write_w),
        .rs1_d(rs1_d), .rs2_d(rs2_d), .rd_e(rd_e), 
        .is_load_e(is_load_e), .pc_src_e(pc_src_e),
        .mem_req_m(mem_req_m), .mem_done_m(mem_done_m), 
        .forward_a_e(forward_a_e), .forward_b_e(forward_b_e),
        .stall_f(stall_f), .stall_d(stall_d), .stall_e(stall_e), 
        .stall_m(stall_m), .stall_w(stall_w),
        .flush_d(flush_d), .flush_e(flush_e)
    );

    // ========================================================================
    // 3. FETCH STAGE
    // ========================================================================
    always_comb begin
        if (csr_load_mepc)      pc_next_f = csr_mepc_target;
        else if (pc_src_e)      pc_next_f = pc_target_e;
        else                    pc_next_f = pc_f + 32'd4;
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) pc_f <= 32'h0;
        else if (!stall_f) pc_f <= pc_next_f;
    end
    assign i_address = pc_f;
    assign pc_plus4_f = pc_f + 32'd4;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            instr_d <= 32'h00000013; pc_d <= 0; pc_plus4_d <= 0;
        end else if (flush_d) begin
            instr_d <= 32'h00000013; pc_d <= 0; pc_plus4_d <= 0;
        end else if (!stall_d) begin
            instr_d <= i_data; pc_d <= pc_f; pc_plus4_d <= pc_plus4_f;
        end
    end

    // ========================================================================
    // 4. DECODE STAGE
    // ========================================================================
    assign opcodes_d.opcode  = instr_d[6:0];
    assign opcodes_d.funct3  = instr_d[14:12];
    assign opcodes_d.funct7  = instr_d[31:25];
    assign opcodes_d.funct12 = instr_d[31:20];
    assign rd_d  = instr_d[11:7];
    assign rs1_d = instr_d[19:15];
    assign rs2_d = instr_d[24:20];

    assign imm_i_d = {{20{instr_d[31]}}, instr_d[31:20]};
    assign imm_s_d = {{20{instr_d[31]}}, instr_d[31:25], instr_d[11:7]};
    assign imm_b_d = {{20{instr_d[31]}}, instr_d[7], instr_d[30:25], instr_d[11:8], 1'b0};
    assign imm_u_d = {instr_d[31:12], 12'b0};
    assign imm_j_d = {{12{instr_d[31]}}, instr_d[19:12], instr_d[20], instr_d[30:21], 1'b0};

    always_comb begin
        case (imm_src_d)
            3'b000: imm_final_d = imm_i_d;
            3'b001: imm_final_d = imm_s_d;
            3'b010: imm_final_d = imm_b_d;
            3'b011: imm_final_d = imm_j_d;
            3'b100: imm_final_d = imm_u_d;
            default: imm_final_d = 32'b0;
        endcase
    end

    decoder main_decoder (
        .opcodes(opcodes_d),
        .ulaMuxData(ulaMuxData_d), .alu_decoder(alu_decoder_d), .M_decoder(M_decoder_d), .alu_src(alu_src_d),
        .dmemory(dmemory_d), .writeBackMux(writeBackMux_d), .reg_write(reg_write_d),
        .jumps(jumps_d), .imm_src(imm_src_d), .cpu_state(cpu_state_d),
        .csr_write(csr_write_d), .mret(mret_d), .csr_load_imm()
    );

    register_file rf (
        .clk(clk), .rst(rst),
        .w_ena(reg_write_w && !stall_w), .w_address(rd_w), .w_data(result_w), 
        .r1_address(rs1_d), .r1_data(r1_data_raw), .r2_address(rs2_d), .r2_data(r2_data_raw)                   
    );

    always_comb begin
        if (reg_write_w && (rd_w != 0) && (rd_w == rs1_d)) r1_data_d = result_w;    
        else r1_data_d = r1_data_raw; 
        if (reg_write_w && (rd_w != 0) && (rd_w == rs2_d)) r2_data_d = result_w;    
        else r2_data_d = r2_data_raw; 
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst || flush_e) begin 
            reg_write_e <= 0; dmemory_e <= '0; jumps_e <= '0; csr_write_e <= 0; mret_e <= 0;
            writeBackMux_e <= WB_ALU; alu_src_e <= 0; alu_decoder_e <= 0;
            pc_e <= 0; pc_plus4_e <= 0; rs1_data_e <= 0; rs2_data_e <= 0; imm_e <= 0; 
            rd_e <= 0; rs1_e <= 0; rs2_e <= 0; opcodes_e <= '0;
        end else if (!stall_e) begin
            reg_write_e <= reg_write_d; dmemory_e <= dmemory_d; jumps_e <= jumps_d;
            alu_decoder_e <= alu_decoder_d; alu_src_e <= alu_src_d; 
            writeBackMux_e <= writeBackMux_d; csr_write_e <= csr_write_d; mret_e <= mret_d;
            pc_e <= pc_d; pc_plus4_e <= pc_plus4_d;
            rs1_data_e <= r1_data_d; rs2_data_e <= r2_data_d;
            imm_e <= imm_final_d; rd_e <= rd_d; rs1_e <= rs1_d; rs2_e <= rs2_d; opcodes_e <= opcodes_d;
        end
    end

    // ========================================================================
    // 5. EXECUTE STAGE
    // ========================================================================
    always_comb begin
        case (forward_a_e)
            2'b00: src_a_forwarded = rs1_data_e;  
            2'b01: src_a_forwarded = result_w;    
            2'b10: src_a_forwarded = alu_out_m;   
            default: src_a_forwarded = rs1_data_e;
        endcase
    end
    always_comb begin
        case (forward_b_e)
            2'b00: write_data_forwarded = rs2_data_e;
            2'b01: write_data_forwarded = result_w;
            2'b10: write_data_forwarded = alu_out_m;
            default: write_data_forwarded = rs2_data_e;
        endcase
    end

    assign src_b_alu = (alu_src_e) ? imm_e : write_data_forwarded;
    assign alu_in.a = src_a_forwarded;
    assign alu_in.b = src_b_alu;
    assign alu_in.code = alu_decoder_e;

    alu alu_core (.alu_data(alu_in), .Zero(alu_zero_e), .dataOut(alu_core_result));

    assign is_m_instr_e = (opcodes_e.opcode == 7'b0110011) && (opcodes_e.funct7 == 7'b0000001);
    assign m_data_in.a    = src_a_forwarded; 
    assign m_data_in.b    = src_b_alu;       
    assign m_data_in.code = opcodes_e.funct3; 

    riscv_m_unit m_unit_inst (
        .clk(clk), .rst(rst), .valid(is_m_instr_e), 
        .m_data(m_data_in), .result(m_result), .ready(m_ready)
    );

    // [FIX FINAL] MUX CHỌN KẾT QUẢ EX (QUAN TRỌNG NHẤT)
    // Phải chọn WB_IMM nếu lệnh là LUI, WB_PC4 nếu là JAL
    always_comb begin
        if (writeBackMux_e == WB_IMM)      alu_out_e = imm_e;       // LUI
        else if (writeBackMux_e == WB_PC4) alu_out_e = pc_plus4_e;  // JAL/JALR
        else if (is_m_instr_e)             alu_out_e = m_result;    // MUL/DIV
        else                               alu_out_e = alu_core_result; // ADD/SUB/...
    end

    assign m_stall_req = is_m_instr_e & ~m_ready;

    assign pc_branch_target = pc_e + imm_e;
    always_comb begin
        pc_src_e    = 1'b0;
        pc_target_e = 32'b0;
        if (jumps_e.load && jumps_e.load_from == 2'b00) begin 
            pc_src_e = 1'b1; pc_target_e = pc_branch_target;
        end else if (jumps_e.load && jumps_e.load_from == 2'b01) begin 
             if (alu_zero_e) begin pc_src_e = 1'b1; pc_target_e = pc_branch_target; end
        end else if (jumps_e.load && jumps_e.load_from == 2'b11) begin 
             pc_src_e = 1'b1; pc_target_e = (src_a_forwarded + imm_e) & 32'hFFFFFFFE;
        end
    end

    csr csr_unit (
        .clk(clk), .rst(rst), .pending_inst(1'b0), .write(csr_write_e), .mret(mret_e),
        .next_pc(pc_e), .csr_addr(imm_e), .csr_new(src_a_forwarded), 
        .opcodes(opcodes_e), .interrupts(interrupts),
        .csr_value(csr_rdata_e), .load_mepc(csr_load_mepc), .mepc_out(csr_mepc_target)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_m <= 0; dmemory_ctrl <= '0; writeBackMux_m <= WB_ALU;
            alu_out_m <= 0; rs2_data_m <= 0; rd_m <= 0; pc_plus4_m <= 0; imm_m <= 0; csr_rdata_m <= 0;
        end else if (!stall_m) begin
            reg_write_m <= reg_write_e; dmemory_ctrl <= dmemory_e; writeBackMux_m <= writeBackMux_e;
            alu_out_m <= alu_out_e; rs2_data_m <= write_data_forwarded; rd_m <= rd_e;
            pc_plus4_m <= pc_plus4_e; imm_m <= imm_e; csr_rdata_m <= csr_rdata_e;
        end
    end

    // ========================================================================
    // 6. MEMORY STAGE
    // ========================================================================
    assign d_address = alu_out_m;
    assign d_data_w  = rs2_data_m;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_w <= 0; writeBackMux_w <= WB_ALU;
            alu_out_w <= 0; read_data_w <= 0; rd_w <= 0; pc_plus4_w <= 0; imm_w <= 0; csr_rdata_w <= 0;
        end else if (!stall_w) begin
            reg_write_w <= reg_write_m; writeBackMux_w <= writeBackMux_m;
            alu_out_w <= alu_out_m; read_data_w <= d_data_r; 
            rd_w <= rd_m; pc_plus4_w <= pc_plus4_m; imm_w <= imm_m; csr_rdata_w <= csr_rdata_m;
        end
    end

    // ========================================================================
    // 7. WRITEBACK STAGE
    // ========================================================================
    always_comb begin
        case (writeBackMux_w)
            WB_ALU: result_w = alu_out_w;
            WB_IMM: result_w = imm_w;
            WB_PC4: result_w = pc_plus4_w;
            WB_MEM: result_w = read_data_w;
            WB_CSR: result_w = csr_rdata_w;
            default: result_w = alu_out_w;
        endcase
    end

endmodule