`include "uvm_macros.svh"
import uvm_pkg::*;
import imem_pkg::*; // Import gói UVM ta vừa viết

// Định nghĩa Interface
interface imem_if (input logic clk);
    logic        rst;
    logic [31:0] addr;
    logic [31:0] instr;
endinterface

module tb_top;
    logic clk;
    
    // Tạo Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instance Interface
    imem_if vif(clk);

    // Instance DUT (Device Under Test)
    imem #(
        .HEX_FILE("program.hex"),
	.MEM_SIZE(4096)
    ) dut (
        .clk_i   (clk),
        .rst_i  (vif.rst),
        .addr_i  (vif.addr),
        .instr_o (vif.instr)
    );

    // Block khởi chạy UVM
    initial begin
        vif.rst = 1;
	vif.addr =0;
	#20;
        vif.rst = 0;
	end

        // Đăng ký Interface vào Config DB để Driver/Monitor tìm thấy
	initial begin
	uvm_config_db#(virtual imem_if)::set(null, "*", "vif", vif);

        // Chạy Test
        run_test("imem_basic_test");
    end
	initial begin
    // In tiêu đề cột cho dễ nhìn
    $display("Time  | Reset | Address    | Instruction");
    $display("------+-------+------------+------------");
    
    // $monitor tự động chạy khi bất kỳ signal nào trong danh sách thay đổi
    $monitor("%4t  |   %b   | %h   | %h", 
             $time, vif.rst, vif.addr, vif.instr);
end
endmodule
