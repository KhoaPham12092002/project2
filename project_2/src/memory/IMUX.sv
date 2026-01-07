`timescale 1ns/1ps

module instructionbusmux #(
    parameter IADDRESS_BUS_SIZE = 16,
    parameter DADDRESS_BUS_SIZE = 32
)(
    // Tín hiệu điều khiển
    input  logic        d_rd,      // Tín hiệu yêu cầu đọc dữ liệu từ Data Bus
    input  logic [1:0]  dcsel,     // Tín hiệu chọn vùng nhớ (00 ứng với vùng IMem)
    
    // Luồng địa chỉ vào
    input  logic [DADDRESS_BUS_SIZE-1:0] daddress, // Địa chỉ từ luồng Dữ liệu (cho Load/Interrupt)
    input  logic [IADDRESS_BUS_SIZE-1:0] iaddress, // Địa chỉ từ luồng Lệnh (từ PC)
    
    // Địa chỉ ra nối vào chân Address của RAM
    output logic [9:0]  address    
);

    // Mạch chọn địa chỉ (Multiplexer)
    // Ưu tiên đọc dữ liệu (Data) trước để phục vụ các lệnh Load hoặc truy xuất bảng ngắt
    always_comb begin
        if ((d_rd == 1'b1) && (dcsel == 2'b00)) begin
            // Nếu có tín hiệu đọc và chọn đúng vùng IMem, lấy địa chỉ từ Data Bus
            address = daddress[9:0];
        end
        else begin
            // Trường hợp mặc định: Lấy địa chỉ từ Instruction Bus (PC) để nạp lệnh
            address = iaddress[9:0];
        end
    end

endmodule