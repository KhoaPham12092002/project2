`timescale 1ns/1ps
import M_types_pkg::*; 

module riscv_m_unit (
    input  logic         clk,
    input  logic         rst,
    input  logic         valid,
    input  M_req_t       m_req,
    output logic [31:0]  result,
    output logic         ready,
    output logic         busy    
);

    // --- DECODE ---
    logic is_div_op, is_rem_op, is_signed_op;
    assign is_div_op    = (m_req.op inside {M_DIV, M_DIVU, M_REM, M_REMU});
    assign is_rem_op    = (m_req.op inside {M_REM, M_REMU});
    assign is_signed_op = (m_req.op inside {M_MULH, M_MULHSU, M_DIV, M_REM});

    typedef enum logic [2:0] { IDLE, PREPARE, CALC_LOOP, FIX_SIGN, DONE } state_t;
    state_t state;
    assign busy = (state != IDLE);

    logic [5:0]  count;
    logic [63:0] reg_p;    
    logic [31:0] reg_b;    
    logic        sign_q, sign_r;

    // --- Shared Adder Logic ---
    logic [32:0] adder_in_a, adder_in_b, adder_out;
    
    // FIX: Adder_in_a phải linh hoạt theo từng trạng thái
    always_comb begin
        if (is_div_op) begin
            // Lấy reg_p đã dịch trái 1 bit để thử trừ
            adder_in_a = {1'b0, reg_p[62:32], reg_p[31]}; 
        end else begin
            // Nhân: Lấy nửa cao hiện tại để cộng
            adder_in_a = {1'b0, reg_p[63:32]};
        end
        adder_in_b = {1'b0, reg_b};
    end
    
    // Thuật toán chia dùng Trừ, Nhân dùng Cộng
    assign adder_out = is_div_op ? (adder_in_a - adder_in_b) : (adder_in_a + adder_in_b);

    // --- FSM ---
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; reg_p <= '0; reg_b <= '0; count <= '0;
        end else begin
            case (state)
                IDLE: begin
                    if (valid) begin
                        state <= PREPARE;
                        if (is_div_op) begin
                            sign_q <= is_signed_op ? (m_req.a_i[31] ^ m_req.b_i[31]) : 1'b0;
                            sign_r <= is_signed_op ? m_req.a_i[31] : 1'b0;
                        end else begin
                            sign_q <= (m_req.op == M_MULHSU) ? m_req.a_i[31] : 
                                      (is_signed_op ? (m_req.a_i[31] ^ m_req.b_i[31]) : 1'b0);
                        end
                    end
                end

                PREPARE: begin
                    if (is_div_op && (m_req.b_i == 0 || (m_req.a_i == 32'h80000000 && m_req.b_i == 32'hFFFFFFFF))) begin
                        state <= DONE;
                        reg_p <= (m_req.b_i == 0) ? {m_req.a_i, 32'hFFFFFFFF} : {32'd0, 32'h80000000};
                    end else begin
                        // Lấy trị tuyệt đối an toàn
                        reg_p <= {32'd0, (is_signed_op && m_req.a_i[31]) ? (32'd0 - m_req.a_i) : m_req.a_i};
                        reg_b <= (m_req.op != M_MULHSU && is_signed_op && m_req.b_i[31]) ? (32'd0 - m_req.b_i) : m_req.b_i;
                        count <= 32;
                        state <= CALC_LOOP;
                    end
                end

                CALC_LOOP: begin
                    if (count > 0) begin
                        if (is_div_op) begin
                            // FIX: Thuật toán Chia Restoring
                            if (adder_out[32]) // Không trừ được
                                reg_p <= {reg_p[62:0], 1'b0};
                            else // Trừ được
                                reg_p <= {adder_out[31:0], reg_p[30:0], 1'b1};
                        end else begin
                            // FIX: Thuật toán Nhân (Tránh Double Shift)
                            logic [32:0] next_val;
                            next_val = reg_p[0] ? adder_out : {1'b0, reg_p[63:32]};
                            reg_p <= {next_val, reg_p[31:1]};
                        end
                        count <= count - 1;
                    end else state <= FIX_SIGN;
                end

                FIX_SIGN: begin
                    if (is_div_op) begin
                        if (sign_q) reg_p[31:0]  <= (32'd0 - reg_p[31:0]);
                        if (sign_r) reg_p[63:32] <= (32'd0 - reg_p[63:32]);
                    end else begin
                        if (sign_q) reg_p <= (64'd0 - reg_p);
                    end
                    state <= DONE;
                end

                DONE: if (!valid) state <= IDLE;
            endcase
        end
    end

    // --- Output ---
    always_comb begin
        ready = (state == DONE);
        if (is_div_op) result = is_rem_op ? reg_p[63:32] : reg_p[31:0];
        else           result = (m_req.op == M_MUL) ? reg_p[31:0] : reg_p[63:32];
    end

endmodule