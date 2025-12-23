# --- Cấu hình đường dẫn (Relative Paths) ---
set SUB_PATH    "../src/module_dau"
set TB_PATH     "../verif/tb"

# 1. Khởi tạo thư viện work (Xóa cũ tạo mới để đảm bảo sạch sẽ)
if [file exists work] {
    vdel -all
}
vlib work
vmap work work

# 2. Biên dịch các file (Chỉ tập trung vào Unit Test cho add_sub)

# Biên dịch module cộng/trừ 32-bit (CLA)
vlog -sv $SUB_PATH/add_sub.sv

# Biên dịch Testbench tương ứng
vlog -sv $TB_PATH/tb_add_sub.sv

# 3. Nạp mô phỏng
# -voptargs="+acc" cho phép bạn xem mọi tín hiệu bên trong CLA (như P, G, cin)
vsim -voptargs="+acc" work.tb_add_sub

# 4. Thêm sóng (Waveform)
add wave -divider "INPUTS"
add wave sim:/tb_add_sub/a
add wave sim:/tb_add_sub/b
add wave sim:/tb_add_sub/add_sub
add wave sim:/tb_add_sub/carry_in

add wave -divider "OUTPUTS"
add wave -color Yellow sim:/tb_add_sub/sum_dif
add wave -color Cyan   sim:/tb_add_sub/C
add wave -color Red    sim:/tb_add_sub/V

# Thêm tín hiệu bên trong khối CLA để verify logic Carry Look-ahead
add wave -divider "INTERNAL CLA LOGIC"
add wave sim:/tb_add_sub/dut/cin
add wave sim:/tb_add_sub/dut/C_blk

# 5. Chạy mô phỏng
run -all

# Tự động zoom toàn bộ kết quả
wave zoom full