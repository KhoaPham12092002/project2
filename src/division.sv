/* verilator lint_off EOFNEWLINE */
/*module division #(parameter WIDTH = 32) (
    input  logic 		clk,         
    input  logic 		rst_ni,
    input  logic 		start,          // start calculation
    input  logic [WIDTH-1:0] 	a,    		// dividend
    input  logic [WIDTH-1:0] 	b,              // divisor 

    output logic 		busy,           // calculation in progress
    output logic 		done,           // calculation is complete
    output logic 		valid,          // result is valid
    output logic [WIDTH-1:0] 	val,  		// result value: quotient
    output logic [WIDTH-1:0] 	rem   		// result: remainder
    );

    logic [WIDTH-1:0] 		b1;             // copy of divisor
    logic [WIDTH-1:0] 		quo, quo_next;  // temp quotient
    logic [WIDTH:0] 		acc, acc_next;  // accumulator (1 bit wider)
    logic [$clog2(WIDTH)-1:0] 	i;      	// iteration counter

    // division algorithm iteration
    always_comb begin
        if (acc >= {1'b0, b1}) begin
            acc_next = acc - b1;
            {acc_next, quo_next} = {acc_next[WIDTH-1:0], quo, 1'b1};
        end else begin
            {acc_next, quo_next} = {acc, quo} << 1;
        end
    end

    // calculation control
    always_ff @(posedge clk, negedge rst_ni) begin
        done <= 0;
	if (!rst_ni && start) begin
            busy  <= 0;
            done  <= 0;
            valid <= 0;
            val   <= 0;
            rem   <= 0;
	    valid <= 0;
            i     <= 0;
        end
        if (rst_ni && start) begin
            if (i < 31) begin
                busy <= 1;
                b1 <= b;
                {acc, quo} <= {{WIDTH{1'b0}}, a, 1'b0};  // initialize calculation
            end
	    if (busy) begin
		if (i == 31) begin  // we're done
                busy  <= 0;
                done  <= 1;
                valid <= 1;
                val   <= quo_next;
                rem   <= acc_next[WIDTH:1]; // undo final shift
		i     <= 31;
	        end else begin  // next iteration
                i     <= i + 1;
                acc   <= acc_next;
                quo   <= quo_next;
		end
	    end
        end	
    end

endmodule*/
module division #(parameter WIDTH = 32) (
    input  logic        clk,         
    input  logic        rst_ni,
    input  logic        start,          // start calculation
    input  logic [WIDTH-1:0]  a,      // dividend
    input  logic [WIDTH-1:0]  b,      // divisor 

    output logic        busy,           // calculation in progress
    output logic        done,           // calculation is complete
    output logic        valid,          // result is valid
    output logic [WIDTH-1:0] val,        // result value: quotient
    output logic [WIDTH-1:0] rem         // result: remainder
    );

    logic [WIDTH-1:0]    b1;             // copy of divisor
    logic [WIDTH-1:0]    quo, quo_next;  // temp quotient
    logic [WIDTH:0]      acc, acc_next;  // accumulator (1 bit wider)
    logic [$clog2(WIDTH)-1:0] i;         // iteration counter

    // division algorithm iteration
    always_comb begin
        if (acc >= {1'b0, b1}) begin
            acc_next = acc - b1;
            {acc_next, quo_next} = {acc_next[WIDTH-1:0], quo, 1'b1};
        end else begin
            {acc_next, quo_next} = {acc, quo} << 1;
        end
    end

    // calculation control
    always_ff @(posedge clk, negedge rst_ni) begin
        if (!rst_ni) begin
            busy  <= 0;
            done  <= 0;
            valid <= 0;
            val   <= 0;
            rem   <= 0;
            valid <= 0;
            i     <= 0;
        end
        else begin
            if (start && (i < 31)) begin
                busy <= 1;
                b1 <= b;
                {acc, quo} <= {{WIDTH{1'b0}}, a, 1'b0};  // initialize calculation
            end
            if (busy && (i == 31)) begin  // we're done
                busy  <= 0;
                done  <= 1;
                valid <= 1;
                val   <= quo_next;
                rem   <= acc_next[WIDTH:1]; // undo final shift
                i     <= 31;
            end
            else if (busy) begin  // next iteration
                i     <= i + 1;
                acc   <= acc_next;
                quo   <= quo_next;
            end
        end
    end
endmodule
