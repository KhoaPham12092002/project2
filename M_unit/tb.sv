`timescale 1ns/1ps
import M_types_pkg::*;

module tb;

    // --- Signals ---
    logic         clk;
    logic         rst;
    logic         valid;
    M_req_t       m_req;
    logic [31:0]  result;
    logic         ready;
    logic         busy;

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz
    end

    // --- DUT Instantiation ---
    riscv_m_unit dut (
        .clk    (clk),
        .rst    (rst),
        .valid  (valid),
        .m_req  (m_req),
        .result (result),
        .ready  (ready),
        .busy   (busy)
    );

    // --- Reference Model Logic ---
    // Hàm tính toán kết quả mong đợi (Golden Model) để so sánh
    function [31:0] get_expected(M_req_t req);
        logic signed [31:0] s_a, s_b;
        logic [31:0] u_a, u_b;
        logic signed [63:0] s_res;
        logic [63:0] u_res;
        logic signed [63:0] su_res;

        s_a = req.a_i; s_b = req.b_i;
        u_a = req.a_i; u_b = req.b_i;

        case (req.op)
            M_MUL    : return (u_a * u_b);
            M_MULH   : begin s_res = 64'(s_a) * 64'(s_b); return s_res[63:32]; end
            M_MULHSU : begin su_res = 64'(s_a) * 64'({1'b0, u_b}); return su_res[63:32]; end
            M_MULHU  : begin u_res = 64'(u_a) * 64'(u_b); return u_res[63:32]; end
            M_DIV    : begin 
                if (u_b == 0) return 32'hFFFFFFFF;
                if (s_a == 32'h80000000 && s_b == -1) return 32'h80000000;
                return s_a / s_b;
            end
            M_DIVU   : return (u_b == 0) ? 32'hFFFFFFFF : u_a / u_b;
            M_REM    : begin 
                if (u_b == 0) return u_a;
                if (s_a == 32'h80000000 && s_b == -1) return 32'h0;
                return s_a % s_b;
            end
            M_REMU   : return (u_b == 0) ? u_a : u_a % u_b;
            default  : return 0;
        endcase
    endfunction

    // --- Stimulus Process ---
    int pass_count = 0;
    int fail_count = 0;
    M_req_t test_queue[$];
    logic [31:0] expected_val;

    initial begin
        // Khởi tạo
        rst = 1;
        valid = 0;
        m_req = '0;
        repeat(5) @(posedge clk);
        rst = 0;
        @(posedge clk);

        $display("======= STARTING RISC-V M-UNIT TESTBENCH (500+ CASES) =======");

        // Chạy 550 cases (50 corner cases + 500 random cases)
        for (int i = 0; i < 550; i++) begin
            wait(!busy); // Đợi module rảnh
            
            @(posedge clk);
            valid = 1;
            
            // Tạo Corner Cases cho 50 vòng đầu, sau đó là Random
            if (i < 8) begin
                m_req.op = m_op_e'(i); // Test mỗi op 1 lần với số thường
                m_req.a_i = $random; m_req.b_i = $random;
            end else if (i < 20) begin
                m_req.op = M_DIV; m_req.b_i = 0; m_req.a_i = $random; // Chia cho 0
            end else if (i < 30) begin
                m_req.op = M_DIV; m_req.a_i = 32'h80000000; m_req.b_i = 32'hFFFFFFFF; // Tràn số
            end else begin
                m_req.a_i = $random;
                m_req.b_i = $random;
                m_req.op = m_op_e'($urandom_range(0, 7));
            end

            expected_val = get_expected(m_req);
            
            // Handshaking
            @(posedge clk);
            while (!ready) @(posedge clk); // Đợi kết quả
            
            // Kiểm tra kết quả
            if (result === expected_val) begin
                pass_count++;
            end else begin
                $display("[ERROR] Op: %p | A: %h | B: %h | Exp: %h | Got: %h", 
                          m_req.op, m_req.a_i, m_req.b_i, expected_val, result);
                fail_count++;
            end

            valid = 0; // Kết thúc chu kỳ
            @(posedge clk);
        end

        $display("=====================================================");
        $display(" TEST COMPLETED");
        $display(" PASSED: %d", pass_count);
        $display(" FAILED: %d", fail_count);
        $display("=====================================================");
        
        if (fail_count == 0) $display(" RESULT: SUCCESS");
        else                $display(" RESULT: FAILURE");
        
        $finish;
    end

endmodule