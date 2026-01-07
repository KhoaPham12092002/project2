`timescale 1ns/1ps

module hazard_unit (
    input  logic       clk,
    input  logic       rst,

    // --- Data Hazard Inputs ---
    input  logic [4:0] rs1_e, rs2_e,
    input  logic [4:0] rd_m,  rd_w,
    input  logic       reg_write_m, reg_write_w,

    // --- Load-Use Hazard Inputs ---
    input  logic [4:0] rs1_d, rs2_d,
    input  logic [4:0] rd_e,
    input  logic       is_load_e, 
    
    // --- M-Unit Hazard Inputs ---
    input  logic       stall_m_req, // [NEW] Yêu cầu dừng từ bộ Nhân/Chia

    // --- Control Hazard Inputs ---
    input  logic       pc_src_e,

    // --- Memory Handshake Inputs ---
    input  logic       mem_req_m,  
    input  logic       mem_done_m, 

    // --- Outputs ---
    output logic [1:0] forward_a_e, forward_b_e,
    output logic       stall_f, stall_d, stall_e, stall_m, stall_w,
    output logic       flush_d, flush_e
);

    // ========================================================================
    // 1. DATA FORWARDING
    // ========================================================================
    always_comb begin
        // Forward A
        if ((rs1_e == rd_m) && reg_write_m && (rs1_e != 0)) forward_a_e = 2'b10;
        else if ((rs1_e == rd_w) && reg_write_w && (rs1_e != 0)) forward_a_e = 2'b01;
        else forward_a_e = 2'b00;

        // Forward B
        if ((rs2_e == rd_m) && reg_write_m && (rs2_e != 0)) forward_b_e = 2'b10;
        else if ((rs2_e == rd_w) && reg_write_w && (rs2_e != 0)) forward_b_e = 2'b01;
        else forward_b_e = 2'b00;
    end

    // ========================================================================
    // 2. STALL LOGIC (GỘP LẠI THÀNH 1 KHỐI DUY NHẤT)
    // ========================================================================
    
    // a. Memory Stall: Đợi bộ nhớ (Cache miss/SDRAM latency)
    logic mem_stall;
    assign mem_stall = mem_req_m & ~mem_done_m;

    // b. Load-Use Hazard Stall
    logic lw_stall;
    assign lw_stall = is_load_e & ((rs1_d == rd_e) || (rs2_d == rd_e));

    // c. Tổng hợp Stall
    // [FIX] Chỉ dùng 1 khối always_comb duy nhất ở đây
    always_comb begin
        // ---------------------------------------------------------
        // Priority: Mem Stall > M-Unit Stall > Load-Use Stall
        // ---------------------------------------------------------
        
        // 1. Stall Fetch & Decode (Dừng nạp lệnh mới)
        // Bị dừng khi: Memory bận OR M-Unit bận OR Load-Use Hazard
        stall_f = mem_stall | stall_m_req | lw_stall;
        stall_d = mem_stall | stall_m_req | lw_stall;

        // 2. Stall Execute (Dừng tính toán)
        // Bị dừng khi: Memory bận OR M-Unit bận (chính nó đang tính)
        // Lưu ý: Load-Use thì KHÔNG stall E (để E chạy xong bong bóng NOP)
        stall_e = mem_stall | stall_m_req; 

        // 3. Stall Memory & Writeback ("Freeze All" Strategy)
        // Khi M-Unit chạy lâu, ta chọn cách dừng cả MEM/WB lại để giữ trạng thái.
        // Điều này giúp đơn giản hóa logic (không cần chèn Bubble phức tạp).
        stall_m = mem_stall | stall_m_req; 
        stall_w = mem_stall | stall_m_req; 

        // ---------------------------------------------------------
        // Flush Logic (Xóa lệnh)
        // ---------------------------------------------------------
        
        // Flush Decode: Khi nhảy nhánh (Branch Taken)
        // Nếu đang stall do Mem/M-Unit thì KHÔNG được flush (ưu tiên giữ trạng thái)
        flush_d = pc_src_e & ~stall_d;

        // Flush Execute: Khi Load-Use Hazard hoặc Branch Taken
        // Để biến lệnh đang ở ID/EX thành NOP
        flush_e = (lw_stall || pc_src_e) & ~stall_e;
    end

endmodule