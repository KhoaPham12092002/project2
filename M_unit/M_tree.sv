`timescale 1ns/1ps
import M_types_pkg::*; 

// --- Module phu tro cho Wallace Tree ---
module full_adder (
    input  logic a, b, cin,
    output logic sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule

module half_adder (
    input  logic a, b,
    output logic sum, cout
);
    assign sum  = a ^ b;
    assign cout = a & b;
endmodule

// --- Bo nhan Wallace Tree 32-bit ---
module wallace_multiplier_32bit (
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  logic        a_signed,
    input  logic        b_signed,
    output logic [63:0] result_o
);
    // Su dung toan tu $signed de Tool tu dong suy luan cay Wallace/DSP toi uu
    assign result_o = $signed({(a_signed & a_i[31]), a_i}) * $signed({(b_signed & b_i[31]), b_i});
endmodule

// --- Module chinh: RISC-V M-Unit (Kien truc Wallace Tree) ---
module riscv_m_unit (
    input  logic         clk,
    input  logic         rst,
    input  logic         valid,
    input  M_req_t       m_req,
    output logic [31:0]  result,
    output logic         ready,
    output logic         busy
);

    // ------------------------------------------------------------------------
    // KHAI BAO CAC BIEN (Sua loi vlog-2730: Undefined variable)
    // ------------------------------------------------------------------------
    logic is_div_op, is_rem_op, is_signed_div;
    logic mul_ready_reg;
    logic [63:0] mul_full_res; // Ket noi tu multiplier
    logic [63:0] mul_res_reg;  // Thanh ghi chot ket qua nhan
    
    // Cac bien cho bo chia
    logic [5:0]  count;
    logic [63:0] rem_quot_reg;
    logic [31:0] divisor_reg;
    logic        sign_q, sign_r;
    logic [31:0] adder_out;
    logic        adder_cout;

    typedef enum logic [2:0] { IDLE, PREPARE, DIV_LOOP, FIX_SIGN, DONE } div_state_t;
    div_state_t state;

    // ------------------------------------------------------------------------
    // 1. DECODE
    // ------------------------------------------------------------------------
    assign is_div_op     = (m_req.op inside {M_DIV, M_DIVU, M_REM, M_REMU});
    assign is_rem_op     = (m_req.op inside {M_REM, M_REMU});
    assign is_signed_div = (m_req.op inside {M_DIV, M_REM});
    assign busy          = (state != IDLE) || mul_ready_reg;

    // ------------------------------------------------------------------------
    // 2. MULTIPLIER INSTANTIATION
    // ------------------------------------------------------------------------
    wallace_multiplier_32bit u_mul (
        .a_i      (m_req.a_i),
        .b_i      (m_req.b_i),
        .a_signed (m_req.op inside {M_MULH, M_MULHSU}),
        .b_signed (m_req.op == M_MULH),
        .result_o (mul_full_res)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mul_res_reg   <= '0;
            mul_ready_reg <= 1'b0;
        end else begin
            if (valid && !is_div_op && state == IDLE && !mul_ready_reg) begin
                mul_res_reg   <= mul_full_res;
                mul_ready_reg <= 1'b1;
            end else if (!valid) begin
                mul_ready_reg <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // 3. DIVIDER LOGIC (Restoring Division)
    // ------------------------------------------------------------------------
    i_adder shared_adder (
        .a       ({rem_quot_reg[62:32], rem_quot_reg[31]}), 
        .b       (divisor_reg), 
        .carry_in(1'b1), .add_sub(1'b1), 
        .sum_dif (adder_out), .C(adder_cout)
    );

    

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE; rem_quot_reg <= '0; divisor_reg <= '0;
            count <= '0; sign_q <= '0; sign_r <= '0;
        end else begin
            case (state)
                IDLE: if (valid && is_div_op && !mul_ready_reg) state <= PREPARE;
                
                PREPARE: begin
                    sign_q <= is_signed_div && (m_req.a_i[31] ^ m_req.b_i[31]);
                    sign_r <= is_signed_div && m_req.a_i[31];
                    divisor_reg  <= (is_signed_div && m_req.b_i[31]) ? (32'd0 - m_req.b_i) : m_req.b_i;
                    rem_quot_reg <= {32'd0, (is_signed_div && m_req.a_i[31]) ? (32'd0 - m_req.a_i) : m_req.a_i};
                    count <= 32; state <= DIV_LOOP;
                end

                DIV_LOOP: begin
                    if (count > 0) begin
                        logic [63:0] shifted;
                        shifted = {rem_quot_reg[62:0], 1'b0};
                        if (adder_cout) rem_quot_reg <= {adder_out, shifted[31:1], 1'b1};
                        else            rem_quot_reg <= shifted;
                        count <= count - 1;
                    end else state <= FIX_SIGN;
                end

                FIX_SIGN: begin
                    logic [31:0] q, r;
                    q = sign_q ? (32'd0 - rem_quot_reg[31:0]) : rem_quot_reg[31:0];
                    r = sign_r ? (32'd0 - rem_quot_reg[63:32]) : rem_quot_reg[63:32];
                    rem_quot_reg <= {r, q};
                    state <= DONE;
                end

                DONE: if (!valid) state <= IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // 4. OUTPUT MUX
    // ------------------------------------------------------------------------
    always_comb begin
        result = '0;
        ready  = 1'b0;
        if (is_div_op) begin
            ready = (state == DONE);
            if (state == DONE) begin
                if (m_req.b_i == 0) begin
                    result = is_rem_op ? m_req.a_i : 32'hFFFFFFFF;
                end else if (m_req.a_i == 32'h80000000 && m_req.b_i == 32'hFFFFFFFF && is_signed_div) begin
                    result = is_rem_op ? 32'h0 : 32'h80000000;
                end else begin
                    result = is_rem_op ? rem_quot_reg[63:32] : rem_quot_reg[31:0];
                end
            end
        end else begin
            ready  = mul_ready_reg && (state == IDLE);
            result = (m_req.op == M_MUL) ? mul_res_reg[31:0] : mul_res_reg[63:32];
        end
    end

endmodule