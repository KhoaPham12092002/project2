module reg_id_ex (
   input  logic         clk_i,
   input  logic         rst_ni,
  
   input  logic         flushE, 
   input  logic [W-1:0] pc_temp,
   input  logic [W-1:0] instr_temp,
   input  logic [1:0]   wb_sel,
   input  logic         reg_wr_en,
   input  logic         dmem_wr,
   input  logic [W-1:0] rs1_data,
   input  logic [W-1:0] rs2_data,
   input  logic [3:0]   alu_op,       
   input  logic         branch_u,
   input  logic         op_a_sel,
   input  logic         op_b_sel,
   input  logic [W-1:0] imm,
   input  logic         PC_sel,

   output logic [W-1:0] pc_temp_temp,
   output logic [W-1:0] instr_temp_temp,
   output logic [1:0]   wb_sel_temp,
   output logic         reg_wr_en_temp,
   output logic         dmem_wr_temp,
   output logic [W-1:0] rs1_data_temp,
   output logic [W-1:0] rs2_data_temp,
   output logic [3:0]   alu_op_temp,
   output logic         branch_u_temp,
   output logic         op_a_sel_temp,
   output logic         op_b_sel_temp,
   output logic [W-1:0] imm_temp,
   output logic         PC_sel_temp   

);
parameter W = 32;
always @(posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      pc_temp_temp    <= 'd0;
      instr_temp_temp <= 'd0;
      wb_sel_temp     <= 'd0;
      reg_wr_en_temp  <= 'd0;
      dmem_wr_temp    <= 'd0;
      rs1_data_temp   <= 'd0;
      rs2_data_temp   <= 'd0;
      alu_op_temp     <= 'd0;
      branch_u_temp   <= 'd0;
      op_a_sel_temp   <= 'd0;
      op_b_sel_temp   <= 'd0;
      imm_temp        <= 'd0;
      PC_sel_temp     <= 'd0;
   end else begin
      if (flushE) begin
         pc_temp_temp    <= 'd0;
         instr_temp_temp <= 'd0;
         wb_sel_temp     <= 'd0;
         reg_wr_en_temp  <= 'd0;
         dmem_wr_temp    <= 'd0;
         rs1_data_temp   <= 'd0;
         rs2_data_temp   <= 'd0;
         alu_op_temp     <= 'd0;
         branch_u_temp   <= 'd0;
         op_a_sel_temp   <= 'd0;
         op_b_sel_temp   <= 'd0;
         imm_temp        <= 'd0;
         PC_sel_temp     <= 'd0;
      end else begin
         pc_temp_temp    <= pc_temp;
         instr_temp_temp <= instr_temp;
         wb_sel_temp     <= wb_sel;
         reg_wr_en_temp  <= reg_wr_en;
         dmem_wr_temp    <= dmem_wr;
         rs1_data_temp   <= rs1_data;
         rs2_data_temp   <= rs2_data;
         alu_op_temp     <= alu_op;
         branch_u_temp   <= branch_u;
         op_a_sel_temp   <= op_a_sel;
         op_b_sel_temp   <= op_b_sel;
         imm_temp        <= imm;
         PC_sel_temp     <= PC_sel;
      end
   end
end
endmodule
