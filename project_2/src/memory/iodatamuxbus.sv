`timescale 1ns/1ps
import memory_pkg::*; // [QUAN TRỌNG]

module iodatabusmux (
    input  logic [31:0] daddress,

    // Các kênh dữ liệu từ thiết bị ngoại vi
    input  logic [31:0] ddata_r_gpio,
    input  logic [31:0] ddata_r_segments,
    input  logic [31:0] ddata_r_uart,
    input  logic [31:0] ddata_r_adc,
    input  logic [31:0] ddata_r_i2c,
    input  logic [31:0] ddata_r_timer,
    input  logic [31:0] ddata_r_dif_fil,
    input  logic [31:0] ddata_r_stepmot,
    input  logic [31:0] ddata_r_lcd,
    input  logic [31:0] ddata_r_nn_accelerator,
    input  logic [31:0] ddata_r_fir_fil,
    input  logic [31:0] ddata_r_spwm,
    input  logic [31:0] ddata_r_crc,
    input  logic [31:0] ddata_r_key,
    input  logic [31:0] ddata_r_accelerometer,
    input  logic [31:0] ddata_r_cordic,
    input  logic [31:0] ddata_r_RS485,
    input  logic [31:0] ddata_r_rgb,

    output logic [31:0] ddata_r_periph
);

    // Selector: daddress[19:4] (Offset 16 bytes)
    // Ép kiểu về enum periph_addr_t để so sánh trong case
    periph_addr_t periph_id;
    assign periph_id = periph_addr_t'(daddress[19:4]);

    always_comb begin
        case (periph_id)
            ADDR_GPIO:           ddata_r_periph = ddata_r_gpio;
            ADDR_SEGMENTS:       ddata_r_periph = ddata_r_segments;
            ADDR_UART:           ddata_r_periph = ddata_r_uart;
            ADDR_ADC:            ddata_r_periph = ddata_r_adc;
            ADDR_I2C:            ddata_r_periph = ddata_r_i2c;
            ADDR_TIMER:          ddata_r_periph = ddata_r_timer;
            
            ADDR_DIF_FIL:        ddata_r_periph = ddata_r_dif_fil;
            ADDR_STEP_MOT:       ddata_r_periph = ddata_r_stepmot;
            ADDR_LCD:            ddata_r_periph = ddata_r_lcd;
            ADDR_NN_ACCEL:       ddata_r_periph = ddata_r_nn_accelerator;
            
            ADDR_FIR_FIL:        ddata_r_periph = ddata_r_fir_fil;
            ADDR_KEY:            ddata_r_periph = ddata_r_key;
            ADDR_CRC:            ddata_r_periph = ddata_r_crc;
            
            ADDR_SPWM:           ddata_r_periph = ddata_r_spwm;
            ADDR_ACCEL:          ddata_r_periph = ddata_r_accelerometer;
            ADDR_CORDIC:         ddata_r_periph = ddata_r_cordic;
            ADDR_RS485:          ddata_r_periph = ddata_r_RS485;
            ADDR_RGB:            ddata_r_periph = ddata_r_rgb;

            default:             ddata_r_periph = 32'b0;
        endcase
    end

endmodule