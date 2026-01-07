library verilog;
use verilog.vl_types.all;
library work;
entity riscv_m_unit is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        valid           : in     vl_logic;
        m_req           : in     work.\M_types_pkg\.\M_req_t\;
        result          : out    vl_logic_vector(31 downto 0);
        ready           : out    vl_logic;
        busy            : out    vl_logic
    );
end riscv_m_unit;
