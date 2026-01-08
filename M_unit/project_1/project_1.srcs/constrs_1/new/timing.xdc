# Tạo xung Clock 50 MHz (Chu kỳ 20ns) trên chân clk
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} [get_ports clk]

# Ví dụ gán chân (nếu bạn dùng board Basys 3, chân clock thường là W5)
# set_property PACKAGE_PIN W5 [get_ports clk]							
# set_property IOSTANDARD LVCMOS33 [get_ports clk]