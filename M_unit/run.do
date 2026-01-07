# ============================================================================
# Script run.do - Phien ban tuong thich ModelSim 10.1d (Fixed)
# ============================================================================

# 1. Lay tham so tu lenh 'do run.do <arch>'
set ARCH "32_cycle"
if {[info exists 1]} {
    set ARCH $1
}

# 2. Xac dinh ten file design tuong ung
set DESIGN_FILE "M_32_cycle.sv"
if {$ARCH == "dsp"} {
    set DESIGN_FILE "M_dsp.sv"
} elseif {$ARCH == "tree"} {
    set DESIGN_FILE "M_tree.sv"
}

# Chuyen ten kien truc sang chu hoa (Dung lenh toupper)
set ARCH_UP [string toupper $ARCH]

# 3. In thong tin ra Console
echo "-------------------------------------------------------"
echo ">>> DANG KIEM TRA KIEN TRUC: $ARCH_UP"
echo ">>> FILE DESIGN DUOC NAP   : $DESIGN_FILE"
echo "-------------------------------------------------------"

# 4. Khoi tao thu vien work
if [file exists work] { vdel -all }
vlib work

# 5. Bien dich cac file chung
vlog -sv -work work package.sv
vlog -sv -work work adder.sv

# 6. Bien dich file Design duoc chon
vlog -sv -work work $DESIGN_FILE

# 7. Bien dich Testbench
vlog -sv -work work tb.sv

# 8. Khoi dong mo phong che do Console
vsim -c -voptargs=+acc work.tb

# 9. Chay mo phong
run -all

# 10. Thoat
quit -f