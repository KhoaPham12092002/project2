`timescale 1ns/1ps
import memory_pkg::*; // [QUAN TRỌNG]

module databusmux (
    input  dev_sel_t    dcsel,          // [UPDATE] Kiểu Enum từ Address Decoder
    
    input  logic [31:0] idata,          // Từ IMEM (Load constant)
    input  logic [31:0] ddata_r_mem,    // Từ DMEM (Load var)
    input  logic [31:0] ddata_r_periph, // Từ IO (Read Register)
    input  logic [31:0] ddata_r_sdram,  // Từ SDRAM
    
    output logic [31:0] ddata_r         // Về CPU Writeback
);

    always_comb begin
        case (dcsel)
            DEV_IMEM:   ddata_r = idata;
            DEV_DMEM:   ddata_r = ddata_r_mem;
            DEV_IO:     ddata_r = ddata_r_periph;
            DEV_SDRAM:  ddata_r = ddata_r_sdram;
            default:    ddata_r = 32'b0; // Safe default
        endcase
    end

endmodule