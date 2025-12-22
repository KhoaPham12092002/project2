module reg_ex_mem (
   input  logic         clk_i,
   input  logic         rst_ni,

   input  logic [W-1:0] pc_temp_temp,
   input  logic [W-1:0] instr_temp_temp,
   input  logic [1:0]   wb_sel_temp,
   input  logic         reg_wr_en_temp,
   input  logic         dmem_wr_temp,
   input  logic [W-1:0] alu_data,
   input  logic [W-1:0] rs2_data_temp,

   output logic [W-1:0] pc_temp_temp_temp,
   output logic [W-1:0] instr_temp_temp_temp,
   output logic [1:0]   wb_sel_temp_temp,
   output logic         reg_wr_en_temp_temp,
   output logic         dmem_wr_temp_temp,
   output logic [W-1:0] alu_data_temp,
   output logic [W-1:0] rs2_data_temp_temp
);
parameter W = 32;
always @(posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      pc_temp_temp_temp    <= 'd0;
      instr_temp_temp_temp <= 'd0;
      wb_sel_temp_temp     <= 'd0;
      reg_wr_en_temp_temp  <= 'd0;
      dmem_wr_temp_temp    <= 'd0;
      alu_data_temp        <= 'd0;
      rs2_data_temp_temp   <= 'd0;
   end else begin
      pc_temp_temp_temp    <= pc_temp_temp+4;
      instr_temp_temp_temp <= instr_temp_temp;
      wb_sel_temp_temp     <= wb_sel_temp;
      reg_wr_en_temp_temp  <= reg_wr_en_temp;
      dmem_wr_temp_temp    <= dmem_wr_temp;
      alu_data_temp        <= alu_data;
      rs2_data_temp_temp   <= rs2_data_temp;
   end
end
endmodule
