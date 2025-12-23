import alu_types_pkg::*;

module alu (
    input  alu_data_t         alu_data,
    output logic signed [31:0] dataOut
);

    // Tín hiệu nội bộ
    logic [4:0] shamt;
    assign shamt = alu_data.b[4:0]; // Lấy 5 bit thấp để dịch

    

    always_comb begin
        case (alu_data.code)
            // Toán học
            ALU_ADD:  dataOut = alu_data.a + alu_data.b;
            ALU_SUB:  dataOut = alu_data.a - alu_data.b;
            
            // Dịch bit
            ALU_SLL:  dataOut = alu_data.a <<  shamt;
            ALU_SRL:  dataOut = alu_data.a >>  shamt;
            
            // Sửa lỗi SRA: Sử dụng toán tử >>> cho dịch phải số học (giữ bit dấu)
            ALU_SRA:  dataOut = alu_data.a >>> shamt; 

            // So sánh (Set Less Than)
            ALU_SLT:  dataOut = (alu_data.a < alu_data.b) ? 32'd1 : 32'd0;
            ALU_SLTU: dataOut = (unsigned'(alu_data.a) < unsigned'(alu_data.b)) ? 32'd1 : 32'd0;

            // Logic
            ALU_XOR:  dataOut = alu_data.a ^ alu_data.b;
            ALU_OR:   dataOut = alu_data.a | alu_data.b;
            ALU_AND:  dataOut = alu_data.a & alu_data.b;

            default:  dataOut = 32'sh0;
        endcase
    end

endmodule