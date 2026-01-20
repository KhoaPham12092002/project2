module imem #(
    parameter string HEX_FILE = "test.hex", // Tên file hex mặc định
    parameter int    MEM_SIZE = 4096           // Kích thước 4KB (1024 lệnh)
) (
    input  logic        clk_i,    // Clock 
    input  logic        rst_i,   // Reset 

    // Input từ PC (Fetch Stage)
    input  logic [31:0] addr_i,   
    
    // Output ra Decoder (Decode Stage)
    output logic [31:0] instr_o   
);
    
    localparam int WORD_COUNT = MEM_SIZE / 4;
// Array intrucstion    
    logic [31:0] mem_array [0 : WORD_COUNT-1];
// Array addr PC+4
    logic [31:0] word_addr;
    assign word_addr = {2'b0, addr_i[31:2]}; // Làm tròn xuống word gần nhất
//ASYNCHRONOUS READ
    always_comb begin
        if (word_addr < WORD_COUNT) begin
            instr_o = mem_array[word_addr];
        end else begin
            instr_o = 32'h0000_0000; // NOP 
        end
    end

    //BACKDOOR LOAD (FOR SIMULATION)
     initial begin
        // Reset array
        for (int i = 0; i < WORD_COUNT; i++) begin
            mem_array[i] = 32'b0;
        end

        // load file Hex
        $display("Loading IMEM from %s...", HEX_FILE);
        $readmemh(HEX_FILE, mem_array);
    end

endmodule