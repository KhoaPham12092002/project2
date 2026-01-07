module compare_32bit_s (
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,

   output logic         eq,
   output logic         gt,
   output logic         lt
);
parameter W = 32;
logic eq_temp;
logic gt_temp;
logic lt_temp;
logic eq_temp_2c;
logic gt_temp_2c;
logic lt_temp_2c;
logic [W-1:0] a_2c;
logic [W-1:0] b_2c;

assign a_2c = ~a + 1;
assign b_2c = ~b + 1;

always @(*) begin
   if (a[W-1] == 0 && b[W-1] == 0) begin
      assign eq = eq_temp;
      assign gt = gt_temp;
      assign lt = lt_temp;
   end else if (a[W-1] == 1 && b[W-1] == 1) begin
      assign eq = eq_temp_2c;
      assign gt = ~gt_temp_2c;
      assign lt = ~lt_temp_2c;
   end else if (a[W-1] == 0 && b[W-1] == 1) begin
      assign eq = 0;
      assign gt = 1;
      assign lt = 0;
   end else begin
      assign eq = 0;
      assign gt = 0;
      assign lt = 1;
   end      
end

compare_32bit compare_0 (.a(a), .b(b), .eq(eq_temp), .gt(gt_temp), .lt(lt_temp));
compare_32bit compare_1 (.a(a_2c), .b(b_2c), .eq(eq_temp_2c), .gt(gt_temp_2c), .lt(lt_temp_2c));
endmodule
