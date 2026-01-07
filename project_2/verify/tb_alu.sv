`timescale 1ns/1ps
import alu_types_pkg::*;

module tb_alu;

    // --- 1. DUT SIGNALS ---
    alu_req_t    req;
    logic        zero;
    logic [31:0] result;

    // --- 2. INSTANTIATE DUT ---
    alu dut (
        .alu_req (req),
        .Zero    (zero),
        .alu_o   (result)
    );

    // Biến đếm lỗi
    int error_count = 0;
    int test_count = 0;

    // --- 3. MAIN TESTING PROCESS ---
    initial begin
        $display("==========================================================");
        $display("   STARTING ROBUST RISC-V ALU VERIFICATION");
        $display("==========================================================");

        // ------------------------------------------------------------
        // PHẦN 1: DIRECTED TESTS (CÁC TRƯỜNG HỢP HIỂM HÓC)
        // ------------------------------------------------------------
        $display("\n--- [PART 1] CORNER CASES (Truong hop khac khe) ---");

        // Case 1.1: Zero Flag Check
        // Kiểm tra xem kết quả = 0 thì cờ Zero có lên 1 không
        verify_alu(ALU_SUB, 32'd10, 32'd10, "SUB sets Zero Flag");

        // Case 1.2: Shift 0 bit (Không làm gì cả)
        verify_alu(ALU_SLL, 32'hDEADBEEF, 32'd0, "Shift Left by 0");

        // Case 1.3: Shift tối đa (31 bit)
        // 1 (0...01) dịch trái 31 bit -> thành số âm lớn nhất (10...0)
        verify_alu(ALU_SLL, 32'd1, 32'd31, "Shift Left Max (31)");

        // Case 1.4: Shift quá giới hạn (33 bit)
        // RISC-V chỉ lấy 5 bit cuối: 33 (100001) -> lấy 00001 -> Dịch 1 bit
        verify_alu(ALU_SRL, 32'hFFFFFFFF, 32'd33, "Shift Right Overlimit (33->1)");

        // Case 1.5: Arithmetic Shift Right (SRA) với số Âm
        // FFFFFF00 (-256) >> 4 = FFFFFFF0 (-16) (Phải giữ bit 1 ở đầu)
        verify_alu(ALU_SRA, 32'hFFFFFF00, 32'd4, "SRA on Negative Number");

        // Case 1.6: Signed Comparison (SLT) - QUAN TRỌNG
        // -1 (0xFFFFFFFF) < 10 (0x0000000A) -> TRUE (1)
        verify_alu(ALU_SLT, -32'd1, 32'd10, "SLT: Negative < Positive");

        // Case 1.7: Unsigned Comparison (SLTU) - QUAN TRỌNG
        // -1 (0xFFFFFFFF) là số cực lớn trong Unsigned -> Lớn hơn 10 -> FALSE (0)
        verify_alu(ALU_SLTU, -32'd1, 32'd10, "SLTU: Max Uint > Small Uint");

        // ------------------------------------------------------------
        // PHẦN 2: RANDOMIZED TESTS (TEST NGẪU NHIÊN)
        // ------------------------------------------------------------
        $display("\n--- [PART 2] RANDOM REGRESSION (Chay 50 lenh ngau nhien) ---");
        
        repeat (50) begin
            // Random hóa inputs
            logic [31:0] rand_a = $urandom();
            logic [31:0] rand_b = $urandom();
            
            // Random hóa Opcode (chỉ lấy trong range hợp lệ)
            // Ta dùng thủ thuật ép kiểu số sang enum
            alu_op_e rand_op;
            logic [3:0] rand_code = $urandom_range(0, 9); // 0 đến 9 tương ứng ADD đến AND
            
            // Cast về enum
            rand_op = alu_op_e'(rand_code); 

            // Gọi hàm verify
            verify_alu(rand_op, rand_a, rand_b, "Random Case");
        end

        // --- FINAL REPORT ---
        $display("\n==========================================================");
        if (error_count == 0) begin
            $display("   VICTORY! ALL %0d TESTS PASSED.", test_count);
            $display("   Your ALU is Solid Rock!");
        end else begin
            $display("   FAILURE! FOUND %0d ERRORS.", error_count);
        end
        $display("==========================================================");
        if (error_count > 0) $stop; else $finish;
    end

    // =================================================================
    // TASK: GOLDEN MODEL & CHECKER
    // Đây là "Phần mềm" mô phỏng lại hành vi đúng để so sánh với "Phần cứng"
    // =================================================================
    task verify_alu(input alu_op_e op_in, input [31:0] a_in, input [31:0] b_in, input string msg);
        logic [31:0] expected_res;
        logic        expected_zero;
        
        // 1. Setup Input cho DUT
        req.op = op_in;
        req.a  = a_in;
        req.b  = b_in;
        
        // 2. Tính toán kết quả mẫu (GOLDEN MODEL)
        // Dùng tóa tử của SystemVerilog để tính kết quả đúng tuyệt đối
        case (op_in)
            ALU_ADD:  expected_res = a_in + b_in;
            ALU_SUB:  expected_res = a_in - b_in;
            ALU_SLL:  expected_res = a_in << b_in[4:0];
            ALU_SRL:  expected_res = a_in >> b_in[4:0];
            ALU_SRA:  expected_res = $signed(a_in) >>> b_in[4:0]; // Chú ý $signed
            ALU_SLT:  expected_res = ($signed(a_in) < $signed(b_in)) ? 32'd1 : 32'd0;
            ALU_SLTU: expected_res = (a_in < b_in) ? 32'd1 : 32'd0;
            ALU_XOR:  expected_res = a_in ^ b_in;
            ALU_OR:   expected_res = a_in | b_in;
            ALU_AND:  expected_res = a_in & b_in;
            default:  expected_res = 32'b0;
        endcase
        
        expected_zero = (expected_res == 0);

        // 3. Chờ mạch chạy
        #10; 

        // 4. So sánh (Checker)
        test_count++;
        if (result !== expected_res || zero !== expected_zero) begin
            $error("[FAIL] %s", msg);
            $display("   OP: %s | A: %h | B: %h", op_in.name(), a_in, b_in);
            $display("   Expect: %h (Z=%b)", expected_res, expected_zero);
            $display("   Got   : %h (Z=%b)", result, zero);
            error_count++;
        end else begin
            // Uncomment dòng dưới nếu muốn in tất cả (sẽ rất dài)
            // $display("[PASS] %s - Result: %h", msg, result);
        end
    endtask

endmodule