module imem (
  /* verilator lint_off UNUSED */
   input  logic              clk_i,
   input  logic              rst_ni,
   input  logic [IMEM_W-1:0] address,

   output logic [W-1:0]      data
);
parameter IMEM_W = 14;
parameter W = 32;
logic [3:0][7:0] mem [2**(IMEM_W-2)-1:0];
initial begin
   $readmemh("./mem/instmem.data.sim", mem);
end
always@(*) begin
   data = mem[address[IMEM_W-1:2]][3:0];
end
endmodule
