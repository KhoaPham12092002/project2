module branch_compare (
   input  logic [W-1:0] data_in_a,
   input  logic [W-1:0] data_in_b,
   input  logic         branch_unsigned,

   output logic         equal,
   output logic         lessthan

);
parameter W = 32;
logic equal_u;
logic equal_s;
logic lessthan_u;
logic lessthan_s;
/* verilator lint_off PINCONNECTEMPTY */
compare_32bit compare_0 (.a(data_in_a), 
			 .b(data_in_b),
			 .eq(equal_u),
			 .lt(lessthan_u),
			 .gt()
			);
compare_32bit_s compare_1 (.a(data_in_a),
                         .b(data_in_b),
                         .eq(equal_s),
                         .lt(lessthan_s),
                         .gt()
                        );
assign equal    = (branch_unsigned) ? equal_u:equal_s;
assign lessthan = (branch_unsigned) ? lessthan_u:lessthan_s;
endmodule
