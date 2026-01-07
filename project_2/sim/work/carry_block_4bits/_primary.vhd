library verilog;
use verilog.vl_types.all;
entity carry_block_4bits is
    port(
        carry_in        : in     vl_logic;
        p               : in     vl_logic_vector(3 downto 0);
        g               : in     vl_logic_vector(3 downto 0);
        cin_out         : out    vl_logic_vector(3 downto 0);
        cout            : out    vl_logic;
        P_out           : out    vl_logic;
        G_out           : out    vl_logic
    );
end carry_block_4bits;
