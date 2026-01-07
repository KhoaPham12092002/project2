module control_unit (
    /* verilator lint_off UNUSED */
    input  logic [W-1:0] instr,
    
    output logic [2:0]   imm_gen_sel,        // 000:R, 001:I, 010:B, 011:J1, 100:J2, 101:U1, 110:U2, 111:S
    output logic [3:0]   alu_op ,            // 0000:ADD, 0001:SUB, 0010:XOR, 0011:AND, 0100:OR, 0101:SLL, 0110:SRL, 0111:SRA, 1000:SLT, 1001:SLTU, 1010:LUI
    output logic         reg_wr_en,          // 1 if writing to the RegFile, otherwise 0
    output logic         PC_sel,             // select signal between pc+4:0 or pc ALU:1
    output logic         branch_u,           // 1 if the two operands are unsigned.
    output logic         dmem_wr,            // 1 write LSU, otherwise 0 
    output logic         op_a_sel,           // choose between rs1_ (0) or pc (1) to wire into operand_a of ALU.
    output logic         op_b_sel,           // choose between rs2_ (0) or imm (1) to wire into operand_b of ALU   
    output logic [1:0]   wb_sel              // choose between alu_ (0), ld_ (1), or pc_four (2) to write back into rd_ of RegFile
);
parameter W = 32;
    // parameter format command
    parameter       OP         =   5'b01100;
    parameter       OP_IMM     =   5'b00100;
    parameter       LOAD       =   5'b00000;
    parameter       STORE      =   5'b01000;
    parameter       BRANCH     =   5'b11000;
    parameter       LUI        =   5'b01101;
    parameter       AUIPC      =   5'b00101;
    parameter       JAL        =   5'b11011;
    parameter       JALR       =   5'b11001;
    parameter       HEX_DEC    =   5'b11111;
    // parameter function in format command 
        // OP
    parameter       ADD_SUB             =   3'b000;      
    parameter       SLL                 =   3'b001;
    parameter       SLT                 =   3'b010;
    parameter       SLTU                =   3'b011;
    parameter       XOR                 =   3'b100;
    parameter       SRL_SRA             =   3'b101;
    parameter       OR                  =   3'b110;
    parameter       AND                 =   3'b111;
        
        // OP_IMM
    parameter       ADDI                =   3'b000;
    parameter       SLTI                =   3'b010;
    parameter       SLTIU               =   3'b011;
    parameter       XORI                =   3'b100;
    parameter       ORI                 =   3'b110;
    parameter       ANDI                =   3'b111;
    parameter       SLLI                =   3'b001;
    parameter       SRLI_SRAI           =   3'b101;
        
        // LOAD
    
    parameter       LB                  =   3'b000;
    parameter       LH                  =   3'b001;
    parameter       LW                  =   3'b010;
    parameter       LBU                 =   3'b100;
    parameter       LHU                 =   3'b101;
        
        // STORE
    parameter       SB                  =   3'b000;
    parameter       SH                  =   3'b001;
    parameter       SW                  =   3'b010;
    
    
        // BRANCH
    parameter       BEQ                 =   3'b000;
    parameter       BNE                 =   3'b001;
    parameter       BLT                 =   3'b100;
    parameter       BGE                 =   3'b101;
    parameter       BLTU                =   3'b110;
    parameter       BGEU                =   3'b111;

    always_comb begin 
        case(instr[6:2])
	    HEX_DEC: begin
		                                        PC_sel       = 1'b0;
                                                        imm_gen_sel  = 3'b000;
                                                        alu_op       = 4'b0000;
                                                        branch_u     = 1'b0;
                                                        dmem_wr      = 1'b0;
                                                        op_a_sel      = 1'b0;
                                                        op_b_sel      = 1'b0;
                                                        wb_sel        = 2'b11;
                                                        reg_wr_en    = 1'b1;
	    end    
            OP: begin
                case(instr[14:12])
                    ADD_SUB: begin 
                        if(!instr[30]) begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel      = 1'b0;
							op_b_sel      = 1'b0;
							wb_sel        = 2'b00;
							reg_wr_en    = 1'b1;
                        end else begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0001;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                        end
                    end                              
                    SLL    :begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0101;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    SLT    :begin  
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b1000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    SLTU   :begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b1001;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    XOR    :begin        
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0010;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    SRL_SRA: begin                   
                        if(!instr[30]) begin 
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0110;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                        end else begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0111;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                        end
                    end                              
                    OR     :begin                 
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0100;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    AND    : begin               
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0011;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    default: begin                   
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                       
                endcase                              
            end 
            OP_IMM: begin                
                case(instr[14:12])                 
                    ADDI: begin              
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    SLTI: begin             
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b1000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end 
                    SLTIU: begin           
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b1001;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    XORI:begin           
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0010;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    ORI: begin          
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0100;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    ANDI: begin         
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0011;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end
                    SLLI:begin        
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0101;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                    end 
                    SRLI_SRAI: begin                      
                        if(!instr[30]) begin   
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0110;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                        end else begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0111;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
                        end 
                    end                              
                    default: begin                   
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                              
                endcase                              
            end                                      
            LOAD: begin                 
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b001;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b01;
							reg_wr_en    = 1'b1;
            end                          
            STORE: begin                
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b111;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b1;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
            end                         
            BRANCH: begin                         
                case(instr[14:12])                 
                    BEQ: begin                       
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                              
                    BNE: begin                       
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                              
                    BLT: begin                       
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                              
                    BGE: begin                       
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                             
                    BLTU: begin                      
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                             
                    BGEU: begin                     
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b010;
							alu_op       = 4'b0000;
							branch_u     = 1'b1;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end                             
                    default: begin                  
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
                    end
                endcase            
            end
            LUI: begin                                 
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b101;
							alu_op       = 4'b1010;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
            end 
            AUIPC: begin               
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b101;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b1;
							op_b_sel     = 1'b1;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b1;
            end
            JAL: begin              
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b011;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b10;
							reg_wr_en    = 1'b1;
            end
            JALR: begin             
							PC_sel       = 1'b1;
							imm_gen_sel  = 3'b100;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b10;
							reg_wr_en    = 1'b1;
            end 
            default: begin
							PC_sel       = 1'b0;
							imm_gen_sel  = 3'b000;
							alu_op       = 4'b0000;
							branch_u     = 1'b0;
							dmem_wr      = 1'b0;
							op_a_sel     = 1'b0;
							op_b_sel     = 1'b0;
							wb_sel       = 2'b00;
							reg_wr_en    = 1'b0;
            end
        endcase 
    end
endmodule
