import memory_pkg::*;
module imem #(
	parameter string	HEX_FILE = "program.hex", // Tên file hex mặc định
	parameter int MEM_SIZE		=	memory_pkg::IMEM_SIZE_BYTES,
	parameter int DATA_WIDTH	=	memory_pkg::XLEN,
)(
    input  logic        clk_i,    // Clock 
    input  logic        rst_i,   // Reset 

    
    // Input từ PC (Fetch Stage)
    input  logic [31:0] addr_i,   
    // --- Handshake Interface ---
    input  logic        req_i,      // (Valid Address)
    // Output ra Decoder (Decode Stage)
    output logic        gnt_o,      // (Ready to accept)
    output logic        rvalid_o,   // (Valid Data)
    output logic [DATA_WIDTH-1:0] instr_o   
);
    
    localparam int WORD_COUNT = MEM_SIZE / 4;
// Array intrucstion    
    logic [31:0] mem_array [0 : WORD_COUNT-1];
// Array addr PC+4
    logic [31:0] word_addr;
    assign word_addr = {2'b0, addr_i[31:2]}; // Làm tròn xuống word gần nhất
//SYNCHRONOUS READ
    always_ff@(posedge clk_i) begin
        // Reset logic 
	if (rst_i) begin
		rvalid_o < 1'b0;
		instr_o <= 32'h0000_0000; // NOP
	end else begin
		if (reg_i && gnt_o) begin
			if (word_addr < WORD_COUNT)
				instr_o <= mem_array[word_addr];
			else begin 
				instr_o <= 32'h0000_0000;
				rvalid <=1'b1;
			end else rvalid <= 1'b0;
		end
	end
end

    //BACKDOOR LOAD (FOR SIMULATION)
     initial begin
        // Reset array
        for (int i = 0; i < WORD_COUNT; i++) begin
            mem_array[i] = 32'b0;
        end

        // load file Hex
        $display("Loading IMEM from %s (Size : %0d bytes)", HEX_FILE, MEM_SIZE);
        $readmemh(HEX_FILE, mem_array);
    endrvalid <= 1'b0;

endmodule
