package alu_types_pkg;

    // Định nghĩa cấu trúc dữ liệu cho ALU 
    typedef struct packed {
        logic signed [31:0] a;      // Toán hạng A
        logic signed [31:0] b;      // Toán hạng B
        logic [3:0]         code;   // Mã lệnh ALU
    } alu_data_t;

    // --- ALU Operation Codes
    typedef enum logic [3:0] {
        ALU_ADD  = 4'b0000,
        ALU_SUB  = 4'b0001,
        ALU_SLL  = 4'b0010,
        ALU_SRL  = 4'b0011,
        ALU_SRA  = 4'b0100,
        ALU_SLT  = 4'b0101,
        ALU_SLTU = 4'b0111,
        ALU_XOR  = 4'b1000,
        ALU_OR   = 4'b1001,
        ALU_AND  = 4'b1010
    } alu_op_e;

    // --- Các hằng số bổ trợ khác từ file  ---
    // Mux chọn nguồn cho ALU
    typedef enum logic [1:0] {
        MUX_ULA_R      = 2'b00, // Lệnh R-type
        MUX_ULA_I      = 2'b01, // Lệnh I-type
        MUX_ULA_Shift  = 2'b10, // Các lệnh dịch
        MUX_ULA_BRANCH = 2'b11  // Tính toán địa chỉ nhảy
    } alu_mux_sel_e;

    // Mux chọn dữ liệu ghi lại Register File
    localparam logic MUX_BR_ULA = 1'b0;
    localparam logic MUX_BR_RAM = 1'b1;

    // Địa chỉ I/O Registers (Dùng localparam cho hằng số cố định)
    localparam logic [7:0] LED_IO_REG  = 8'h80; // 10000000
    localparam logic [7:0] SW_IO_REG   = 8'h81; // 10000001
    localparam logic [7:0] SEG7_IO_REG = 8'h82; // 10000010

endpackage