module compare_1bit (
   input  logic a,
   input  logic b,

   output logic eq,
   output logic lt,
   output logic gt
);
assign eq = a~^b;
assign gt = a&(~b);
assign lt = (~a)&b;
endmodule
