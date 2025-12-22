module compare_32bit (
   input  logic [W-1:0] a,
   input  logic [W-1:0] b,

   output logic         eq,
   output logic         gt,
   output logic         lt
);
parameter W = 32;
/* verilator lint_off UNUSED */
logic [W-1:0] eq_temp;
logic [W-1:0] gt_temp;
logic [W-1:0] lt_temp;
/* verilator lint_off UNUSED */
assign eq = eq_temp[0] &
            eq_temp[1] &
            eq_temp[2] &
            eq_temp[3] &
            eq_temp[4] &
            eq_temp[5] &
            eq_temp[6] &
            eq_temp[7] &
            eq_temp[8] &
            eq_temp[9] &
            eq_temp[10]&
            eq_temp[11]&
	    eq_temp[12]&
	    eq_temp[13]&
	    eq_temp[14]&
	    eq_temp[15]&
	    eq_temp[16]&
	    eq_temp[17]&
	    eq_temp[18]&
	    eq_temp[19]&
	    eq_temp[20]&
	    eq_temp[21]&
	    eq_temp[22]&
	    eq_temp[23]&
	    eq_temp[24]&
	    eq_temp[25]&
	    eq_temp[26]&
	    eq_temp[27]&
	    eq_temp[28]&
	    eq_temp[29]&
	    eq_temp[30]&
	    eq_temp[31];    
assign gt = gt_temp[31]| 
            (eq_temp[31]&gt_temp[30])|
	    (eq_temp[31]&eq_temp[30]&gt_temp[29])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&gt_temp[28])| 
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&gt_temp[27])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&gt_temp[26])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&gt_temp[25])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&gt_temp[24])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&gt_temp[23])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&gt_temp[22])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&gt_temp[21])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&gt_temp[20])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&gt_temp[19])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&gt_temp[18])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&gt_temp[17])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&gt_temp[16])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&gt_temp[15])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&gt_temp[14])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&gt_temp[13])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&gt_temp[12])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&gt_temp[11])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&gt_temp[10])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&gt_temp[9])|
	    (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&gt_temp[8])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&gt_temp[7])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&gt_temp[6])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&gt_temp[5])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&eq_temp[5]&gt_temp[4])|	
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&eq_temp[5]&eq_temp[4]&gt_temp[3])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&eq_temp[5]&eq_temp[4]&eq_temp[3]&gt_temp[2])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&eq_temp[5]&eq_temp[4]&eq_temp[3]&eq_temp[2]&gt_temp[1])|
            (eq_temp[31]&eq_temp[30]&eq_temp[29]&eq_temp[28]&eq_temp[27]&eq_temp[26]&eq_temp[25]&eq_temp[24]&eq_temp[23]&eq_temp[22]&eq_temp[21]&eq_temp[20]&eq_temp[19]&eq_temp[18]&eq_temp[17]&eq_temp[16]&eq_temp[15]&eq_temp[14]&eq_temp[13]&eq_temp[12]&eq_temp[11]&eq_temp[10]&eq_temp[9]&eq_temp[8]&eq_temp[7]&eq_temp[6]&eq_temp[5]&eq_temp[4]&eq_temp[3]&eq_temp[2]&eq_temp[1]&gt_temp[0])  
	    ;
