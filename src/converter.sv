module converter(
	input  logic 		clk, rst_n,
	input  logic [31:0] 	result,
        input  logic [31:0]     io_sw_i,

	output logic [31:0] 	temp9, temp8, temp7, temp6, temp5, temp4, temp3, temp2, temp1, temp0,
	output logic 		busy9, busy8, busy7, busy6, busy5, busy4, busy3, busy2, busy1, busy0,
	output logic		valid9, valid8, valid7, valid6, valid5, valid4, valid3, valid2, valid1, valid0,
	output logic            done9, done8, done7, done6, done5, done4, done3, done2, done1, done0,
	output logic [31:0]     digit9, digit8, digit7, digit6, digit5, digit4, digit3, digit2, digit1, digit0						
);


logic start; 
assign start = (io_sw_i == result) ? 1 : 0;

division	d0(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(start),           
    .a(result),
    .b(32'd10), 
    .busy(busy0),
    .done(done0),
    .valid(valid0),    
    .val(temp0),
    .rem(digit0)
); 
	
	
division	d1(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid0),           
    .a(temp0),
    .b(32'd10), 
    .busy(busy1),
    .done(done1),
    .valid(valid1),   
    .val(temp1),
    .rem(digit1)
); 
	
division	d2(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid1),           
    .a(temp1),
    .b(32'd10), 
    .busy(busy2),
    .done(done2),
    .valid(valid2),   
    .val(temp2),
    .rem(digit2)
); 

division	d3(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid2),           
    .a(temp2),
    .b(32'd10), 
    .busy(busy3),
    .done(done3),
    .valid(valid3),   
    .val(temp3),
    .rem(digit3)
); 
	
division	d4(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid3),           
    .a(temp3),
    .b(32'd10), 
    .busy(busy4),
    .done(done4),
    .valid(valid4),   
    .val(temp4),
    .rem(digit4)
); 
	
division	d5(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid4),           
    .a(temp4),
    .b(32'd10), 
    .busy(busy5),
    .done(done5),
    .valid(valid5),   
    .val(temp5),
    .rem(digit5)
); 
	
division	d6(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid5),           
    .a(temp5),
    .b(32'd10), 
    .busy(busy6),
    .done(done6),
    .valid(valid6),   
    .val(temp6),
    .rem(digit6)
); 
	
division	d7(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid6),           
    .a(temp6),
    .b(32'd10), 
    .busy(busy7),
    .done(done7),
    .valid(valid7),   
    .val(temp7),
    .rem(digit7)
); 
	
division	d8(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid7),           
    .a(temp7),
    .b(32'd10), 
    .busy(busy8),
    .done(done8),
    .valid(valid8),   
    .val(temp8),
    .rem(digit8)
); 
	
division	d9(
    .clk(clk),
    .rst_ni(rst_n),              
    .start(valid8),           
    .a(temp8),
    .b(32'd10), 
    .busy(busy9),
    .done(done9),
    .valid(valid9),   
    .val(temp9),
    .rem(digit9)
); 	
	
endmodule


