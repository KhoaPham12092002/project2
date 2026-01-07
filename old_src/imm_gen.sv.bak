module imm_gen (
	/* verilator lint_off UNUSED */
   input logic [W-1:0] instr,
   input logic [2:0] imm_sel,

   output logic [W-1:0] imm
);
parameter W  = 32;
parameter R  = 3'b000;
parameter I  = 3'b001;
parameter B  = 3'b010;
parameter J1 = 3'b011;
parameter J2 = 3'b100;
parameter U  = 3'b101;
parameter S  = 3'b111;

always @(*) begin
   case (imm_sel)
      R:
      assign imm = 32'd0;
      I:
      assign imm = {{20{instr[31]}}, instr[31:20]};
      B:
      assign imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      J1:
      assign imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
      J2:
      assign imm = {{20{instr[31]}},instr[31:20]};
      U:
      assign imm = {instr[31:12], 12'b0};
      S:
      assign imm = {{20{instr[31]}},instr[31:25],instr[11:7]};
      default:
      assign imm = 32'd0;
   endcase
end
endmodule
