module reg_32 (
   input  logic [W-1:0] data_d,
   input  logic [nu_reg-1:0] addr_a,
   input  logic [nu_reg-1:0] addr_b,
   input  logic [nu_reg-1:0] addr_d,
   input  logic clk_i,
   input  logic rst_ni,
   input  logic wr_en_d,

   output logic [W-1:0] data_a,
   output logic [W-1:0] data_b
);
parameter W = 32;
parameter nu_reg = 5;
logic [W-1:0] mem [2**nu_reg-1:0];

always @(posedge clk_i, negedge rst_ni) begin
   if(!rst_ni) begin
      for (int i = 0; i <32; i++) begin
         mem[i] <= 'd0;
      end
   end else begin
      if ((wr_en_d == 1) && (addr_d != 0)) begin
         mem[addr_d] <= data_d;
      end else begin
         mem[addr_d] <= mem[addr_d];
      end      
   end
end
assign data_a = mem[addr_a];
assign data_b = mem[addr_b];
endmodule
