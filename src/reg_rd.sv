module reg_rd (
   input  logic         clk_i,
   input  logic         rst_ni,

   input  logic [W-1:0] instr_temp_temp_temp_temp,
   input  logic [W-1:0] wb_data,

   output logic [W-1:0] wb_data_temp,
   output logic [W-1:0] instr_temp_temp_temp_temp_temp
);
parameter W = 32;
always @(posedge clk_i, negedge rst_ni) begin
   if (!rst_ni) begin
      wb_data_temp                   <= 'd0;
      instr_temp_temp_temp_temp_temp <= 'd0;
   end else begin
      wb_data_temp                   <= wb_data;
      instr_temp_temp_temp_temp_temp <= instr_temp_temp_temp_temp;
   end
end
endmodule
