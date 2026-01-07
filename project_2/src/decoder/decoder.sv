`timescale 1ns/1ps
import alu_types_pkg::*;
import decoder_pkg::*;
import M_types_pkg::*; // Mở comment nếu bạn dùng M-extension constants

module decoder (
    // Input từ tầng Fetch (qua pipeline reg)
    input  opcodes_t      opcodes, 
    
    // --- Signals cho tầng EX (Execute) ---
    output logic [1:0]    aluMuxData,
    output logic [3:0]    alu_decoder,
    output logic [2:0]    M_decoder,
    output logic          alu_src,    // 0: rs2, 1: Imm
    
    // --- Signals cho tầng MEM (Memory) ---
    output mem_ctrl_t     dmemory,    // Struct chứa read, write, width
    
    // --- Signals cho tầng WB (Write Back) ---
    // [UPDATE] Sử dụng Enum thay vì logic [2:0]
    output wb_mux_t       writeBackMux, 
    output logic          reg_write,
    
    // --- Signals cho Hazard / Branch ---
    output jumps_ctrl_t   jumps,      
    output logic [2:0]    imm_src,    
    output cpu_state_t    cpu_state,
    
    // --- CSR Signals ---
    output logic          csr_write,
    output logic          csr_load_imm,
    output logic          mret
);

    // Biến trung gian giải mã ALU
    logic [1:0] alu_op_main; 

    // =========================================================
    // 1. MAIN DECODER (Opcode -> Control Signals)
    // =========================================================
    always_comb begin
        // --- Default / Safe Values (Tránh Latch) ---
        reg_write    = 1'b0;
        alu_src      = 1'b0; 
        writeBackMux = WB_ALU; // [UPDATE] Mặc định là ALU Result
        imm_src      = 3'b000;
        alu_op_main  = 2'b00;
        jumps        = '0;
        dmemory      = '0;
        cpu_state    = '0;
        csr_write    = 1'b0;
        csr_load_imm = 1'b0;
        mret         = 1'b0;
        aluMuxData   = 2'b00;

        case (opcodes.opcode)
            // ---------------------------------------------
            // R-Type Instructions (ADD, SUB, AND, OR...)
            // ---------------------------------------------
            TYPE_R: begin 
                reg_write    = 1'b1;
                alu_src      = 1'b0; // Dùng rs2
                alu_op_main  = 2'b10; 
                
                // Logic cho M-Extension (Nên gom vào ALU result hoặc xử lý riêng)
                // Ở đây ta giả định M-Ext cũng trả về qua đường ALU
                writeBackMux = WB_ALU; 
            end

            // ---------------------------------------------
            // I-Type Instructions (ADDI, ANDI...)
            // ---------------------------------------------
            TYPE_I: begin 
                reg_write    = 1'b1;
                alu_src      = 1'b1; // Dùng Immediate
                imm_src      = 3'b000; 
                alu_op_main  = 2'b10;
                writeBackMux = WB_ALU;
            end

            // ---------------------------------------------
            // Load Instructions (LW, LB, LH...)
            // ---------------------------------------------
            TYPE_L: begin 
                reg_write    = 1'b1;
                alu_src      = 1'b1; // Tính địa chỉ: rs1 + imm
                imm_src      = 3'b000;
                alu_op_main  = 2'b00; // ALU làm phép cộng
                
                writeBackMux = WB_MEM; // [UPDATE] Chọn dữ liệu từ Memory
                dmemory.read = 1'b1;   // Báo tín hiệu đọc
            end

            // ---------------------------------------------
            // Store Instructions (SW, SB, SH...)
            // ---------------------------------------------
            TYPE_S: begin 
                alu_src       = 1'b1;
                imm_src       = 3'b001; // S-type imm
                alu_op_main   = 2'b00;
                dmemory.write = 1'b1;   // Báo tín hiệu ghi
            end

            // ---------------------------------------------
            // Branch Instructions (BEQ, BNE...)
            // ---------------------------------------------
            TYPE_BRANCH: begin 
                alu_src         = 1'b0;
                imm_src         = 3'b010; // B-type imm
                alu_op_main     = 2'b01;  // ALU so sánh
                jumps.load      = 1'b1;   // Cho phép nhảy có điều kiện
                jumps.load_from = 2'b01;
            end

            // ---------------------------------------------
            // Jump (JAL)
            // ---------------------------------------------
            TYPE_JAL: begin 
                reg_write     = 1'b1;
                imm_src       = 3'b011; // J-type imm
                writeBackMux  = WB_PC4; // [UPDATE] Ghi PC+4 vào rd
                jumps.load    = 1'b1;   // Nhảy không điều kiện
                jumps.load_from = 2'b00;
            end

            // ---------------------------------------------
            // Jump Register (JALR)
            // ---------------------------------------------
            TYPE_JALR: begin
                reg_write     = 1'b1;
                alu_src       = 1'b1; 
                imm_src       = 3'b000; // I-type imm
                writeBackMux  = WB_PC4; // [UPDATE] Ghi PC+4 vào rd
                jumps.load    = 1'b1;
                jumps.load_from = 2'b11; 
            end

            // ---------------------------------------------
            // Load Upper Immediate (LUI)
            // ---------------------------------------------
            TYPE_LUI: begin
                reg_write    = 1'b1;
                imm_src      = 3'b100; // U-type imm
                writeBackMux = WB_IMM; // [UPDATE] Ghi thẳng Imm vào rd
            end
            
            // ---------------------------------------------
            // Add Upper Immediate to PC (AUIPC) - Placeholder
            // ---------------------------------------------
            TYPE_AUIPC: begin
               reg_write    = 1'b1;
               imm_src      = 3'b100; // U-type
               alu_src      = 1'b1;   // Dùng Imm
               // Cần ALU hỗ trợ cộng PC + Imm (chưa implement trong ALU decoder này)
               // Tạm thời để WB_ALU
               writeBackMux = WB_ALU; 
            end

            // ---------------------------------------------
            // System Instructions (CSR, EBREAK, MRET)
            // ---------------------------------------------
            TYPE_ENV_BREAK_CSR: begin // TYPE_ENV_CSR
                if (opcodes.funct3 != 3'b000) begin
                    // CSR Instructions (CSRRW, CSRRS, etc.)
                    reg_write    = 1'b1;
                    alu_src      = 1'b1; 
                    imm_src      = 3'b000; // I-type (Z-imm handled in pipeline)
                    csr_write    = 1'b1; 
                    writeBackMux = WB_CSR; // [UPDATE] Đọc từ CSR
                end else begin
                    // PRIVILEGED INSTRUCTIONS (ECALL, EBREAK, MRET)
                    case (opcodes.funct12)
                        12'b001100000010: mret = 1'b1; // MRET
                        // 12'b000000000000: // ECALL (Trap)
                        // 12'b000000000001: // EBREAK (Trap)
                        default: ;
                    endcase
                end
            end
            
            default: cpu_state.error = 1'b1;
        endcase
        
        // Thiết lập kích thước truy cập bộ nhớ (LB, LH, LW)
        dmemory.word_size  = opcodes.funct3[1:0];
        // Bit 2 của funct3 quyết định Sign Extension (0: Signed, 1: Unsigned cho LBU/LHU)
        // Tuy nhiên logic này phụ thuộc vào cách bạn định nghĩa signal_ext. 
        // Thường: LB (funct3=000) -> ext=1. LBU (funct3=100) -> ext=0.
        // => signal_ext = ~funct3[2]
        dmemory.signal_ext = ~opcodes.funct3[2]; 
    end
    

    // =========================================================
    // 2. ALU DECODER 
    // =========================================================
    always_comb begin
        alu_decoder = ALU_ADD;
        M_decoder   = 3'b000;

        case (alu_op_main)
            2'b00: alu_decoder = ALU_ADD; // Load/Store (Add Base + Offset)
            2'b01: alu_decoder = ALU_SUB; // Branch (So sánh)
            
            default: begin // R-type hoặc I-type (alu_op_main = 10)
                case (opcodes.funct3)
                    TYPE_ADD_SUB: begin
                        if (opcodes.opcode == TYPE_R && opcodes.funct7 == TYPE_SUB)
                             alu_decoder = ALU_SUB;
                        else alu_decoder = ALU_ADD;
                    end
                    TYPE_AND: alu_decoder = ALU_AND;
                    TYPE_OR:  alu_decoder = ALU_OR;
                    TYPE_XOR: alu_decoder = ALU_XOR;
                    TYPE_SLT: alu_decoder = ALU_SLT;
                    TYPE_SLU: alu_decoder = ALU_SLT; // SLTU (Lưu ý: Cần ALU hỗ trợ unsigned)
                    
                    TYPE_SR: begin // SRA / SRL
                        if (opcodes.funct7 == TYPE_SRAI) alu_decoder = ALU_SRA;
                        else                             alu_decoder = ALU_SRL;
                    end
                    
                    TYPE_SLL: alu_decoder = ALU_SLL;
                    
                    default:  alu_decoder = ALU_ADD;
                endcase
                
                // Logic cho M Extension
                if (opcodes.opcode == TYPE_R && opcodes.funct7 == TYPE_MULDIV) begin
                    M_decoder = opcodes.funct3; 
                end
            end
        endcase
    end

endmodule