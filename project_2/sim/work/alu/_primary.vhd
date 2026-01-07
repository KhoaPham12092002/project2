library verilog;
use verilog.vl_types.all;
library work;
entity alu is
    port(
        alu_req         : in     work.alu_types_pkg.alu_req_t;
        Zero            : out    vl_logic;
        alu_o           : out    vl_logic_vector(31 downto 0)
    );
end alu;
