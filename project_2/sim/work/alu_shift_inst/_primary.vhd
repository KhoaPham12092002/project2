library verilog;
use verilog.vl_types.all;
entity alu_shift_inst is
    port(
        a_i             : in     vl_logic_vector(31 downto 0);
        b_i             : in     vl_logic_vector(31 downto 0);
        shift_type_i    : in     vl_logic_vector(1 downto 0);
        result_o        : out    vl_logic_vector(31 downto 0)
    );
end alu_shift_inst;
