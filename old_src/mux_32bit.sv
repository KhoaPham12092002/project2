module mux_32bit(
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,
   input  logic         sel,

   output logic [W-1:0] out
);
parameter W = 32;
assign out = (sel) ? b : a;
endmodule
