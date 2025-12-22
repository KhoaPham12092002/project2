module hazard_detect(
    input  logic [4:0] IF_IDrs1_i,
    input  logic [4:0] IF_IDrs2_i,
    input  logic [4:0] ID_EXrd_i,
    input  logic       ID_EX_MemRead_i,

    output logic       hazard
);
   assign hazard = (ID_EX_MemRead_i && ((ID_EXrd_i == IF_IDrs1_i) || (ID_EXrd_i == IF_IDrs2_i)))? 1'b1 : 1'b0;
endmodule
