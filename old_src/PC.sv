module PC (
   input  logic         clk_i,
   input  logic         rst_ni,
   input  logic         sel,
   input  logic [W-1:0] pc_imm,
   input  logic         hazard,

   output logic [W-1:0] pc_out   
);
parameter W = 32;
logic [31:0] pc_nxt;
logic [31:0] pc_four;
logic [31:0] pc;

assign pc_four = pc + 32'd4;
assign pc_nxt  = (sel)? pc_imm : pc_four;

always @(posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      pc_out <= 32'd0;
      pc     <= 32'd0;
   end else begin
      if (!hazard) begin
         pc     <= pc_nxt;
         pc_out <= pc_nxt;
      end else begin
         pc     <= pc;
	 pc_out <= pc_out;
      end
   end
end
endmodule
