`timescale 1ns/1ps
module testbench;

reg  SYS_CLK; 
reg  Core_rst_n;   
reg  rst_oled;
reg  load_data;
reg  EN_PC;

wire oled_spi_clk;
wire oled_spi_data;
wire oled_vdd;
wire oled_vbat;
wire oled_reset_n;
wire oled_dc_n;

Core_With_OLED DUT (
	.SYS_CLK(SYS_CLK),
	.Core_rst_n(Core_rst_n),   
	.rst_oled(rst_oled),
	.load_data(load_data),
	.EN_PC(EN_PC),
	//oled interface
	.oled_spi_clk(oled_spi_clk),
	.oled_spi_data(oled_spi_data),
	.oled_vdd(oled_vdd),
	.oled_vbat(oled_vbat),
	.oled_reset_n(oled_reset_n),
	.oled_dc_n(oled_dc_n)
);

always begin
	#5
	SYS_CLK = ~SYS_CLK;
end

initial begin
	EN_PC      = 1'b0;
	Core_rst_n = 1'b0;
	rst_oled   = 1'b1;
	SYS_CLK    = 1'b0;
	load_data  = 1'b0;
	repeat (200) @(negedge SYS_CLK);
	Core_rst_n = 1'b1;
	rst_oled   = 1'b0;
	EN_PC      = 1'b1;
	repeat (1200) @(negedge SYS_CLK);
	load_data  = 1'b1;
    repeat (10) @(negedge SYS_CLK);
    load_data  = 1'b0;
    repeat (2000) @(negedge SYS_CLK);
	$stop;

end

endmodule