assign lt = ~(eq|gt);
compare_1bit compare_0  (.a(a[0]),  .b(b[0]),  .eq(eq_temp[0]),  .gt(gt_temp[0]),  .lt(lt_temp[0]));
compare_1bit compare_1  (.a(a[1]),  .b(b[1]),  .eq(eq_temp[1]),  .gt(gt_temp[1]),  .lt(lt_temp[1]));
compare_1bit compare_2  (.a(a[2]),  .b(b[2]),  .eq(eq_temp[2]),  .gt(gt_temp[2]),  .lt(lt_temp[2]));
compare_1bit compare_3  (.a(a[3]),  .b(b[3]),  .eq(eq_temp[3]),  .gt(gt_temp[3]),  .lt(lt_temp[3]));
compare_1bit compare_4  (.a(a[4]),  .b(b[4]),  .eq(eq_temp[4]),  .gt(gt_temp[4]),  .lt(lt_temp[4]));
compare_1bit compare_5  (.a(a[5]),  .b(b[5]),  .eq(eq_temp[5]),  .gt(gt_temp[5]),  .lt(lt_temp[5]));
compare_1bit compare_6  (.a(a[6]),  .b(b[6]),  .eq(eq_temp[6]),  .gt(gt_temp[6]),  .lt(lt_temp[6]));
compare_1bit compare_7  (.a(a[7]),  .b(b[7]),  .eq(eq_temp[7]),  .gt(gt_temp[7]),  .lt(lt_temp[7]));
compare_1bit compare_8  (.a(a[8]),  .b(b[8]),  .eq(eq_temp[8]),  .gt(gt_temp[8]),  .lt(lt_temp[8]));
compare_1bit compare_9  (.a(a[9]),  .b(b[9]),  .eq(eq_temp[9]),  .gt(gt_temp[9]),  .lt(lt_temp[9]));
compare_1bit compare_10 (.a(a[10]), .b(b[10]), .eq(eq_temp[10]), .gt(gt_temp[10]), .lt(lt_temp[10]));
compare_1bit compare_11 (.a(a[11]), .b(b[11]), .eq(eq_temp[11]), .gt(gt_temp[11]), .lt(lt_temp[11]));
compare_1bit compare_12 (.a(a[12]), .b(b[12]), .eq(eq_temp[12]), .gt(gt_temp[12]), .lt(lt_temp[12]));
compare_1bit compare_13 (.a(a[13]), .b(b[13]), .eq(eq_temp[13]), .gt(gt_temp[13]), .lt(lt_temp[13]));
compare_1bit compare_14 (.a(a[14]), .b(b[14]), .eq(eq_temp[14]), .gt(gt_temp[14]), .lt(lt_temp[14]));
compare_1bit compare_15 (.a(a[15]), .b(b[15]), .eq(eq_temp[15]), .gt(gt_temp[15]), .lt(lt_temp[15]));
compare_1bit compare_16 (.a(a[16]), .b(b[16]), .eq(eq_temp[16]), .gt(gt_temp[16]), .lt(lt_temp[16]));
compare_1bit compare_17 (.a(a[17]), .b(b[17]), .eq(eq_temp[17]), .gt(gt_temp[17]), .lt(lt_temp[17]));
compare_1bit compare_18 (.a(a[18]), .b(b[18]), .eq(eq_temp[18]), .gt(gt_temp[18]), .lt(lt_temp[18]));
compare_1bit compare_19 (.a(a[19]), .b(b[19]), .eq(eq_temp[19]), .gt(gt_temp[19]), .lt(lt_temp[19]));
compare_1bit compare_20 (.a(a[20]), .b(b[20]), .eq(eq_temp[20]), .gt(gt_temp[20]), .lt(lt_temp[20]));
compare_1bit compare_21 (.a(a[21]), .b(b[21]), .eq(eq_temp[21]), .gt(gt_temp[21]), .lt(lt_temp[21]));
compare_1bit compare_22 (.a(a[22]), .b(b[22]), .eq(eq_temp[22]), .gt(gt_temp[22]), .lt(lt_temp[22]));
compare_1bit compare_23 (.a(a[23]), .b(b[23]), .eq(eq_temp[23]), .gt(gt_temp[23]), .lt(lt_temp[23]));
compare_1bit compare_24 (.a(a[24]), .b(b[24]), .eq(eq_temp[24]), .gt(gt_temp[24]), .lt(lt_temp[24]));
compare_1bit compare_25 (.a(a[25]), .b(b[25]), .eq(eq_temp[25]), .gt(gt_temp[25]), .lt(lt_temp[25]));
compare_1bit compare_26 (.a(a[26]), .b(b[26]), .eq(eq_temp[26]), .gt(gt_temp[26]), .lt(lt_temp[26]));
compare_1bit compare_27 (.a(a[27]), .b(b[27]), .eq(eq_temp[27]), .gt(gt_temp[27]), .lt(lt_temp[27]));
compare_1bit compare_28 (.a(a[28]), .b(b[28]), .eq(eq_temp[28]), .gt(gt_temp[28]), .lt(lt_temp[28]));
compare_1bit compare_29 (.a(a[29]), .b(b[29]), .eq(eq_temp[29]), .gt(gt_temp[29]), .lt(lt_temp[29]));
compare_1bit compare_30 (.a(a[30]), .b(b[30]), .eq(eq_temp[30]), .gt(gt_temp[30]), .lt(lt_temp[30]));
compare_1bit compare_31 (.a(a[31]), .b(b[31]), .eq(eq_temp[31]), .gt(gt_temp[31]), .lt(lt_temp[31]));
endmodule
