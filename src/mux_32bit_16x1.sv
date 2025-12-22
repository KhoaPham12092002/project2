module mux_32bit_16x1 (
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,
   input  logic [W-1:0] c,
   input  logic [W-1:0] d,
   input  logic [W-1:0] e,
   input  logic [W-1:0] f,
   input  logic [W-1:0] g,
   input  logic [W-1:0] h,
   input  logic [W-1:0] j,
   input  logic [W-1:0] k,
   input  logic [W-1:0] l,
   input  logic [W-1:0] m,
   input  logic [W-1:0] n,
   input  logic [W-1:0] q,
   input  logic [W-1:0] r,
   input  logic [W-1:0] s,
   input  logic [3:0]   sel,

   output logic [W-1:0] out
);
parameter W = 32;
always @(*) begin
   case (sel)
      4'b0000:  out = a;
      4'b0001:  out = b;
      4'b0010:  out = c;
      4'b0011:  out = d;
      4'b0100:  out = e;
      4'b0101:  out = f;
      4'b0110:  out = g;
      4'b0111:  out = h;
      4'b1000:  out = j;
      4'b1001:  out = k;
      4'b1010:  out = l;
      4'b1011:  out = m;
      4'b1100:  out = n;
      4'b1101:  out = q;
      4'b1110:  out = r;
      4'b1111:  out = s;
   endcase
end
endmodule
