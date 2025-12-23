// cách dùng  input  logic [31:0] a, b,
//    input  logic        carry_in, add_sub = 1 là trừ = 0 là cộng
//    output logic [31:0] sum_dif,
//    output logic        C, V // Carry và Overflow
// --- 1-bit Full Adder with P & G Generation ---
module full_adder_1_bit (
    input  logic a, b, cin, add_sub,
    output logic sum_dif, p, g
);
    logic b_inv;
    assign b_inv = b ^ add_sub; // Nếu add_sub = 1, thực hiện phép trừ (2's complement)
    
    assign g = a & b_inv;
    assign p = a ^ b_inv;
    assign sum_dif = p ^ cin;
endmodule

// --- 4-bit Carry Look-ahead Block ---
module carry_block_4bits (
    input  logic       carry_in,
    input  logic [3:0] p, g,
    output logic [3:0] cin_out,
    output logic       cout, P_out, G_out
);
    assign cin_out[0] = carry_in;
    assign cin_out[1] = g[0] | (p[0] & cin_out[0]);
    assign cin_out[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & cin_out[0]);
    assign cin_out[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & cin_out[0]);
    
    assign G_out = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);
    assign P_out = &p; // p[0] & p[1] & p[2] & p[3]
    assign cout  = G_out | (P_out & carry_in);
endmodule

// --- 32-bit CLA Adder/Subtractor ---
module i_adder (
    input  logic [31:0] a, b,
    input  logic        carry_in, add_sub,
    output logic [31:0] sum_dif,
    output logic        C, V // Carry và Overflow
); // adder_sub32bit
    logic [31:0] p, g, cin;
    logic [7:0]  P_blk, G_blk, C_blk;

    // Tạo 32 bộ FA 1-bit
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_fa
            full_adder_1_bit fa_inst (
                .a(a[i]), .b(b[i]), .cin(cin[i]), .add_sub(add_sub),
                .sum_dif(sum_dif[i]), .p(p[i]), .g(g[i])
            );
        end
    endgenerate

    // Kết nối các khối Carry Look-ahead 4-bit
    genvar j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : gen_cla
            carry_block_4bits cla_inst (
                .carry_in( (j == 0) ? carry_in : C_blk[j-1] ),
                .p(p[j*4+3 : j*4]), 
                .g(g[j*4+3 : j*4]),
                .cin_out(cin[j*4+3 : j*4]),
                .cout(C_blk[j]),
                .P_out(P_blk[j]),
                .G_out(G_blk[j])
            );
        end
    endgenerate

    assign C = C_blk[7];
    // Overflow detection cho số có dấu (Signed Overflow)
    // V = (C_in_last ^ C_out_last)
    assign V = C_blk[7] ^ C_blk[6]; 

endmodule