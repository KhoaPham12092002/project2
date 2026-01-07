`timescale 1ns/1ps

module register_file (
    input  logic        clk,
    input  logic        rst,         
    
    // (Write Port) - From Write Back (WB)
    input  logic        w_ena,       
    input  logic [4:0]  w_address,   
    input  logic [31:0] w_data,      

    // (Read Ports) - Output data immediately to Execute (EX)
    input  logic [4:0]  r1_address,  
    output logic [31:0] r1_data,     
    
    input  logic [4:0]  r2_address,  
    output logic [31:0] r2_data      
);

    // --- (32 register 32-bit) ---
    logic [31:0] rf [31:0];
    //x0 always = 0.
    logic w_ena_prot;
    assign w_ena_prot = (w_address == 5'd0) ? 1'b0 : w_ena;

    // (Synchronous Write) ghi dữ liệu (xung clock cạnh lên)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // reset
            for (int i = 0; i < 32; i++) begin
                rf[i] <= 32'h0;
            end
        end else if (w_ena_prot) begin
            rf[w_address] <= w_data;
        end
    end

    // (Asynchronous Read) đọc dữ liệu
    // đọc không đợi clock.
    assign r1_data = (r1_address == 5'd0) ? 32'h0 : rf[r1_address];
    assign r2_data = (r2_address == 5'd0) ? 32'h0 : rf[r2_address];
 // hoạt động như một bộ nhớ 3 cổng (1W/2R
endmodule