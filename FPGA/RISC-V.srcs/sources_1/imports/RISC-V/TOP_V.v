(* DONT_TOUCH = "TRUE" *) module Core_With_OLED (
    input  wire SYS_CLK, // 100 MHz 
    input  wire Core_rst_n,   
    input  wire rst_oled,
    input  wire load_data,
    input  wire EN_PC,
    // Instruction Done
    output wire PC_done,
    //oled interface
    output wire oled_spi_clk,    // 10MHZ
    output wire oled_spi_data,
    output wire oled_vdd,
    output wire oled_vbat,
    output wire oled_reset_n,
    output wire oled_dc_n
);

wire [31:0] reg_31;

(* DONT_TOUCH = "TRUE" *) RV32IMF Core (
    .rst_n(Core_rst_n),
    .CLK(SYS_CLK), // 100 MHz
    .EN_PC(EN_PC),
    .PC_done(PC_done),
    .ireg_31(reg_31)
);

(* DONT_TOUCH = "TRUE" *) top OLED_Interface (
    .clock(SYS_CLK), //100MHz onboard clock
    .reset(rst_oled),
    // DTA interface 
    .decimal(reg_31),
    .load_data(load_data),
    //oled interface
    .oled_spi_clk(oled_spi_clk),    // 10MHZ
    .oled_spi_data(oled_spi_data),
    .oled_vdd(oled_vdd),
    .oled_vbat(oled_vbat),
    .oled_reset_n(oled_reset_n),
    .oled_dc_n(oled_dc_n)
);

endmodule
