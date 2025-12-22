module hazard_unit (
   input  logic [5-1:0] rs1_addr, //rs1e
   input  logic [5-1:0] rs2_addr, //rs2e
   input  logic [5-1:0] rdm_addr, //rdm
   input  logic [5-1:0] rdw_addr, //rdw
   input  logic [5-1:0] rdt_addr, //rdt
   input  logic         reg_wr_en_temp_temp, //regwritem
   input  logic         reg_wr_en_temp_temp_temp, //regwritew
//   input  logic         dmem_wr_temp_temp,
   output logic [1:0]   fowardAE,
   output logic [1:0]   fowardBE
);
always_comb begin
   if ((((rs1_addr == rdm_addr) & (reg_wr_en_temp_temp)) & (rdm_addr!=0)) /*| (((rs1_addr == rdt_addr) & (dmem_wr_temp_temp)) & (rdt_addr!=0))*/) begin
      fowardAE = 2'b10;
   end else if (((rs1_addr == rdw_addr) & (reg_wr_en_temp_temp_temp)) & (rdw_addr!=0)) begin
      fowardAE = 2'b01;
   end else if (((rs1_addr == rdt_addr) & (reg_wr_en_temp_temp_temp)) & (rdt_addr!=0)) begin
      fowardAE = 2'b11;
   end else begin
      fowardAE = 2'b00;
   end
end

always_comb begin
   if ((((rs2_addr == rdm_addr) & (reg_wr_en_temp_temp)) & (rdm_addr!=0)) /*| (((rs2_addr == rdt_addr) & (dmem_wr_temp_temp)) & (rdt_addr!=0))*/) begin
      fowardBE = 2'b10;
   end else if (((rs2_addr == rdw_addr) & (reg_wr_en_temp_temp_temp)) & (rdw_addr!=0)) begin
      fowardBE = 2'b01;
   end else if (((rs2_addr == rdt_addr) & (reg_wr_en_temp_temp_temp)) & (rdt_addr!=0)) begin
      fowardBE = 2'b11;
   end else begin
      fowardBE = 2'b00;
   end
end

endmodule
