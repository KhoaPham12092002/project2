# =============================================================================
# RUN SCRIPT FOR IMEM UVM TEST (LINUX VERSION)
# =============================================================================

# 1. SETUP PATHS (Dùng đường dẫn tương đối để linh hoạt)
set SRC_DIR   "../src"
set VERIF_DIR "../verify"

# 2. CLEANUP & INIT LIBRARY
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# 3. PREPARE HEX FILE
if {[file exists "$SRC_DIR/memory/program.hex"]} {
    file copy -force "$SRC_DIR/memory/program.hex" .
}

# 4. COMPILE
puts "\[SCRIPT\] Compiling Design and UVM PKG..."
vlog -sv -timescale "1ns/1ps" \
    +incdir+$SRC_DIR/memory \
    +incdir+$VERIF_DIR/MCU \
    -L uvm \
    $SRC_DIR/memory/memory_pkg.sv \
    $SRC_DIR/memory/IMEM.sv \
    $VERIF_DIR/MCU/imem_pkg.sv \
    $VERIF_DIR/MCU/tb_top.sv

# 5. SIMULATE
# Bỏ -c nếu bạn muốn xem giao diện ModelSim GUI
vsim -voptargs=+acc -L uvm +UVM_TESTNAME=imem_basic_test work.tb_top

# 6. WAVEFORM (Chỉ chạy nếu có giao diện GUI)
if {[batch_mode] == 0} {
    add wave -noupdate -divider {INTERFACE}
    add wave -hex sim:/tb_top/vif/*
    add wave -noupdate -divider {INTERNAL_MEM}
    add wave -hex sim:/tb_top/dut/mem_array
}

run -all