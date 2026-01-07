`timescale 1ns/1ps
import memory_pkg::*; // Import gói cấu hình

module address_decoder (
    input  logic [31:0] address,
    
    // Output giải mã (Thay thế cho logic cứng nhắc cũ)
    output dev_sel_t    dev_sel,    // Tín hiệu chọn thiết bị (Enum)
    output logic [1:0]  dcsel_raw   // Tín hiệu 2-bit thô (cho tương thích legacy code)
);

    // Sử dụng hàm từ Package để giải mã
    always_comb begin
        dev_sel = decode_address(address);
    end

    // Chuyển đổi Enum về 2-bit vector (nếu module cũ cần)
    assign dcsel_raw = dev_sel; 

endmodule