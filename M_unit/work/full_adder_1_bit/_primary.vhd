library verilog;
use verilog.vl_types.all;
entity full_adder_1_bit is
    port(
        a               : in     vl_logic;
        b               : in     vl_logic;
        cin             : in     vl_logic;
        add_sub         : in     vl_logic;
        sum_dif         : out    vl_logic;
        p               : out    vl_logic;
        g               : out    vl_logic
    );
end full_adder_1_bit;
