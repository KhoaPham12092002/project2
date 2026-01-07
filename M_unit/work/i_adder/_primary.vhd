library verilog;
use verilog.vl_types.all;
entity i_adder is
    port(
        a               : in     vl_logic_vector(31 downto 0);
        b               : in     vl_logic_vector(31 downto 0);
        carry_in        : in     vl_logic;
        add_sub         : in     vl_logic;
        sum_dif         : out    vl_logic_vector(31 downto 0);
        C               : out    vl_logic;
        V               : out    vl_logic
    );
end i_adder;
