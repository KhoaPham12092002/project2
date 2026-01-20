# =============================================================================
# RUN SCRIPT FOR IMEM UVM TEST
# =============================================================================

# 1. Dọn dẹp thư viện cũ (Clean start)
if [file exists work] { vdel -lib work -all }
vlib work

# 2. Định nghĩa biến đường dẫn (Relative Paths từ thư mục 'sim')
# ../src        tương đương C:/Users/Khoa/project2/project_2/src
# ../verify     tương đương C:/Users/Khoa/project2/project_2/verify
#
set DUT_PATH    "../src/memory/IMEM.sv"
set PKG_PATH    "../verify/MCU/imem_pkg.sv"
set TB_PATH     "../verify/MCU/tb_top.sv"

# 3. Biên dịch (Compile)
# Lưu ý: ModelSim dùng dấu gạch chéo '/' cho đường dẫn (dù là Windows)

echo "Compiling DUT..."
vlog -sv -work work $DUT_PATH

echo "Compiling UVM Package & Testbench..."
# +incdir+... giúp compiler tìm thấy các file include bên trong thư mục MCU (nếu có)
# -L uvm giúp link thư viện UVM có sẵn
vlog -sv -work work -L uvm +incdir+../verify/MCU $PKG_PATH $TB_PATH

# 4. Kiểm tra file program.hex
# File hex phải nằm ngay tại thư mục 'sim' để $readmemh tìm thấy
if {![file exists "program.hex"]} {
    echo "WARNING: File 'program.hex' khong tim thay trong thu muc sim!"
    echo "Creating dummy program.hex..."
    set fp [open "program.hex" w]
    puts $fp "00500093"
    puts $fp "00700113"
    puts $fp "002081B3"
    puts $fp "DEADBEEF"
    close $fp
}

# 5. Chạy mô phỏng (Elaborate & Simulate)
echo "Starting Simulation..."
# -voptargs=+acc: Giữ lại tín hiệu để debug waveform
# -L uvm: Load thư viện UVM
vsim -voptargs=+acc -L uvm work.tb_top

# 6. Thiết lập Waveform
# Tắt bớt các warnings không cần thiết của UVM
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Add các tín hiệu quan trọng
add wave -noupdate -divider {INTERFACE}
add wave -noupdate -color yellow -radix hex sim:/tb_top/vif/clk
add wave -noupdate -color yellow -radix hex sim:/tb_top/vif/rst_n
add wave -noupdate -color cyan   -radix hex sim:/tb_top/vif/addr
add wave -noupdate -color green  -radix hex sim:/tb_top/vif/instr

add wave -noupdate -divider {INTERNAL MEMORY}
# Chỉ hiển thị 10 dòng đầu của mảng nhớ để đỡ lag
add wave -noupdate -radix hex sim:/tb_top/dut/mem_array(0)
add wave -noupdate -radix hex sim:/tb_top/dut/mem_array(1)
add wave -noupdate -radix hex sim:/tb_top/dut/mem_array(2)
add wave -noupdate -radix hex sim:/tb_top/dut/mem_array(3)

# Zoom toàn bộ
view structure
view signals
view wave

# 7. Chạy Simulation
echo "Running UVM Test..."
run -all

# Zoom fit màn hình sau khi chạy xong
wave zoom full