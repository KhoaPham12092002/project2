module mux_32bit_4x1 (
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,
   input  logic [W-1:0] c,
   input  logic [W-1:0] d,
   input  logic [1:0]   sel,

   output logic [W-1:0] out
);
parameter W = 32;
always @(*) begin
   case (sel)
      2'b00: assign out = a;
      2'b01: assign out = b;
      2'b10: assign out = c;
      2'b11: assign out = d;
   endcase
end
endmodule
